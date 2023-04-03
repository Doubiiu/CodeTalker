function [] = plot_mesh_patches(S,region_in,ifplot)
get_region_indicator = @(seg_id) cellfun(@(i) seg_id == i, num2cell(unique(seg_id)),'UniformOutput',false);
if iscell(region_in)
    if size(region_in,2) == 1
        region = region_in';
    elseif size(region_in,1) == 1
        region = region_in;
    end
else % input is a vector: region id
    region = get_region_indicator(region_in)';
end
base_col = ...
    [102   194   165;
    252   141    98;
    141   160   203;
    231   138   195;
    166   216    84;
    255   217    47;
    229   196   148;
    179   179   179]/255;

num_base_col = size(base_col,1);
c_id = sum(cell2mat(cellfun(@(i,f) i*f,num2cell(1:length(region)),region,'UniformOutput',false)),2);

% generate colors: convex combinations of the base colors
% num_patch = length(region);
% if num_patch <= num_base_col
%     v_col = base_col(c_id,:);
% else
%     tmp = rand(num_patch - num_base_col,num_base_col);
%     new_base_col = [eye(num_base_col);tmp./sum(tmp,2)]*base_col;
%     v_col = new_base_col(c_id,:);
% end

v_col = base_col(mod(c_id,num_base_col)+1,:);
trimesh(S.surface.TRIV, S.surface.X, S.surface.Y, S.surface.Z,'FaceVertexCData',v_col,...
    'FaceColor','flat', 'EdgeColor', 'none','FaceAlpha',0.95); axis equal; axis off;

if nargin > 2
    figure;
    for i = 1:length(region)
        subplot(2,ceil(length(region)/2),i); plot_func_on_mesh(S,region{i}); title(num2str(i));
    end
end
end