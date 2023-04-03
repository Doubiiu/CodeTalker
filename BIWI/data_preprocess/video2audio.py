import os
from subprocess import call

video_dir = 'videos/'
subjects_list = ['F1','F2','F3','F4','F5','F6','F7','F8','M1','M2','M3','M4','M5','M6']
sentences_list = ['e'+str(i).zfill(2) for i in range(1,41)]

for i_target in subjects_list:  
    for sentence in sentences_list:          
        target_video = video_dir+i_target+'_'+sentence+'.flv'
        if not os.path.exists(target_video):
            print('Not found:',target_video)
            continue
        out_wav_name = 'wav/'+i_target+'_'+sentence+'.wav'
        print(out_wav_name)
        cmd = ('ffmpeg' + ' -i {0} -f wav -ar {1} {2}'.format(
            target_video, 44100, out_wav_name)).split()
        call(cmd)