function writeObj(filename, mesh)

fid = fopen(filename,'wt');
if( fid==-1 ), error('Can''t open the file.'); end

vertex = [mesh.surface.X,mesh.surface.Y,mesh.surface.Z];
face = mesh.surface.TRIV;

% vertex position
fprintf(fid,'# nv = %d\n',size(vertex,1));
fprintf(fid, 'v %f %f %f\n', vertex');

% face 
fprintf(fid,'# nf = %d\n',size(face,1));
fprintf(fid, 'f %d %d %d\n', face');
fclose(fid);

end
