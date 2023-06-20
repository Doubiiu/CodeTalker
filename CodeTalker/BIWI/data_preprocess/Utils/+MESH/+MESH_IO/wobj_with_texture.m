% Output M to an obj file
% uv - texture coordinates.
% iname - filename for texture image
% fname - output file name
function wobj_with_texture(M, uv, iname, fname)

options.object_texture = uv;
options.nm_file = iname;

[pathstr,name] = fileparts(fname);
write_obj([pathstr,'/'], [name '.obj'], M.surface.VERT, M.surface.TRIV, options);
end