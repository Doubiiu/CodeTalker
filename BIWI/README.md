## Dataset

Request the BIWI dataset from [Biwi 3D Audiovisual Corpus of Affective Communication](https://data.vision.ee.ethz.ch/cvl/datasets/b3dac2.en.html). Download all the compressed files, decompress them, and put the `rigid_scans`, `faces` and `videos` into `BIWI/`.

**Description**

14 persons, 40 English sentences, each of length 3~8 seconds. The face meshes are captured at 25 fps and the audio is captured with a sample rate of 44.1kHz. The dataset contains the following subfolders:

- 'rigid_scans' contains the sequences where the speakers just rotated their head around, with a neutral expression. In this folder there are also the personalised templates (.obj) and textures (.png) files. Each face scan has 23370 vertices. 

- 'faces' contains the tracked facial geometries. In each subject's folder, there is one .tar and one .tgz file for each sequence: the .tar archives contain a .vl file for each frame, i.e., a binary file containing the 3D coordinates of each vertex in the generic face template, after the global rotation and translation were removed.

- 'videos' contains videos (.flv) of the rendered 3D geometries and original audio (sampling rate: 44.1kHz). 

**Data Preprocessing**

Here we adopt a verbose way to preprocess the data partially using Matlab scripts, you may use your own script in Python to do the same thing with following sequential steps:
```
cd BIWI/
```

1. Read the .vl files, normalize the coordinates and store them in .mat files (e.g., F1/vert/e01/frame_001.mat). Each .mat stores the 3D coordinates for one frame. (Optional) It will also out the .off files (e.g., F1/off/e01/frame_001.off) for debugging and visualization purpose. [Note: please define `targetpath` to your own path.]:
```
run("data_preprocess/creatDataset_BIWI.m")
```

2. Read the template .obj files, normalize the coordinates and store them in .mat/.off files. [Note: please define `targetpath` to your own path.]:
```
run("data_preprocess/process_BIWI_template.m")
```

3. Read the template .mat files, and store them in .pkl files into `templates.pkl`:
```
python data_preprocess/load_mat_to_template_pkl.py 
```

4. Convert the .mat files to .npy files (e.g., F2_e01.npy). Each .npy (associated with the shape of [num_frame, 23370*3]) stores the 3D coordinates for one sentence for each person and will be saved into `vertices_npy/`:
```
python data_preprocess/load_mat_to_multiple_vert_np.py
```

5. Install ffmpeg, extract the audios from .flv video files and save them into `wav/`:
```
python data_preprocess/video2audio.py
```

You can obtain the preprocessed files (`templates.pkl`, `vertices_npy/` and `wav/`) for training, and note that we have already provided the `BIWI.ply` file.