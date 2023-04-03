function [S1_vt, S2_vt] = visualize_pMap_using_texture(T12, S1, S2, B1, B2, save_path,IFplotSrc)
B2_inv = pinv(B2);
B1_inv = pinv(B1);
% T12: maps S1 -> S2, n1-dim vector
n1 = length(S1.surface.X);
n2 =  length(S2.surface.X);
P21 = sparse(1:n1,T12, ones(1,n1), n1, n2); % n1-by-n2 matrix, maps S2 -> S1
C21 = B1_inv*P21*B2; % k1-by-k2 matrix, maps S2 -> S1
P21 = B1*C21*B2_inv;

% % convert pMap to fMap first, then find the soft correspondence matrix
% C21_new = B1\B2(T12,:);
% % C21_new = mat_projection(C21_new);
% P21_new = B1*C21_new*B2_inv;
%%  visualization: P21 for texture transfering
cols = [1 2 3];
texture_im = 'texture.jpg';
X2 = S2.surface.VERT;
[~,ic] = sort(std(X2),'descend');

S2_vt = MESH.MESH_IO.generate_tex_coords(X2(:,ic), cols(1), cols(2), 1);

if nargin < 6, save_path = './'; end

S1_name = 'target';
S2_name = 'source';
if isfield(S1,'name')
    S1_name = [S1_name,'_', S1.name];
end

if isfield(S2,'name')
    S2_name = [S2_name,'_', S2.name];
end

if nargin > 6
% Source mesh
MESH.MESH_IO.wobj_with_texture(S2, S2_vt, texture_im, [save_path, S2_name]);
end
S1_vt = P21*S2_vt;
% Target mesh: 
MESH.MESH_IO.wobj_with_texture(S1, P21*S2_vt, texture_im, [save_path,S1_name]);
% MESH_IO.wobj_with_texture(S1, P21_new*S2_vt, texture_im, [save_path,S1_name,'_fMap']);

end


function C = mat_projection(W)
n1 = size(W,1);
n2 = size(W,2);
[s,~,d] = svd(W);
C = s*eye(n1,n2)*d';
end