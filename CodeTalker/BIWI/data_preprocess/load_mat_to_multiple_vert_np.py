import os
import numpy as np
import scipy.io as sio

dir_name = 'BIWI_Process/data/'
subjects_list =['F1','F2','F3','F4','F5','F6','F7','F8','M1','M2','M3','M4','M5','M6']
sentences_list = ['e'+str(i).zfill(2) for i in range(1,41)]

for i_target in subjects_list:  
	for sentence in sentences_list:          
		target_dir = dir_name+i_target+'/vert/'+sentence+'/'
		if not os.path.exists(target_dir):
			print('Not found:',target_dir)
			continue
		target_file_list = os.listdir(target_dir)
		size = len(target_file_list)

		data_verts = []
		for i in range(1,size+1):
			target_file = target_dir+'frame_'+str(i).zfill(3)+'.mat'
			input_data = sio.loadmat(target_file)
			verts = input_data['VERT']
			if verts.shape[0] != 23370 or verts.shape[1] != 3:
				print('something wrong...')
			verts = np.reshape(verts,(-1,verts.shape[0]*verts.shape[1]))
			data_verts.append(verts)
		
		data_verts = np.array(data_verts)
		data_verts = np.squeeze(data_verts)
		# print(i_target+'_'+sentence+'.npy',data_verts.shape)
		np.save('vertices_npy/'+i_target+'_'+sentence+'.npy',data_verts)