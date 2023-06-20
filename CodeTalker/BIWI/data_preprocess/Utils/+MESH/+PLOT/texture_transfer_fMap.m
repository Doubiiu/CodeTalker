function [] = texture_transfer_fMap(C21, S2, S1, B2, B1, save_path)
P21 = B1*C21*pinv(B2);
%%  visualization: P21 for texture transfering
cols = [1 2 3];
texture_im = 'texture.jpg';
S2_vt = MESH_IO.generate_tex_coords(S2.surface.VERT, cols(1), cols(2), 1);

if nargin < 6, save_path = './'; end

S1_name = 'target';
S2_name = 'source';
if isfield(S1,'name')
    S1_name = [S1_name,'_', S1.name];
end

if isfield(S2,'name')
    S2_name = [S2_name,'_', S2.name];
end

% Source mesh
MESH_IO.wobj_with_texture(S2, S2_vt, texture_im, [save_path, S2_name]);

% Target mesh: 
MESH_IO.wobj_with_texture(S1, P21*S2_vt, texture_im, [save_path,S1_name]);
% MESH_IO.wobj_with_texture(S1, P21_new*S2_vt, texture_im, [save_path,S1_name,'_fMap']);

end


function C = mat_projection(W)
n1 = size(W,1);
n2 = size(W,2);
[s,~,d] = svd(W);
C = s*eye(n1,n2)*d';
end