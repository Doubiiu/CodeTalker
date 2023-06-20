function [param, p] = parse_MeshPlot_params(default_param, varargin)
p = inputParser;
addParameter(p, 'Title', default_param.Title, @isstr);
addParameter(p,'IfShowFunc',default_param.IfShowFunc, @islogical);
addParameter(p,'func', default_param.func, default_param.checkFunc);
addParameter(p,'IfShowVtx',default_param.IfShowVtx, @islogical);
addParameter(p, 'landmarks', default_param.landmarks, @isnumeric);
addParameter(p,'Color_Landmarks',default_param.Col_lmk,@isnumeric);
addParameter(p,'Size_Landmarks',default_param.Size_lmk,@isnumeric);

addParameter(p,'FaceColor',default_param.FaceColor,default_param.checkFaceColor);
addParameter(p,'EdgeColor',default_param.EdgeColor,default_param.checkEdgeColor);
addParameter(p,'FaceAlpha', default_param.FaceAlpha, @isnumeric);
addParameter(p,'BackgroundColor',default_param.BackgroundColor, @isnumeric);

addParameter(p,'IfShowEdge',default_param.IfShowEdge, @islogical);
addParameter(p,'edgeList', default_param.edgeList, default_param.checkEdgeList);
addParameter(p,'edgeID', default_param.edgeID, @isnumeric);
addParameter(p,'LineWidth', default_param.LineWidth, @isnumeric);

addParameter(p,'CameraPos', default_param.CameraPos,@isnumeric);
addParameter(p,'LightPos', default_param.LightPos,@isnumeric);
addParameter(p,'RotationOps', default_param.RotationOps,@iscell);
addParameter(p,'MeshVtxColor',default_param.MeshVtxColor, default_param.checkMeshVtxColor);
addParameter(p,'IfPlotIsolines',default_param.IfPlotIsolines,@islogical);
addParameter(p,'VtxPos',default_param.VtxPos,default_param.checkVtxPos);
addParameter(p,'MeshSepDist',default_param.MeshSepDist,@isnumeric);
addParameter(p,'VecField',default_param.VecField,@isnumeric);

parse(p,varargin{:});
param = p.Results;
param.Col_lmk = p.Results.Color_Landmarks;
param.Size_lmk = p.Results.Size_Landmarks;

if ~isempty(param.func)
    param.IfShowFunc = true;
    param.FaceAlpha = 0.9;
end
if ~isempty(param.landmarks)
    param.IfShowVtx = true;
    if ~param.IfShowFunc
        param.FaceColor = [0.7, 0.7, 0.7];        
    end
end
if ~isempty(param.edgeList) || ~isempty(param.edgeID)
    param.IfShowEdge = true;
end


end