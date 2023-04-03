## Code adopted from Google [Li 2021]: https://google.github.io/aichoreographer/

import numpy as np
import six
import torch
import torch.nn as nn


def dropout(input_tensor, dropout_prob):
  """Perform dropout.

  Args:
    input_tensor: float Tensor.
    dropout_prob: Python float. The probability of dropping out a value (NOT of
      *keeping* a dimension as in `tf.nn.dropout`).

  Returns:
    A version of `input_tensor` with dropout applied.
  """
  if dropout_prob is None or dropout_prob == 0.0:
    return input_tensor

  output = nn.Dropout(input_tensor, rate=dropout_prob)
  return output


def create_look_ahead_mask(seq_length, batch_size=0):
  """Create a look ahead mask given a certain seq length.

  Args:
    seq_length: int the length of the sequence.
    batch_size: if batch_size if provided, the mask will be repeaded.

  Returns:
    the mask ((batch_size), seq_length, seq_length)
  """
  mask = 1 - troch.tril(torch.ones((seq_length, seq_length)))
  if batch_size > 0:
    mask = torch.repeat(torch.unsqueeze(mask, dim=0), batch_size, dim=0)
  return mask


def create_attention_mask_from_input_mask(from_tensor, to_mask):
  """Create 3D attention mask from a 2D tensor mask.

  Args:
    from_tensor: 2D or 3D Tensor of shape [batch_size, from_seq_length, ...].
    to_mask: int32 Tensor of shape [batch_size, to_seq_length].

  Returns:
    float Tensor of shape [batch_size, from_seq_length, to_seq_length].
  """
  from_shape = get_shape_list(from_tensor)
  batch_size = from_shape[0]
  from_seq_length = from_shape[1]

  to_shape = get_shape_list(to_mask)
  to_seq_length = to_shape[1]

  to_mask = torch.reshape(to_mask, (batch_size, 1, to_seq_length)).float()

  # We don't assume that `from_tensor` is a mask (although it could be). We
  # don't actually care if we attend *from* padding tokens (only *to* padding)
  # tokens so we create a tensor of all ones.
  #
  # `broadcast_ones` = [batch_size, from_seq_length, 1]
  broadcast_ones = torch.ones(
      shape=[batch_size, from_seq_length, 1]).float()

  # Here we broadcast along two dimensions to create the mask.
  mask = broadcast_ones * to_mask

  return mask


# def create_initializer(initializer_range=0.02):
#   """Creates a `truncated_normal_initializer` with the given range."""
#   return tf.keras.initializers.TruncatedNormal(stddev=initializer_range)


def gelu(x):
  """Gaussian Error Linear Unit.

  This is a smoother version of the RELU.
  Original paper: https://arxiv.org/abs/1606.08415
  Args:
    x: float Tensor to perform activation.

  Returns:
    `x` with the GELU activation applied.
  """
  cdf = 0.5 * (1.0 + torch.tanh(
      (np.sqrt(2 / np.pi) * (x + 0.044715 * torch.pow(x, 3)))))
  return x * cdf


def get_activation(activation_string):
  """Maps a string to a Python function, e.g., "relu" => `tf.nn.relu`.

  Args:
    activation_string: String name of the activation function.

  Returns:
    A Python function corresponding to the activation function. If
    `activation_string` is None, empty, or "linear", this will return None.
    If `activation_string` is not a string, it will return `activation_string`.

  Raises:
    ValueError: The `activation_string` does not correspond to a known
      activation.
  """

  # We assume that anything that"s not a string is already an activation
  # function, so we just return it.
  if not isinstance(activation_string, six.string_types):
    return activation_string

  if not activation_string:
    return None

  act = activation_string.lower()
  if act == "linear":
    return None
  elif act == "relu":
    return nn.ReLU
  elif act == "gelu":
    return gelu
  elif act == "tanh":
    return torch.tanh
  else:
    raise ValueError("Unsupported activation: %s" % act)


def get_shape_list(tensor):
  """Returns a list of the shape of tensor, preferring static dimensions.

  Args:
    tensor: A tf.Tensor object to find the shape of.

  Returns:
    A list of dimensions of the shape of tensor. All static dimensions will
    be returned as python integers, and dynamic dimensions will be returned
    as tf.Tensor scalars.
  """
  #shape = tensor.shape.as_list()
  shape = tensor.size()

  non_static_indexes = []
  for (index, dim) in enumerate(shape):
    if dim is None:
      non_static_indexes.append(index)

  if not non_static_indexes:
    return shape
  else:
    print('something wrong with static shaping')
    assert False

  # dyn_shape = tf.shape(tensor)
  # for index in non_static_indexes:
  #   shape[index] = dyn_shape[index]
  # return shape


def gather_indexes(sequence_tensor, positions):
  """Gathers the vectors at the specific positions over a minibatch."""
  sequence_shape = get_shape_list(sequence_tensor)
  batch_size = sequence_shape[0]
  seq_length = sequence_shape[1]
  width = sequence_shape[2]

  flat_offsets = torch.reshape(
      torch.range(0, batch_size).int() * seq_length, (-1, 1))
  flat_positions = torch.reshape(positions + flat_offsets, (-1))
  flat_sequence_tensor = torch.reshape(sequence_tensor,
                                    (batch_size * seq_length, width))
  output_tensor = torch.gather(flat_sequence_tensor, flat_positions)
  output_tensor = torch.reshape(output_tensor, (batch_size, -1, width))
  return output_tensor


def split_heads(x, batch_size, seq_length, num_joints, num_attention_heads,
                model_depth):
  """Split the embedding vector for different heads for the spatial attention.

  Args:
    x: the embedding vector (batch_size, seq_len, num_joints, model_depth) or
      (batch_size, seq_len, model_depth)
    batch_size: the batch_size
    seq_length: the sequence length
    num_joints: the number of joints
    num_attention_heads: the number of attention heads
    model_depth: the model depth

  Returns:
    the split vector (batch_size, seq_len, num_heads, num_joints, depth) or
      (batch_size, num_heads, seq_len, depth)
  """
  depth = model_depth // num_attention_heads
  if len(x.get_shape().as_list()) == 4:
    # Input shape (batch_size, seq_len, num_joints, model_depth)
    x = torch.reshape(
        x, (batch_size, seq_length, num_joints, num_attention_heads, depth))
    return x.permute(0, 1, 3, 2, 4)
  elif len(x.get_shape().as_list()) == 3:
    # Input shape (batch_size, seq_len, model_depth)
    x = torch.reshape(x, (batch_size, seq_length, num_attention_heads, depth))
    return x.permute(0, 2, 1, 3)
  else:
    raise ValueError("Unsupported input tensor dimension.")


def scaled_dot_product_attention(q, k, v, mask):
  """The scaled dot product attention mechanism.

  Attn(Q, K, V) = softmax((QK^T+mask)/sqrt(depth))V.

  Args:
    q: the query vectors matrix (..., attn_dim, d_model/num_heads)
    k: the key vector matrix (..., attn_dim, d_model/num_heads)
    v: the value vector matrix (..., attn_dim, d_model/num_heads)
    mask: a mask for attention

  Returns:
    the updated encoding and the attention weights matrix
  """
  # matmul_qk = tf.matmul(
  #     q, k, transpose_b=True)  # (..., num_heads, attn_dim, attn_dim)
  matmul_qk = q @ k.transpose()

  # scale matmul_qk
  dk = torch.shape(k)[-1].float()
  scaled_attention_logits = matmul_qk / torch.sqrt(dk)

  # add the mask to the scaled tensor.
  if mask is not None:
    scaled_attention_logits += (mask * -1e9)

  # normalized on the last axis (seq_len_k) so that the scores add up to 1.
  attention_weights = nn.softmax(
      scaled_attention_logits, dim=-1)  # (..., num_heads, attn_dim, attn_dim)

  output = attention_weights @ v  # (..., num_heads, attn_dim, depth)

  return output, attention_weights
