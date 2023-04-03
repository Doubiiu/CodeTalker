function [param,p] = parse_MeshMapPlot_params(default_param,varargin)
p = inputParser;
addParameter(p,'OverlayAxis',default_param.OverlayAxis,@ischar);
addParameter(p,'MeshSepDist',default_param.MeshSepDist,@isnumeric);
addParameter(p,'Color_VtxNaN',default_param.Col_NaN,@isnumeric);
addParameter(p,'Alpha01',default_param.Alpha1,@isnumeric);
addParameter(p,'Alpha02',default_param.Alpha2,@isnumeric);
addParameter(p,'IfShowCoverage',default_param.IfShowCoverage,@islogical);
addParameter(p,'landmarks01',default_param.lmk1,@isnumeric);
addParameter(p,'landmarks02',default_param.lmk2,@isnumeric);
addParameter(p,'CorrespondingLandmarks',default_param.corres_lmks,@isnumeric);
addParameter(p,'Color_Landmarks',default_param.Col_lmk,@isnumeric);
addParameter(p,'Size_Landmarks',default_param.Size_lmk,@isnumeric);
addParameter(p,'Color_Correspondence',default_param.Col_corres,@isnumeric);
addParameter(p,'IfShowCorresLines',default_param.IfShowCorresLines,@islogical);
addParameter(p,'IfShowCorresVtx', default_param.IfShowCorresVtx, @islogical);
addParameter(p,'IfShowMappedSamples', default_param.IfShowMappedSamples, @islogical);
addParameter(p,'Error', default_param.error, @isnumeric);
addParameter(p,'caxis', default_param.Caxis_range, @isnumeric);
addParameter(p,'Color_ErrMin', default_param.Col_ErrMin, @isnumeric);
addParameter(p,'Color_ErrMax', default_param.Col_ErrMax, @isnumeric);
addOptional(p,'FaceColor',default_param.FaceColor,default_param.checkFaceColor);
addOptional(p,'EdgeColor',default_param.EdgeColor,default_param.checkEdgeColor);
addParameter(p,'Samples',default_param.samples, @isnumeric);
addParameter(p,'CameraPos',default_param.CameraPos, @isnumeric);

parse(p,varargin{:});

param = p.Results;
param.MeshSepDist = p.Results.MeshSepDist;
param.OverlayAxis = p.Results.OverlayAxis;
param.IfShowCoverage = p.Results.IfShowCoverage;
param.FaceColor = p.Results.FaceColor;
param.EdgeColor = p.Results.EdgeColor;
param.ColNaN = p.Results.Color_VtxNaN;
param.Alpha1 = p.Results.Alpha01;
param.Alpha2 = p.Results.Alpha02;
param.Col_lmk = p.Results.Color_Landmarks;
param.Size_lmk = p.Results.Size_Landmarks;
param.Col_corres = p.Results.Color_Correspondence;
param.IfShowVtx = p.Results.IfShowCorresVtx;
param.IfShowLines = p.Results.IfShowCorresLines;
param.IfShowMappedSamples = p.Results.IfShowMappedSamples;
param.Caxis_range = p.Results.caxis;
param.col_min = p.Results.Color_ErrMin;
param.col_max = p.Results.Color_ErrMax;
param.corres_lmks = p.Results.CorrespondingLandmarks;
param.samples = p.Results.Samples;
param.lmk1 = p.Results.landmarks01;
param.lmk2 = p.Results.landmarks02;
param.Err = p.Results.Error;

if ~isempty(param.samples)
    param.IfShowMappedSamples = true;
end
end