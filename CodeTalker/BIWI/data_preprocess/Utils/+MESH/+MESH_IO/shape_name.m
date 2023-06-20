function mesh_name = shape_name(filename)
mesh_name = strsplit(filename,'\');
mesh_name = strsplit(mesh_name{end},'/');
mesh_name = strsplit(mesh_name{end},'.');
mesh_name = mesh_name{1};
end