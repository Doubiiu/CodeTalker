function render_map(S1,S2,map,samples,varargin)
default_param = load_MeshPlot_default_params(S1);
param = parse_MeshPlot_params(default_param, varargin{:});

xdiam = param.MeshSepDist(1)*(max(S2.surface.X)-min(S2.surface.X));
ydiam = param.MeshSepDist(2)*(max(S2.surface.Y)-min(S2.surface.Y));
zdiam = param.MeshSepDist(3)*(max(S2.surface.Z)-min(S2.surface.Z));
%%
[S1_col,S2_col]= get_mapped_face_color_withNaN(S1,S2,map);


[~,new_X1] = MESH.PLOT.render_mesh(S1,'MeshVtxCol',S1_col,varargin{:});
axis equal; axis off; hold on;

[~,new_X2] = MESH.PLOT.render_mesh(S2,'MeshVtxCol',S2_col,...
    'VtxPos',S2.surface.VERT + repmat([xdiam,ydiam,zdiam],S2.nv,1),...
    varargin{:});
axis equal; axis off; hold on;

if (~isempty(samples))
    target_samples = map(samples);
    
    Xstart = new_X1(samples,1)'; Xend = new_X2(target_samples,1)';
    Ystart = new_X1(samples,2)'; Yend = new_X2(target_samples,2)';
    Zstart = new_X1(samples,3)'; Zend = new_X2(target_samples,3)';
    
    Colors = S1_col;
    ColorSet = Colors(samples,:);
    set(gca, 'ColorOrder', ColorSet);
    plot3([Xstart; Xend], [Ystart; Yend], [Zstart; Zend],'LineWidth',1); hold off;
end
end

function [S1_col,S2_col]= get_mapped_face_color_withNaN(S1,S2,map,IFaddcoverage)
if nargin < 4
    IFaddcoverage = 0;
end
col_nan = [0.05,0.05,0.05];


g1 = S2.surface.X;
g2 = S2.surface.Y;
g3 = S2.surface.Z;

g1 = normalize_function(0,1,g1);
g2 = normalize_function(0,1,g2);
g3 = normalize_function(0,1,g3);

ind = find(~isnan(map));

f1 = col_nan(1)*ones(length(map),1);
f2 = col_nan(2)*ones(length(map),1);
f3 = col_nan(3)*ones(length(map),1);

f1(ind) = g1(map(ind));
f2(ind) = g2(map(ind));
f3(ind) = g3(map(ind));
S1_col = [f1,f2,f3]; % S1 face color f
S2_col = [g1,g2,g3]; % S2 face color g

if IFaddcoverage
    n2 = size(S2.surface.X,1);
    mask = zeros(n2,1);
    mask(unique(map)) = 1;
    S2_col = [mask.*g1, mask.*g2, mask.*g3];
end

end