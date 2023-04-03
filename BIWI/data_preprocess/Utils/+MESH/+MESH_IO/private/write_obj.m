function write_obj(path, filename, vertex, face, options)

% write_off - write a mesh to an OBJ file
%
%   write_obj(filename, vertex, face, options)
%
%   vertex must be of size [n,3]
%   face must be of size [p,3]
%
%   Copyright (c) 2004 Gabriel Peyr

if nargin<0
    options.null = 0;
end

if size(vertex,2)~=3
    vertex=vertex';
end
if size(vertex,2)~=3
    error('vertex does not have the correct format.');
end


if size(face,2)~=3
    face=face';
end
if size(face,2)~=3
    error('face does not have the correct format.');
end

fid = fopen([path, filename],'wt');
if( fid==-1 )
    error('Can''t open the file.');
    return;
end

object_name = filename(1:end-4);

fprintf(fid, '# write_obj (c) 2004 Gabriel Peyr\n');
if isfield(options, 'nm_file')
    fprintf(fid, 'mtllib ./%s.mtl\n', object_name);
end

%object_name = 'curobj';

fprintf(fid, ['g\n# object ' object_name ' to come\n']);

% vertex position
fprintf(fid, '# %d vertex\n', size(vertex,1));
fprintf(fid, 'v %f %f %f\n', vertex');

% use mtl
fprintf(fid, ['g ' object_name '_export\n']);
mtl_bump_name = 'material_0';
fprintf(fid, ['usemtl ' mtl_bump_name '\n']);

% face
fprintf(fid, '# %d faces\n', size(face,1));
if isfield(options, 'face_texcorrd')
    face_texcorrd = [face(:,1), options.face_texcorrd(:,1), face(:,2), options.face_texcorrd(:,2), face(:,3), options.face_texcorrd(:,3)];
else
    face_texcorrd = [face(:,1), face(:,1), face(:,2), face(:,2), face(:,3), face(:,3)];
end
fprintf(fid, 'f %d/%d %d/%d %d/%d\n', face_texcorrd');

% vertex texture
if isfield(options, 'nm_file')
    fprintf(fid, 'vt %f %f\n', options.object_texture');
else
    % create dummy vertex texture
    vertext = vertex(:,1:2)*0 - 1;
    % vertex position
    fprintf(fid, '# %d vertex texture\n', size(vertext,1));
    fprintf(fid, 'vt %f %f\n', vertext');
end

fclose(fid);


% MTL generation
if isfield(options, 'nm_file')
    mtl_file = [object_name '.mtl'];
    fid = fopen([path, mtl_file],'wt');
    if( fid==-1 )
        error('Can''t open the file.');
        return;
    end
    
    Ka = [0.2 0.2 0.2];
    Kd = [1 1 1];
    Ks = [1 1 1];
    Tr = 1;
    Ns = 0;
    illum = 2;
    
    fprintf(fid, '# write_obj (c) 2004 Gabriel Peyr\n');
    
    fprintf(fid, 'newmtl %s\n', mtl_bump_name);
    fprintf(fid, 'Ka  %f %f %f\n', Ka);
    fprintf(fid, 'Kd  %f %f %f\n', Kd);
    fprintf(fid, 'Ks  %f %f %f\n', Ks);
    fprintf(fid, 'Tr  %d\n', Tr);
    fprintf(fid, 'Ns  %d\n', Ns);
    fprintf(fid, 'illum %d\n', illum);
    fprintf(fid, 'map_Kd %s\n', options.nm_file);
    
    fprintf(fid, '#\n# EOF\n');

    fclose(fid);
end