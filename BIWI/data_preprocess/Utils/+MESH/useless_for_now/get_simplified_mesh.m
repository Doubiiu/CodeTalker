function [S,f_c2s,f_s2c] = get_simplified_mesh(S1,num_faces,num_Eigs)

F = S1.surface.TRIV;
V = S1.surface.VERT;
[mF,mV] = reducepatch(F,V,num_faces);

S.surface.X = mV(:,1);
S.surface.Y = mV(:,2);
S.surface.Z = mV(:,3);
S.surface.VERT = mV;
S.surface.TRIV = mF;
S.nv = size(mV,1);
S.nf = size(mF,1);

if nargin > 2
    S = compute_laplacian_basis(S,num_Eigs);
end
if isfield(S1,'name')
    if S.nv < 1e3
        S.name = [S1.name,'_',num2str(S.nv)];
    else
        S.name = [S1.name,'_',num2str(floor(S.nv/1e3)),'k'];
    end
end

f_c2s = knnsearch(S.surface.VERT,S1.surface.VERT);
f_s2c = knnsearch(S1.surface.VERT,S.surface.VERT);
% figure;
% subplot(1,2,1); visualize_map_colors_with_coverage(S,S1,f_s2c); title('Simplified to Complete')
% subplot(1,2,2); visualize_map_colors_with_coverage(S1,S,f_c2s); title('Complete to Simplified')
end