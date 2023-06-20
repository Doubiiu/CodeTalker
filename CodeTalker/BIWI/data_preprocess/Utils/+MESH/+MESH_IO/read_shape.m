function S = read_shape(filename)
import MESH.MESH_IO.*
fprintf('Reading mesh...'); tic;
fname = strsplit(filename,'.');
if length(fname) > 1
    if strcmp(fname{end},'obj')
        [X,T] = readObj(filename);
    elseif strcmp(fname{end},'off')
        [X,T] = readOff(filename);
    else
        error('cannot read .%s file',fname{end});
    end
else % no input file extension
    if exist([filename,'.obj'],'file')
        [X,T] = readObj(filename);
    elseif exist([filename,'.off'],'file')
        [X,T] = readOff(filename);
    else
        error('file not found: %s\n',filename)
    end
end

S.surface.TRIV = double(T);
S.surface.X = X(:,1);
S.surface.Y = X(:,2);
S.surface.Z = X(:,3);
S.surface.VERT = X;
S.nf = size(T,1);
S.nv = size(X,1);
S.name = shape_name(filename);
t = toc; fprintf('done:%.4fs\n',t);

MESH.print_info(S);
end