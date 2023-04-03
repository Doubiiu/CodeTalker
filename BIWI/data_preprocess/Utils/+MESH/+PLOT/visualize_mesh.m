function [] = visualize_mesh(S,varargin)
default_param = load_MeshPlot_default_params(S);
% parse the inputs
param = parse_MeshPlot_params(default_param, varargin{:});

% plot the mesh
if param.IfShowFunc
    trimesh(S.surface.TRIV, S.surface.X, S.surface.Y, S.surface.Z, param.func, ...
        'FaceColor', param.FaceColor, 'EdgeColor', param.EdgeColor,'FaceAlpha', param.FaceAlpha);
else
    trimesh(S.surface.TRIV, S.surface.X, S.surface.Y, S.surface.Z, ...
        'FaceColor', param.FaceColor, 'EdgeColor', param.EdgeColor,'FaceAlpha', param.FaceAlpha);
end
axis equal; axis off;

% plot some landmarks on the mesh
if param.IfShowVtx
    hold on;
    vid = param.landmarks;
    scatter3(S.surface.X(vid),S.surface.Y(vid),S.surface.Z(vid),...
        param.Size_lmk, param.Col_lmk,'filled');
end

% plot some edges on the mesh
if param.IfShowEdge
    if ~isfield(S,'Elist'), S.Elist = MESH.get_edge_list(S); end
    if ~isempty(param.edgeID)
        edges = S.Elist(param.edgeID,:);
    end
    if ~isempty(param.edgeList)
        edges = param.edgeList;
    end
    vertex = S.surface.VERT';
    x = [ vertex(1,edges(:,1)); vertex(1,edges(:,2))];
    y = [ vertex(2,edges(:,1)); vertex(2,edges(:,2))];
    z = [ vertex(3,edges(:,1)); vertex(3,edges(:,2))];
    line(x,y,z, 'color', 'k', 'LineWidth',param.LineWidth);    
end
hold off; view(param.CameraPos);
title(param.Title, 'Interpreter','none');

end

