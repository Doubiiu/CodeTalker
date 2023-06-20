from einops.layers.torch import Rearrange
import torch
import torch.nn as nn
from torch.nn import functional as F

from utils.base_model_util import *
import math

class Norm(nn.Module):
  """ Norm Layer """

  def __init__(self, fn, size):
    super().__init__()
    self.norm = nn.LayerNorm(size, eps=1e-5)
    self.fn = fn

  def forward(self, x_data):
    if type(x_data) is dict:
        x_norm = self.fn({'x_a':x_data['x_a'], 'x_b':self.norm(x_data['x_b'])})
        return x_norm
    else:
        x, mask_info = x_data
        x_norm, _ = self.fn((self.norm(x), mask_info))
        return (x_norm, mask_info)

class Residual(nn.Module):
  """ Residual Layer """

  def __init__(self, fn):
    super().__init__()
    self.fn = fn

  def forward(self, x_data):
    if type(x_data) is dict:
        x_resid = self.fn(x_data)['x_b']
        return {'x_a':x_data['x_a'], 'x_b':x_resid+x_data['x_b']}
    else:
        x, mask_info = x_data
        x_resid, _ = self.fn(x_data)
        return (x_resid + x, mask_info)


class MLP(nn.Module):
  """ MLP Layer """

  def __init__(self, in_dim, out_dim, hidden_dim):
    super().__init__()
    self.l1 = nn.Linear(in_dim, hidden_dim)
    self.activation = get_activation("gelu")
    self.l2 = nn.Linear(hidden_dim, out_dim)

  def forward(self, x_data):
    if type(x_data) is dict:
        out = self.l2(self.activation(self.l1(x_data['x_b'])))
        return {'x_a':x_data['x_a'], 'x_b':out}
    else:
        x, mask_info = x_data
        out = self.l2(self.activation(self.l1(x)))
        return (out, mask_info)


class CrossModalAttention(nn.Module):
  """ Cross Modal Attention Layer
  Given 2 modalities (a, b), computes the K,V from modality b and Q from
  modality a.
  """

  def __init__(self, in_dim, dim, heads=8, in_dim2=None):
    super().__init__()
    self.heads = heads
    self.scale = dim**-0.5

    if in_dim2 is not None:
        self.to_kv = nn.Linear(in_dim2, in_dim2 * 2, bias=False)
    else:
        self.to_kv = nn.Linear(in_dim, dim * 2, bias=False)
    self.to_q = nn.Linear(in_dim, dim, bias=False)
    if in_dim2 is not None:
        dim2 = int((in_dim + in_dim2*2) / 3)
    else:
        dim2 = dim
    self.to_out = nn.Linear(dim2, dim)

    self.rearrange_qkv = Rearrange(
        "b n (qkv h d) -> qkv b h n d", qkv=3, h=self.heads)
    self.rearrange_out = Rearrange("b h n d -> b n (h d)")

  def forward(self, x_data):
    x_a = x_data['x_a']
    x_b = x_data['x_b']

    kv = self.to_kv(x_b)
    q = self.to_q(x_a)

    qkv = torch.cat((q, kv), dim=-1)
    qkv = self.rearrange_qkv(qkv)
    q = qkv[0]
    k = qkv[1]
    v = qkv[2]

    dots = torch.einsum("bhid,bhjd->bhij", q, k) * self.scale
    attn = F.softmax(dots, dim=-1)

    out = torch.einsum("bhij,bhjd->bhid", attn, v)
    out = self.rearrange_out(out)
    out = self.to_out(out)
    return {'x_a':x_a, 'x_b':out}


class Attention(nn.Module):
  """ Attention Layer """

  def __init__(self, in_dim, dim, heads=8):
    super().__init__()
    self.heads = heads
    self.scale = dim**-0.5

    self.to_qkv = nn.Linear(in_dim, dim * 3, bias=False)
    self.to_out = nn.Linear(dim, dim)

    self.rearrange_qkv = Rearrange(
        "b n (qkv h d) -> qkv b h n d", qkv=3, h=self.heads)
    self.rearrange_out = Rearrange("b h n d -> b n (h d)")

  def forward(self, x_data):
    x, mask_info = x_data
    max_mask = mask_info['max_mask']
    mask = mask_info['mask']
    #
    qkv = self.to_qkv(x)
    qkv = self.rearrange_qkv(qkv)
    q = qkv[0]
    k = qkv[1]
    v = qkv[2]

    dots = torch.einsum("bhid,bhjd->bhij", q, k) * self.scale
    if max_mask is not None:
        dots[:,:,:max_mask,:max_mask] = \
            dots[:,:,:max_mask,:max_mask].masked_fill(mask == 0., float('-inf'))

    attn = F.softmax(dots, dim=-1)

    out = torch.einsum("bhij,bhjd->bhid", attn, v)
    out = self.rearrange_out(out)
    out = self.to_out(out)
    return (out, mask_info)


class Transformer(nn.Module):
  """ Transformer class
  Parameters
  ----------
  cross_modal : bool
    if true, uses cross-modal attention layers, else is the vanilla Transformer
  in_dim2 : int
    specifies the feature size of the second modality if using cross_modal
  """

  def __init__(self,
               in_size=50,
               hidden_size=768,
               num_hidden_layers=12,
               num_attention_heads=12,
               intermediate_size=3072,
               cross_modal=False,
               in_dim2=None):
    super().__init__()
    blocks = []
    attn = False

    self.cross_modal = cross_modal
    if cross_modal:
      for i in range(num_hidden_layers):
        blocks.extend([
            Residual(Norm(CrossModalAttention(in_size, hidden_size,
                                              heads=num_attention_heads,
                                              in_dim2=in_dim2), hidden_size)),
            Residual(Norm(MLP(hidden_size, hidden_size, intermediate_size),
                              hidden_size))
        ])
    else:
      for i in range(num_hidden_layers):
        blocks.extend([
            Residual(Norm(Attention(in_size, hidden_size,
                                    heads=num_attention_heads), hidden_size)),
            Residual(Norm(MLP(hidden_size, hidden_size, intermediate_size),
                              hidden_size))
        ])
    self.net = torch.nn.Sequential(*blocks)

  def forward(self, x_data):
    if self.cross_modal:
      assert type(x_data) is dict
      x_data = self.net(x_data)
      x = x_data['x_b']
    else:
      x, mask_info = x_data
      x, _ = self.net((x, mask_info))
    return x


class LinearEmbedding(nn.Module):
  """ Linear Layer """

  def __init__(self, size, dim):
    super().__init__()
    self.net = nn.Linear(size, dim)

  def forward(self, x):
    return self.net(x)


class AudioEmbedding(nn.Module):
  """ Audio embedding layer
  Parameters
  ----------
  size : int
    the input feature size of the audio embedding
  dim : int
    the desired output feature size for the audio embedding
  quant_factor: int
    specifies the number of max pool layers applied along the temporal dimension
  version: str (default is 'v6')
    specifies which version of the audio embedding to use
  """

  def __init__(self, size, dim, quant_factor, version='v6'):
    super().__init__()
    self.proj = None
    if version == 'v6':
        print('MODEL V6')
        self.net = nn.MaxPool1d(4)
        layers = [nn.Sequential(nn.MaxPool1d(2))]
        for _ in range(1, quant_factor):
            layers += [nn.Sequential(
                           nn.MaxPool1d(2)
                           )]
        self.squasher = nn.Sequential(*layers)
        self.proj = nn.Linear(size,dim)

  def forward(self, x):
    x = self.net(x)
    x = self.squasher(x)
    if self.proj is not None:
        x = self.proj(x.permute(0,2,1)).permute(0,2,1)
    return x

class PositionEmbedding(nn.Module):
  """Postion Embedding Layer"""

  def __init__(self, seq_length, dim):
    super().__init__()
    self.pos_embedding = nn.Parameter(torch.zeros(seq_length, dim))

  def forward(self, x):
    return x + self.pos_embedding

class PositionalEncoding(nn.Module):
    def __init__(self, d_model, dropout=0.1, max_len=5000):
        super(PositionalEncoding, self).__init__()
        self.dropout = nn.Dropout(p=dropout)

        pe = torch.zeros(max_len, d_model)
        position = torch.arange(0, max_len, dtype=torch.float).unsqueeze(1)
        div_term = torch.exp(torch.arange(0, d_model, 2).float() * (-math.log(10000.0) / d_model))
        pe[:, 0::2] = torch.sin(position * div_term)
        pe[:, 1::2] = torch.cos(position * div_term)
        pe = pe.unsqueeze(0).transpose(0, 1)
        self.register_buffer('pe', pe)

    def forward(self, x):
        x = x + self.pe[:x.size(0), :]
        return self.dropout(x)


class CrossModalLayer(nn.Module):
  """Cross Modal Layer inspired by FACT [Li 2021]"""

  def __init__(self, config):
    super().__init__()
    self.config = config
    model_config = self.config['transformer']
    self.transformer_layer = Transformer(
        in_size=model_config['hidden_size'],
        hidden_size=model_config['hidden_size'],
        num_hidden_layers=model_config['num_hidden_layers'],
        num_attention_heads=model_config['num_attention_heads'],
        intermediate_size=model_config['intermediate_size'])

    output_layer_config = self.config['output_layer']
    self.cross_norm_layer = nn.LayerNorm(self.config['in_dim'])
    self.cross_output_layer = nn.Linear(
                                    self.config['in_dim'],
                                    output_layer_config['out_dim'],
                                    bias=False)

    self.cross_pos_embedding = PositionEmbedding(
            self.config["sequence_length"], self.config['in_dim'])


  def forward(self, modal_a_sequences, modal_b_sequences, mask_info):
    """
    Parameters
    ----------
    modal_a_sequences : tensor
        the first modality (e.g. Listener motion embedding)
    modal_b_sequences : tensor
        the second modality (e.g. Speaker motion+audio embedding)
    mask_info: dict
        specifies the binary mask that is applied to the Transformer attention
    """

    _, _, modal_a_width = get_shape_list(modal_a_sequences)
    merged_sequences = modal_a_sequences
    if modal_b_sequences is not None:
        _, _, modal_b_width = get_shape_list(modal_b_sequences)
        if modal_a_width != modal_b_width:
          raise ValueError(
              "The modal_a hidden size (%d) should be the same with the modal_b"
              "hidden size (%d)" % (modal_a_width, modal_b_width))
        merged_sequences = torch.cat([merged_sequences, modal_b_sequences],
                                      axis=1)

    merged_sequences = self.cross_pos_embedding(merged_sequences)
    merged_sequences = self.transformer_layer((merged_sequences, mask_info))
    merged_sequences = self.cross_norm_layer(merged_sequences)
    logits = self.cross_output_layer(merged_sequences)
    return logits