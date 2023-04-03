function default_param = load_MeshPlot_default_params(S)
default_param.Title = S.name;

% If visualize a function on mesh
default_param.IfShowFunc = false;
default_param.func = [];
default_param.checkFunc = @(T) length(T)==S.nv; % check if the input function has the correct length

% If visualize a set of vertices
default_param.IfShowVtx = false;
default_param.landmarks = [];
default_param.Size_lmk = 50;
% default_param.Col_lmk = [1, 0.7, 0]; % orange
default_param.Col_lmk = [0.4, 0.58, 0.93]; % blue
% If visualize a set of edges
default_param.IfShowEdge = false;
default_param.edgeList = [];
default_param.checkEdgeList = @(edgeList) isnumeric(edgeList) && size(edgeList,2) == 2;
default_param.edgeID = [];
default_param.CameraPos = [0,0];
default_param.LineWidth = 1.2;

% parameters for trimesh
default_param.FaceColor = 'interp';
validFaceColor = {'interp','flat'};
default_param.checkFaceColor = @(x) any(validatestring(x,validFaceColor));

default_param.EdgeColor = 'none';
validEdgeColor = {'none','flat','interp'};
default_param.checkEdgeColor = @(x) any(validatestring(x,validEdgeColor));
default_param.FaceAlpha = 0.6;

% parameters for rendering
default_param.LightPos = [-0.2, -0.5, 0.5];
default_param.BackgroundColor = [1,1,1];
default_param.RotationOps = {};
default_param.MeshVtxColor = get_meshVtxColor(S);
default_param.checkMeshVtxColor = @(f) isnumeric(f) && (size(f,1) == S.nv) && (size(f,2) == 1 || size(f,2) == 3);
default_param.IfPlotIsolines = false;
default_param.VtxPos = S.surface.VERT;
default_param.checkVtxPos = @(X) isnumeric(X) && size(X,1) == S.nv && size(X,2) == 3;
default_param.MeshSepDist = [1.5,0,0];
default_param.VecField = [];
end


function col = get_meshVtxColor(S)
g1 = S.surface.X;
g2 = S.surface.Y;
g3 = S.surface.Z;

g1 = normalize_function(0,1,g1);
g2 = normalize_function(0,1,g2);
g3 = normalize_function(0,1,g3);
col = [g1,g2,g3];
end

function fnew = normalize_function(min_new,max_new,f)
fnew = f - min(f);
fnew = (max_new-min_new)*fnew/max(fnew) + min_new;
end