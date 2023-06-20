function patch = find_mesh_patches(M,nset,~)
nv = length(M.surface.X);
ind = zeros(nset,1);
vor = ones(nv,1); % vertex ind
source_id = 1;
geo = geodesics_to_all(M,source_id);
[~,index] = max(geo);
ind(1)=index;
geo = geodesics_to_all(M, index);
for i=1:(nset-1)
    [~,index] = max(geo);
    ind(i+1) = index;
    local_geo = geodesics_to_all(M,ind(i+1));
    vor(local_geo < geo) = (i+1);
    geo = min(geo,local_geo);
end

patch = cellfun(@(x) double(vor == x), num2cell(1:nset),'UniformOutput',false);
% plot the patches
if nargin > 2
    figure('Name','Mesh Patches');
    for i = 1:min(12,nset)
        subplot(3,4,i);
        plot_func_on_mesh(M,patch{i});
        title(num2str(i))
    end
end
end
%%
function [] = plot_func_on_mesh(S,f)
if nargin < 2
    trimesh(S.surface.TRIV, S.surface.X, S.surface.Y, S.surface.Z, ...
        'FaceColor','interp', 'EdgeColor', 'none','FaceAlpha',0.5); axis equal; axis off;
else
    trimesh(S.surface.TRIV, S.surface.X, S.surface.Y, S.surface.Z,f, ...
        'FaceColor','interp', 'EdgeColor', 'none','FaceAlpha',0.89); axis equal; axis off;
end
end