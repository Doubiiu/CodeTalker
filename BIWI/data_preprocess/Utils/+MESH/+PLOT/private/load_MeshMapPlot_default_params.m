function default_param = load_MeshMapPlot_default_params()
default_param.OverlayAxis = 'z'; % overlay direcion of S1 and S2
default_param.MeshSepDist = 1.5; % overaly distance of S1 and S2
default_param.Col_NaN = [0.1,0.1,0.1]; % color for vertex with no correspondence in "map"
default_param.Alpha1 = 0.99; % alpha for mesh S1
default_param.Alpha2 = 0.99; % alpha for mesh S2

default_param.lmk1 = []; % landmarks on S1
default_param.lmk2 = []; % landmarks on S2
default_param.Col_lmk = [1,0.7,0]; % marker's color for landmarks 01/02
default_param.Size_lmk = 50; % marker's size for the landmarks 01/02
default_param.corres_lmks = []; % a set of corresponding landmarks
default_param.Col_corres = [1,0.24,0.24]; % marker's color for mapped landmarks
default_param.Caxis_range = []; % caxis range for Error
default_param.Col_ErrMin = [13,26,129]/256;
default_param.Col_ErrMax = [255,42,44]/256;
default_param.error = []; % error of map per vertex
default_param.CameraPos = [0,0];
default_param.FaceColor = 'interp';
validFaceColor = {'interp','flat'};
default_param.checkFaceColor = @(x) any(validatestring(x,validFaceColor));

default_param.EdgeColor = 'none';
validEdgeColor = {'none','flat','interp'};
default_param.checkEdgeColor = @(x) any(validatestring(x,validEdgeColor));

default_param.IfShowCoverage = true;        % if visualize the vtx on S2 that are not covered by "map"
default_param.IfShowCorresVtx = false;      % if visualize vtx in "corres_lmks"
default_param.IfShowCorresLines = true;     % if visualize the lines connecting "corres_lmks" on S2
default_param.IfShowMappedSamples = false;   % if visualize the lines connecting "samples" and their mapped vtx
default_param.samples = [];
end
