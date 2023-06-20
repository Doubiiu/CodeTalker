addpath('+MESH');
addpath('+MESH/+MESH_IO')
addpath('+MESH/+PLOT');
addpath('+MESH/+SEG');

mesh_dir = '+MESH/OFF_Data/';
s1_name = 'tr_reg_003.off';
cache_dir = 'cache_TEST';

S = MESH.preprocess([mesh_dir,s1_name], 'cacheDir',cache_dir,...
 'IfComputeLB',true, 'numEigs',100,...
 'IfComputeGeoDist',false,...
 'IfComputeNormals',true);



for i = 2:15
   param.func = S.evecs(:, i);
   subplot(3, 5, i)
   MESH.PLOT.visualize_mesh(S, param)
   title(sprintf('%dth function of LB eigenB', i-1))
   view([0 90])
end