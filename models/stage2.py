import torch
import torch.nn as nn
from models.lib.wav2vec import Wav2Vec2Model
from models.utils import init_biased_mask, enc_dec_mask, PeriodicPositionalEncoding
from base import BaseModel


class CodeTalker(BaseModel):
    def __init__(self, args):
        super(CodeTalker, self).__init__()
        """
        audio: (batch_size, raw_wav)
        template: (batch_size, V*3)
        vertice: (batch_size, seq_len, V*3)
        """
        self.args = args
        self.dataset = args.dataset
        self.audio_encoder = Wav2Vec2Model.from_pretrained(args.wav2vec2model_path)
        # wav2vec 2.0 weights initialization
        self.audio_encoder.feature_extractor._freeze_parameters()
        self.audio_feature_map = nn.Linear(768, args.feature_dim)
        # motion encoder
        self.vertice_map = nn.Linear(args.vertice_dim, args.feature_dim)
        # periodic positional encoding 
        self.PPE = PeriodicPositionalEncoding(args.feature_dim, period = args.period)
        # temporal bias
        self.biased_mask = init_biased_mask(n_head = 4, max_seq_len = 600, period=args.period)
        decoder_layer = nn.TransformerDecoderLayer(d_model=args.feature_dim, nhead=args.n_head, dim_feedforward=2*args.feature_dim, batch_first=True)        
        self.transformer_decoder = nn.TransformerDecoder(decoder_layer, num_layers=args.num_layers)
        # motion decoder
        self.feat_map = nn.Linear(args.feature_dim, args.face_quan_num*args.zquant_dim, bias=False)
        # style embedding
        self.learnable_style_emb = nn.Embedding(len(args.train_subjects.split()), args.feature_dim)

        self.device = args.device
        nn.init.constant_(self.feat_map.weight, 0)
        # nn.init.constant_(self.feat_map.bias, 0)

        if args.autoencoder == 'stage1_vocaset':
            from models.stage1_vocaset import VQAutoEncoder
        elif args.autoencoder == 'stage1_BIWI':
            from models.stage1_BIWI import VQAutoEncoder

        self.autoencoder = VQAutoEncoder(args)
        self.autoencoder.load_state_dict(torch.load(args.vqvae_pretrained_path)['state_dict'])
        for param in self.autoencoder.parameters():
            param.requires_grad = False


    def forward(self, audio, template, vertice, one_hot, criterion):
        # tgt_mask: :math:`(T, T)`.
        # memory_mask: :math:`(T, S)`.
        template = template.unsqueeze(1) # (1,1,V*3)

        # style embedding
        obj_embedding = self.learnable_style_emb(torch.argmax(one_hot, dim=1))
        obj_embedding = obj_embedding.unsqueeze(1)

        frame_num = vertice.shape[1]

        # audio feature extraction
        hidden_states = self.audio_encoder(audio, self.dataset, frame_num=frame_num).last_hidden_state
        if self.dataset == "BIWI":
            if hidden_states.shape[1]<frame_num*2:
                vertice = vertice[:, :hidden_states.shape[1]//2]
                frame_num = hidden_states.shape[1]//2
        hidden_states = self.audio_feature_map(hidden_states)

        # gt motion feature extraction
        feat_q_gt, _ = self.autoencoder.get_quant(vertice - template)
        feat_q_gt = feat_q_gt.permute(0,2,1)

        # autoregressive facial motion prediction with teacher-forcing
        vertice_emb = obj_embedding 
        style_emb = vertice_emb  
        vertice_input = torch.cat((template,vertice[:,:-1]), 1) # shift one position
        vertice_input = vertice_input - template
        vertice_input = self.vertice_map(vertice_input)
        vertice_input = vertice_input + style_emb
        vertice_input = self.PPE(vertice_input)
        tgt_mask = self.biased_mask[:, :vertice_input.shape[1], :vertice_input.shape[1]].clone().detach().to(device=self.device)
        memory_mask = enc_dec_mask(self.device, self.dataset, vertice_input.shape[1], hidden_states.shape[1])
        feat_out = self.transformer_decoder(vertice_input, hidden_states, tgt_mask=tgt_mask, memory_mask=memory_mask)
        feat_out = self.feat_map(feat_out)
        feat_out = feat_out.reshape(feat_out.shape[0], feat_out.shape[1]*self.args.face_quan_num, -1)
        
        # feature quantization
        feat_out_q, _, _ = self.autoencoder.quantize(feat_out)

        # feature decoding
        vertice_out = self.autoencoder.decode(feat_out_q)
        vertice_out = vertice_out + template

        # loss 
        loss_motion = criterion(vertice_out, vertice) # (batch, seq_len, V*3)
        loss_reg = criterion(feat_out, feat_q_gt.detach())

        return self.args.motion_weight*loss_motion + self.args.reg_weight*loss_reg, [loss_motion, loss_reg]



    def predict(self, audio, template, one_hot, one_hot2=None, weight_of_one_hot=None):
        template = template.unsqueeze(1) # (1,1, V*3)

        # style embedding
        obj_embedding = self.learnable_style_emb(torch.argmax(one_hot, dim=1))

        # style interpolation (optional)
        if one_hot2 is not None and weight_of_one_hot is not None:
            obj_embedding2 = self.learnable_style_emb(torch.argmax(one_hot2, dim=1))
            obj_embedding = obj_embedding * weight_of_one_hot + obj_embedding2 * (1-weight_of_one_hot)
        obj_embedding = obj_embedding.unsqueeze(1)

        # audio feature extraction
        hidden_states = self.audio_encoder(audio, self.dataset).last_hidden_state
        if self.dataset == "BIWI":
            frame_num = hidden_states.shape[1]//2
        elif self.dataset == "vocaset":
            frame_num = hidden_states.shape[1]
        hidden_states = self.audio_feature_map(hidden_states)

        # autoregressive facial motion prediction 
        for i in range(frame_num):
            if i==0:
                vertice_emb = obj_embedding # (1,1,feature_dim)
                style_emb = vertice_emb
                vertice_input = self.PPE(style_emb)
            else:
                vertice_input = self.PPE(vertice_emb)

            tgt_mask = self.biased_mask[:, :vertice_input.shape[1], :vertice_input.shape[1]].clone().detach().to(device=self.device)
            memory_mask = enc_dec_mask(self.device, self.dataset, vertice_input.shape[1], hidden_states.shape[1])
            feat_out = self.transformer_decoder(vertice_input, hidden_states, tgt_mask=tgt_mask, memory_mask=memory_mask)
            feat_out = self.feat_map(feat_out)

            feat_out = feat_out.reshape(feat_out.shape[0], feat_out.shape[1]*self.args.face_quan_num, -1)
            # predicted feature to quantized one
            feat_out_q, _, _ = self.autoencoder.quantize(feat_out)
            # quantized feature to vertice
            if i == 0:
                vertice_out_q = self.autoencoder.decode(torch.cat([feat_out_q, feat_out_q], dim=-1))
                vertice_out_q = vertice_out_q[:,0].unsqueeze(1)
            else:
                vertice_out_q = self.autoencoder.decode(feat_out_q)

            if i != frame_num - 1:
                new_output = self.vertice_map(vertice_out_q[:,-1,:]).unsqueeze(1)
                new_output = new_output + style_emb
                vertice_emb = torch.cat((vertice_emb, new_output), 1)


        # quantization and decoding
        feat_out_q, _, _ = self.autoencoder.quantize(feat_out)
        vertice_out = self.autoencoder.decode(feat_out_q)

        vertice_out = vertice_out + template
        return vertice_out
