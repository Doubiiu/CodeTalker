clear all; close all; 
%addpath(genpath('./MATLAB/'));
addpath('../Utils/');
thresh = 0.95;

errs_tot_0 = [];
errs_tot_1 = [];
errs_tot_2 = [];
errs_tot_3 = [];
tic

Data_set = 'TOSCA_Iso/';

if strcmp(Data_set,'FAUST_r/')   
    files_name= 'tr_reg_0';
    range = 80:98;
    end_f= 99;
elseif strcmp(Data_set,'SCAPE_r/')
    files_name= 'mesh0';
    range = 52:68;
    end_f=69;
else
   files_no = dir(['/home/abhishek/UnsupervisedFMapNet/Scr/Unsupervised_FMnet/Shapes/TOSCA_Iso/OFF/', '*.off']) ;
   range = [1:numel(files_no)];
end

dir_name = 'all_class_shot_4_30_8_sub_bs_10/';

for i = range
    
    if strcmp(Data_set,'TOSCA_Iso/')
        file1= files_no(i).name;
        file_cell=strsplit(file1, '.');
        file1= file_cell{1};
        
    else
        k1 = num2str(i);
    
        file1 = strcat(files_name, k1);
        tar_range = [i+1:end_f]
    end   
        target_off_fname = strcat('../Unsupervised_FMnet/Shapes/',Data_set,'/OFF/', file1);
        [X, T] = readOff(target_off_fname);
        
        
        S1 = load(['../../Data/GeoDistanceMatrix/', Data_set,'/' file1, '.mat']);           
        S1.surface.nv = size(X,1);    
        S1.VTS = load(strcat(['../Unsupervised_FMnet/Shapes/', Data_set,'/corres/', file1, '.vts']));   
    %S1.sqr_area = sqrt(trace(massmatrix([S1.surface.X S1.surface.Y S1.surface.Z], S1.surface.TRIV)));
        S1.sqr_area = S1.SQRarea;    
    
    for j= i+1:end_f
        k2 = num2str(j);
       
        file2 = strcat(files_name, k2);
        files_name= 'tr_reg_0';
        S2 = load(['../../Data/GeoDistanceMatrix/', Data_set, '/', file2, '.mat']);
        S2.VTS = load(strcat(['../Unsupervised_FMnet/Shapes/', Data_set, '/corres/', file2, '.vts']));
        
        
        load(strcat('../Unsupervised_FMnet/Matches/', Data_set, dir_name, '/4000-/', files_name, k1, '-',files_name, k2,'.mat')); 
        matches_0 = squeeze(matches)';
%         
        load(strcat('../Unsupervised_FMnet/Matches/', Data_set, dir_name,'/16000-/', files_name, k1, '-',files_name, k2,'.mat')); 
        matches_1 = squeeze(matches)';
 
        load(strcat('../Unsupervised_FMnet/Matches/', Data_set, dir_name,'/24000-/', files_name, k1, '-',files_name, k2,'.mat')); 
        matches_2 = squeeze(matches)';
        
        load(strcat('../Unsupervised_FMnet/Matches/', Data_set, dir_name,'/30000-/', files_name, k1, '-',files_name, k2,'.mat')); 
        matches_3 = squeeze(matches)';
                      
        ind_0 = sub2ind([S1.surface.nv, S1.surface.nv], S1.VTS, matches_0(S2.VTS));
        errs_0 = S1.Gamma(ind_0)/S1.SQRarea;
        
        ind_1 = sub2ind([S1.surface.nv, S1.surface.nv], S1.VTS, matches_1(S2.VTS));
        errs_1 = S1.Gamma(ind_1)/S1.SQRarea;
%         
        ind_2 = sub2ind([S1.surface.nv, S1.surface.nv], S1.VTS, matches_2(S2.VTS));
        errs_2 = S1.Gamma(ind_2)/S1.SQRarea;
%         
        ind_3 = sub2ind([S1.surface.nv, S1.surface.nv], S1.VTS, matches_3(S2.VTS));
        errs_3 = S1.Gamma(ind_3)/S1.SQRarea;
        
        errs_tot_0 = [errs_tot_0 ; errs_0];
        errs_tot_1 = [errs_tot_1 ; errs_1];
        errs_tot_2 = [errs_tot_2 ; errs_2];
        errs_tot_3 = [errs_tot_3 ; errs_3];
    end
    i
end

t = toc
errs_vec = [mean(errs_tot_0), mean(errs_tot_1), mean(errs_tot_2), mean(errs_tot_3)];
figure(20);
plot(errs_vec)
errs_vec

xlabel('no of mini batch iterations (times 10k) ','FontSize',10);
ylabel('Geodesic error','FontSize',10);
title('F remesh with 50 eigen-vec and 4 layers (452 times 452)', 'FontSize',10);
save([dir_name, '.mat'], 'errs_vec')
%subplot(1,2,1);
