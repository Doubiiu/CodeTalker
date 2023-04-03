function [cov] = visualize_map_colors(S1,S2,map,varargin)
%function [] = visualize_map_colors_new(S1,S2,map,varargin)
%   Visualize a vertex2vertex map/or a set of correspondence between two shapes
%
%   ******Required inputs******
%
%   Two meshes S1 and S2, and a pMap 'map' maps S1 to S2
%   'map': S1.nv-by-1 vector (vertex without correspondence set to NaN)
%            or d-by-2 vector (a set of correspondences)
%
%   ******Optional inputs*****
%   (the most important ones, others see "load_MESHPLOT_default_params()")
%
%   'Error': (Euc/geodesic) error per vertex, or given on a set of landmarks
%
%   'caxis': heatmap range for Error, default is [min(Error), max(Error)]
%
%   'Samples': a vector of vtxID on S1, to show the lines of mapping of them
%
%   'landmarks01/02': landmarks (vtxID) on S1/S2, to plot them on the mesh
%
%   'OverlayAxis': {'x', 'y', 'z', 'xy', 'yz', 'xz', 'xyz'}
%           direction to overlay the mesh S1 and S2,
%
%   'MeshSepDist': numeric
%           direction to overlay the mesh S1 and S2,
%
%   'Color_VtxNaN': RGB-value
%           RGB for the vertices on S1 without input correspondence
%
%   'IfShowCoverage': true or false
%           if true, the vtx on S2 that are not covered will be set to black

%   2018-01-06
%   original code: [Maks' fMap code]
%   "visualize_map_colors" and "visualize_map_lines"


% set defualt values
default_param = load_MeshMapPlot_default_params();
default_param.samples = [];

% parse the inputs
param = parse_MeshMapPlot_params(default_param, varargin{:});
corres_lmks = param.corres_lmks;
samples = param.samples;
lmk1 = param.lmk1;
lmk2 = param.lmk2;
Err = param.Err;

if isempty(corres_lmks) % no input corresponding landmarks
    param.IfShowVtx = false;
    param.IfShowLines = false;
end

if param.IfShowMappedSamples
    if isempty(samples)
        default_param.samples = euclidean_fps([S1.surface.X,S1.surface.Y,S1.surface.Z],10);
    end
end

if param.IfShowLines
    param.Alpha2 = 0.5;
end
% TODO: change MeshSepDist to 3d vec, and remove the OverlayAxis param!
% set up the overlay direction and distance
xdiam = param.MeshSepDist*(max(S2.surface.X)-min(S2.surface.X));
ydiam = param.MeshSepDist*(max(S2.surface.Y)-min(S2.surface.Y));
zdiam = param.MeshSepDist*(max(S2.surface.Z)-min(S2.surface.Z));
[xdiam, ydiam, zdiam] = set_overlay_axis(xdiam, ydiam, zdiam, param.OverlayAxis);

n1 = length(S1.surface.X); n2 = length(S2.surface.X);
% check the input map: pMap or matches
T = check_input_pMap(map,n1,n2);
% check the input error: per vertex or on a set of landmarks
Error = check_input_Error(Err,n1);

%% TODO: user input heatmap is problematic!
% set the Error heatmap
if ~isempty(Error)
    Error_color = ones(n1,3); % vtx without error (NaN), is set to white;
    
    if isempty(param.Caxis_range) % if not specified, set to the min/max of input Error
        param.Caxis_range = [min(Error(~isnan(Error))),max(Error(~isnan(Error)))];
    end
    vid = find(~isnan(Error));
    for i = 1:3
        Error_color(vid,i) = interp1(param.Caxis_range,...
            [param.col_min(i),param.col_max(i)],...
            Error(vid));
    end
end
%%
% set color for S1 (picked from S2 according to the input map)
[g1,g2,g3] = set_mesh_color(S2);

if sum(isnan(T)) == 0
    f1 = g1(T);
    f2 = g2(T);
    f3 = g3(T);
else
    nan_id = find(isnan(T));
    id = find(~isnan(T));
    f1(nan_id) = param.ColNaN(1);
    f2(nan_id) = param.ColNaN(2);
    f3(nan_id) = param.ColNaN(3);
    f1(id) = g1(T(id));
    f2(id) = g2(T(id));
    f3(id) = g3(T(id));
    f1 = reshape(f1,[],1);
    f2 = reshape(f2,[],1);
    f3 = reshape(f3,[],1);
end

% if show the coverage
if param.IfShowCoverage % visualize the covarage
    coverage_mask = zeros(n2,1);
    coverage_mask(unique(T(~isnan(T)))) = 1;
else
    coverage_mask = ones(n2,1);
end
cov = 100*length(unique(T(~isnan(T))))/n2; % coverage rate

%% visualization!
X1 = S1.surface.X; Y1 = S1.surface.Y; Z1 = S1.surface.Z;
X2 = S2.surface.X; Y2 = S2.surface.Y; Z2 = S2.surface.Z;

% X1 = X1 - min(X1); Y1 = Y1 - min(Y1); Z1 = Z1 - min(Z1);
% X2 = X2 - min(X2); Y2 = Y2 - min(Y2); Z2 = Z2 - min(Z2);
X1 = X1 - mean(X1); Y1 = Y1 - mean(Y1); Z1 = Z1 - mean(Z1);
X2 = X2 - mean(X2); Y2 = Y2 - mean(Y2); Z2 = Z2 - mean(Z2);

trimesh(S1.surface.TRIV, X1, Y1, Z1, ...
    'FaceVertexCData', [f1, f2, f3],...
    'FaceColor',param.FaceColor,...
    'FaceAlpha',param.Alpha1,...
    'EdgeColor',param.EdgeColor); view(param.CameraPos);
axis equal; axis off; hold on;

% put S2 on the top of S1
trimesh(S2.surface.TRIV, X2 + xdiam, Y2 + ydiam, Z2 + zdiam, ...
    'FaceVertexCData', [coverage_mask.*g1, coverage_mask.*g2, coverage_mask.*g3],...
    'FaceColor', param.FaceColor,...
    'FaceAlpha', param.Alpha2,...
    'EdgeColor', param.EdgeColor); view(param.CameraPos);
axis equal; axis off; hold on;

if ~isempty(Error)
    trimesh(S1.surface.TRIV, X1 - xdiam, Y1 - ydiam, Z1 - zdiam, ...
        'FaceVertexCData', Error,... %TODO: change to user-input: 'Error_color'
        'FaceColor',param.FaceColor,...
        'FaceAlpha',param.Alpha1,...
        'EdgeColor',param.EdgeColor);
    axis equal; axis off; hold on; view(param.CameraPos);
    caxis(param.Caxis_range);
end

% add landmarks;
if ~isempty(lmk1)
    scatter3(X1(lmk1),Y1(lmk1),Z1(lmk1),...
        param.Size_lmk, param.Col_lmk, 'filled'); hold on;
end

if ~isempty(lmk2)
    scatter3(X2(lmk2)+xdiam,Y2(lmk2)+ydiam,Z2(lmk2)+zdiam,...
        param.Size_lmk, param.Col_lmk, 'filled'); hold on;
end

% visualize corresponding landmarks
if param.IfShowVtx
    lmk1 = corres_lmks(:,1);
    lmk2 = corres_lmks(:,2);
    % landmarks on S1
    scatter3(X1(lmk1),Y1(lmk1),Z1(lmk1),...
        param.Size_lmk, param.Col_lmk, 'filled'); hold on;
    % landmarks on S2
    scatter3(X2(lmk2)+xdiam,Y2(lmk2)+ydiam,Z2(lmk2)+zdiam,...
        param.Size_lmk, param.Col_lmk, 'filled'); hold on;
    % T(landmarks of S1) on S2
    scatter3(X2(T(lmk1))+xdiam, Y2(T(lmk1))+ydiam, Z2(T(lmk1))+zdiam,...
        param.Size_lmk, param.Col_corres,'filled'); hold on;
end
% visualize the lines on S2 (connecting the lmk and the mapped lmk)
if param.IfShowLines
    Xstart = X2(T(lmk1))'; Xend = X2(lmk2)';
    Ystart = Y2(T(lmk1))'; Yend = Y2(lmk2)';
    Zstart = Z2(T(lmk1))'; Zend = Z2(lmk2)';
    
    ColorSet = repmat(param.Col_corres,length(lmk1),1);
    set(gca, 'ColorOrder', ColorSet);
    plot3([Xstart; Xend]+xdiam, [Ystart; Yend]+ydiam, [Zstart; Zend]+zdiam,...,
        'LineWidth',2,'LineStyle','-');
end

% visualize the line connecting lmks on S1 and S2
if param.IfShowMappedSamples
    Xstart = X1(samples)'; Xend = X2(T(samples))';
    Ystart = Y1(samples)'; Yend = Y2(T(samples))';
    Zstart = Z1(samples)'; Zend = Z2(T(samples))';
    
    Xend = Xend + xdiam;
    Yend = Yend + ydiam;
    Zend = Zend + zdiam;
    
    Colors = [f1 f2 f3];
    ColorSet = Colors(samples,:);
    set(gca, 'ColorOrder', ColorSet);
    plot3([Xstart; Xend], [Ystart; Yend], [Zstart; Zend]);
end
hold off;
title(['coverage rate: ',num2str(cov,'%2.2f'),'%']);
end
%%
function Err = check_input_Error(Err_in,n1)
if ~isempty(Err_in)
    if size(Err_in,1) == 1 || size(Err_in,2) == 1
        Err = reshape(Err_in,[],1);
        if length(Err) ~= n1
            error('Input Error size does not match.');
        end
    elseif size(Err_in,2) == 2 % (vid, error)
        if max(Err_in(:,1)) > n1
            error('Input Error out of index')
        else
            Err = nan(n1,1);
            Err(Err_in(:,1)) = Err_in(:,2);
        end
    else
        error('Invalid input Error.');
    end
    if any(Err < 0)
        warning('Input error has negative value');
    end
else
    Err = [];
end
end

function [T] = check_input_pMap(map,n1,n2)
if size(map,1) == 1 || size(map,2) == 1  % input is a pMap
    T = reshape(map,[],1);
    if length(T) ~= n1
        error('Input pMap size does not match.')
    end
    if max(T) > n2
        error('pMap out of index.')
    end
elseif size(map,2) == 2 % input is a set of corresponding matches
    if max(map(:,1)) > n1 || max(map(:,2)) > n2
        error('Input matches out of index.')
    end
    T = nan(n1,1); % construct a pMap
    T(map(:,1)) = map(:,2);
else
    error('Invalid input map.');
end
end

function [xdiam, ydiam, zdiam] = set_overlay_axis(xdiam, ydiam, zdiam, overlay_axis)
switch lower(overlay_axis)
    case 'x'
        ydiam = 0; zdiam = 0;
    case 'y'
        xdiam = 0; zdiam = 0;
    case 'z'
        xdiam = 0; ydiam = 0;
    case 'xy'
        zdiam = 0;
    case 'xz'
        ydiam = 0;
    case 'yz'
        xdiam = 0;
    case 'xyz'
    otherwise
        error('invalid overlay_axis type')
end
end

function [g1,g2,g3] = set_mesh_color(S)
g1 = normalize_function(0,1,S.surface.X);
g2 = normalize_function(0,1,S.surface.Y);
g3 = normalize_function(0,1,S.surface.Z);
g1 = reshape(g1,[],1);
g2 = reshape(g2,[],1);
g3 = reshape(g3,[],1);
end

function fnew = normalize_function(min_new,max_new,f)
fnew = f - min(f);
fnew = (max_new-min_new)*fnew/max(fnew) + min_new;
end

% Euclidean farthest point sampling.
function idx = euclidean_fps(C,k,seed)

nv = size(C,1);

if(nargin<3)
    idx = randi(nv,1);
else
    idx = seed;
end

dists = bsxfun(@minus,C,C(idx,:));
dists = sum(dists.^2,2);

for i = 1:k
    maxi = find(dists == max(dists));
    maxi = maxi(1);
    idx = [idx; maxi];
    newdists = bsxfun(@minus,C,C(maxi,:));
    newdists = sum(newdists.^2,2);
    dists = min(dists,newdists);
end
idx = idx(2:end);
end

