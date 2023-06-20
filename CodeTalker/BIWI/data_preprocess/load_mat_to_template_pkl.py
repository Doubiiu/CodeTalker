import scipy.io as sio
import pickle

dir_name = 'BIWI_Process/template/vert/'
subjects_list = ['F1','F2','F3','F4','F5','F6','F7','F8','M1','M2','M3','M4','M5','M6']
templates = {}
for i_target in subjects_list:             
    target_file = dir_name + i_target +'.mat' 
    input_data = sio.loadmat(target_file)        
    verts = input_data['VERT']
    templates[i_target] = verts

f = open('templates.pkl','wb')
pickle.dump(templates,f)
