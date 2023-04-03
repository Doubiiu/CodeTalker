ujfunction [] = visualize_multiMaps_colors(S1,S2,all_T12,all_titles,varargin)
default_param = load_MeshMapPlot_default_params();
param = parse_MeshMapPlot_params(default_param, varargin{:});
camera_pos = param.CameraPos;

num_maps = length(all_T12)+1;
if isempty(all_titles)
    all_titles = arrayfun(@num2str,1:num_maps,'un',0);
else
    if length(all_titles) ~= length(all_T12)
        error('Input maps and titles does not match.');
    end
end
X1 = S1.surface.X; Y1 = S1.surface.Y; Z1 = S1.surface.Z;
X2 = S2.surface.X; Y2 = S2.surface.Y; Z2 = S2.surface.Z;

% set up the overlay direction and distance
xdiam = param.MeshSepDist*(max(S2.surface.X)-min(S2.surface.X));
ydiam = param.MeshSepDist*(max(S2.surface.Y)-min(S2.surface.Y));
zdiam = param.MeshSepDist*(max(S2.surface.Z)-min(S2.surface.Z));
[xdiam, ydiam, zdiam] = set_overlay_axis(xdiam, ydiam, zdiam, param.OverlayAxis);


subplot(1,1+num_maps,1);
g_col = set_mesh_color(S2);
trimesh(S2.surface.TRIV, X2, Y2, Z2, ...
    'FaceVertexCData', g_col,...
    'FaceColor', param.FaceColor,...
    'FaceAlpha', param.Alpha2,...
    'EdgeColor', param.EdgeColor);
axis equal; axis off; view(camera_pos); title('Target');

% visualize all maps
for iMap = 1:length(all_T12)
    
    subplot(1,1+num_maps,1+iMap);
    T = all_T12{iMap};
    
    cov = 100*length(unique(T(~isnan(T))))/S2.nv; % coverage rate
    [f1,f2,f3] = get_fetched_color(T,g_col,param);
    trimesh(S1.surface.TRIV, X1 + iMap*xdiam, Y1+iMap*ydiam, Z1+iMap*zdiam, ...
        'FaceVertexCData', [f1, f2, f3],...
        'FaceColor',param.FaceColor,...
        'FaceAlpha',param.Alpha1,...
        'EdgeColor',param.EdgeColor);
    axis equal; axis off; view(camera_pos);
    title({all_titles{iMap}, ['cov = ',num2str(cov,'%.2f'),'%']});
end




end

