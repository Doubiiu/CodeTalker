## **CodeTalker**

Official PyTorch implementation for the paper:

> **CodeTalker: Speech-Driven 3D Facial Animation with Discrete Motion Prior**, ***CVPR 2023***.
>
> Jinbo Xing, Menghan Xia, Yuechen Zhang, Xiaodong Cun, Jue Wang, Tien-Tsin Wong
>
> <a href='https://arxiv.org/abs/2301.02379'><img src='https://img.shields.io/badge/arXiv-2301.02379-red'></a> <a href='https://doubiiu.github.io/projects/codetalker/'><img src='https://img.shields.io/badge/Project-Video-Green'></a> <a href='https://colab.research.google.com/github/Doubiiu/CodeTalker/blob/main/demo.ipynb'><img src='https://img.shields.io/badge/Demo-Open in Colab-blue'></a>

<p align="center">
<img src="figure.png" width="75%"/>
</p>

> We propose CodeTalker by casting speech-driven facial animation as a code query task in a finite proxy space of the learned codebook. Given the raw audio and a 3D neutral face template, our CodeTalker can produce vivid and realistic 3D facial motions with subtle expressions and accurate lip movements. 

## **Changelog**
- 2023.06.16 Provide a Colab online demo.
- 2023.04.03 Release code and model weights!


<!-- ## **TODO**

- [ ] Provide online demo. -->

## **Environment**
- Linux
- Python 3.6+
- Pytorch 1.9.1
- CUDA 11.1 (GPU with at least 11GB VRAM)

Other necessary packages:
```
pip install -r requirements.txt
```
- ffmpeg
- [MPI-IS/mesh](https://github.com/MPI-IS/mesh)

IMPORTANT: Please make sure to modify the `site-packages/torch/nn/modules/conv.py` file by commenting out the `self.padding_mode != 'zeros'` line to allow for replicated padding for ConvTranspose1d as shown [here](https://github.com/NVIDIA/tacotron2/issues/182).

## **Dataset Preparation**
### VOCASET
Request the VOCASET data from [https://voca.is.tue.mpg.de/](https://voca.is.tue.mpg.de/). Place the downloaded files `data_verts.npy`, `raw_audio_fixed.pkl`, `templates.pkl` and `subj_seq_to_idx.pkl` in the folder `vocaset/`. Download "FLAME_sample.ply" from [voca](https://github.com/TimoBolkart/voca/tree/master/template) and put it in `vocaset/`. Read the vertices/audio data and convert them to .npy/.wav files stored in `vocaset/vertices_npy` and `vocaset/wav`:
```
cd vocaset
python process_voca_data.py
```

### BIWI

Follow the [`BIWI/README.md`](BIWI/README.md) to preprocess BIWI dataset and put .npy/.wav files into `BIWI/vertices_npy` and `BIWI/wav`, and the `templates.pkl` into `BIWI/`.


## **Demo**
Download the pretrained models from [biwi_stage1.pth.tar](https://drive.google.com/file/d/1FSxey5Qug3MgAn69ymwFt8iuvwK6u37d/view?usp=sharing) & [biwi_stage2.pth.tar](https://drive.google.com/file/d/1gSNo9KYeIf6Mx3VYjRXQJBcg7Qv8UiUl/view?usp=sharing) and [vocaset_stage1.pth.tar](https://drive.google.com/file/d/1RszIMsxcWX7WPlaODqJvax8M_dnCIzk5/view?usp=sharing) & [vocaset_stage2.pth.tar](https://drive.google.com/file/d/1phqJ_6AqTJmMdSq-__KY6eVwN4J9iCGP/view?usp=sharing). Put the pretrained models under `BIWI` and `VOCASET` folders, respectively. Given the audio signal,

- to animate a mesh in FLAME topology, run: 
	```
	sh scripts/demo.sh vocaset
	```
- to animate a mesh in BIWI topology, run: 
	```
	sh scripts/demo.sh BIWI
	```
	This script will automatically generate the rendered videos in the `demo/output` folder. You can also put your own test audio file (.wav format) under the `demo/wav` folder and specify the arguments in `DEMO` section of `config/<dataset>/demo.yaml` accordingly (e.g., `demo_wav_path`, `condition`, `subject`, etc.).

## **Training / Testing**

The training/testing operation shares a similar command:
```
sh scripts/<train.sh|test.sh> <exp_name> config/<vocaset|BIWI>/<stage1|stage2>.yaml <vocaset|BIWI> <s1|s2>
```
Please replace `<exp_name>` with your own experiment name, `<vocaset|BIWI>` by the name of your target dataset, i.e., `vocaset` or `BIWI`. Change the `exp_dir` in both `scripts/train.sh` and `scripts/test.sh` if needed. We just take an example for default commands below.

### **Training for Discrete Motion Prior**

```
sh scripts/train.sh CodeTalker_s1 config/vocaset/stage1.yaml vocaset s1
```

### **Training for Speech-Driven Motion Synthesis**
Make sure the paths of pre-trained models are correct, i.e., `vqvae_pretrained_path` and `wav2vec2model_path` in `config/<vocaset|BIWI>/stage2.yaml`.
```
sh scripts/train.sh CodeTalker_s2 config/vocaset/stage2.yaml vocaset s2
```

### **Testing**
```
sh scripts/test.sh CodeTalker_s2 config/vocaset/stage2.yaml vocaset s2
```

## **Visualization with Audio**
Modify the paths in `scripts/render.sh` and run: 
```
sh scripts/render.sh
```

## **Evaluation on BIWI**
We provide the reference code for Lip Vertex Error & Upper-face Dynamics Deviation. Remember to change the paths in `scripts/cal_metric.sh`, and run:
```
sh scripts/cal_metric.sh
```
## **Play with Your Own Data**
###  Data Preparation

- Create the dataset directory `<dataset_dir>` in `CodeTalker` directory. 

- Place your vertices data (.npy files) and audio data (.wav files)  in `<dataset_dir>/vertices_npy` and `<dataset_dir>/wav` folders, respectively. 

- Save the templates of all subjects to a `templates.pkl` file and put it in `<dataset_dir>`, as done for BIWI and vocaset dataset. Export an arbitary template to .ply format and put it in `<dataset_dir>/`.

### Training, Testing & Visualization

- Create the corresponding config files in `config/<dataset_dir>` and modify the arguments in the config files.

- Check all the code segments releated to dataset information.

- Following the training/testing/visualization pipeline as done for BIWI and vocaset dataset.




## **Citation**

If you find the code useful for your work, please star this repo and consider citing:

```
@inproceedings{xing2023codetalker,
  title={Codetalker: Speech-driven 3d facial animation with discrete motion prior},
  author={Xing, Jinbo and Xia, Menghan and Zhang, Yuechen and Cun, Xiaodong and Wang, Jue and Wong, Tien-Tsin},
  booktitle={Proceedings of the IEEE/CVF Conference on Computer Vision and Pattern Recognition},
  pages={12780--12790},
  year={2023}
}
```
## **Notes**
1. Although our codebase allows for training with multi-GPUs, we did not test it and just hardcode the training batch size as one. You may need to change the `data_loader` if needed.


## **Acknowledgement**
We heavily borrow the code from
[FaceFormer](https://github.com/EvelynFan/FaceFormer),
[Learn2Listen](https://github.com/RenYurui/PIRender), and
[VOCA](https://github.com/TimoBolkart/voca). Thanks
for sharing their code and [huggingface-transformers](https://github.com/huggingface/transformers/blob/main/src/transformers/models/wav2vec2/modeling_wav2vec2.py) for their wav2vec2 implementation. We also gratefully acknowledge the ETHZ-CVL for providing the [B3D(AC)2](https://data.vision.ee.ethz.ch/cvl/datasets/b3dac2.en.html) dataset and MPI-IS for releasing the [VOCASET](https://voca.is.tue.mpg.de/) dataset. Any third-party packages are owned by their respective authors and must be used under their respective licenses.

## **Related Work**
- [StyleHEAT: One-Shot High-Resolution Editable Talking Face Generation via Pre-trained StyleGAN (ECCV 2022)](https://github.com/FeiiYin/StyleHEAT)
- [SadTalker: Learning Realistic 3D Motion Coefficients for Stylized Audio-Driven Single Image Talking Face Animation (CVPR 2023)](https://github.com/Winfredy/SadTalker)
- [MetaPortrait: Identity-Preserving Talking Head Generation with Fast Personalized Adaptation (CVPR 2023)](https://github.com/Meta-Portrait/MetaPortrait)
- [DPE: Disentanglement of Pose and Expression for General Video Portrait Editing (CVPR 2023)](https://github.com/Carlyx/DPE)
- [MMFace4D: A Large-Scale Multi-Modal 4D Face Dataset for Audio-Driven 3D Face Animation (arXiv 2023)](https://arxiv.org/abs/2303.09797)
