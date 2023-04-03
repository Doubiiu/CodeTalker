function visualize_map_lines(S1,S2,map_12,samples,para_in)
% plot two mesh in the same coordinate
a = 1.5;
overlay_axis = 'x';

if nargin > 4
    if isfield(para_in,'plot')
        para = para_in.plot;
    else
        para = para_in;
    end
    
    if isfield(para,'fig_dist')
        a = para.fig_dist;
    end
    
    if isfield(para,'overlay_axis')
        overlay_axis = para.overlay_axis;
    end
end

xdiam = a*(max(S2.surface.X)-min(S2.surface.X));
ydiam = a*(max(S2.surface.Y)-min(S2.surface.Y));
zdiam = a*(max(S2.surface.Z)-min(S2.surface.Z));

switch overlay_axis
    case 'x'
        ydiam = 0; zdiam = 0;
    case 'y'
        xdiam = 0; zdiam = 0;
    case 'z'
        xdiam = 0; ydiam = 0;
    otherwise
        error('invalid overlay_axis type')
end
%%
g1 = S2.surface.X;
g2 = S2.surface.Y;
g3 = S2.surface.Z;

g1 = normalize_function(0,1,g1);
g2 = normalize_function(0,1,g2);
g3 = normalize_function(0,1,g3);

f1 = g1(map_12);
f2 = g2(map_12);
f3 = g3(map_12);

X1 = S1.surface.X; Y1 = S1.surface.Y; Z1 = S1.surface.Z;
X2 = S2.surface.X; Y2 = S2.surface.Y; Z2 = S2.surface.Z;

% plot semi-transparent meshes
trimesh(S1.surface.TRIV, X1, Y1, Z1, ...
    'FaceVertexCData', [f1 f2 f3], 'FaceColor','interp', ...
    'FaceAlpha', 0.6, 'EdgeColor', 'none');
axis equal; axis off; hold on;


trimesh(S2.surface.TRIV, X2 + xdiam, Y2 + ydiam, Z2 + zdiam, ...
    'FaceVertexCData', [g1 g2 g3], 'FaceColor','interp', ...
    'FaceAlpha', 0.6, 'EdgeColor', 'none'); 
axis equal; axis off; hold on;

if (~isempty(samples))
    target_samples = map_12(samples);
    
    Xstart = X1(samples)'; Xend = X2(target_samples)';
    Ystart = Y1(samples)'; Yend = Y2(target_samples)';
    Zstart = Z1(samples)'; Zend = Z2(target_samples)';
    
    Xend = Xend + xdiam;
    Yend = Yend + ydiam;
    Zend = Zend + zdiam;
    
    Colors = [f1 f2 f3];
    ColorSet = Colors(samples,:);
    set(gca, 'ColorOrder', ColorSet);
    plot3([Xstart; Xend], [Ystart; Yend], [Zstart; Zend]); hold off;
end
end