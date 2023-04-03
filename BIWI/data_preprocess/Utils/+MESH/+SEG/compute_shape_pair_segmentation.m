function [Y1,Y2] = compute_shape_pair_segmentation(S1,S2,varargin)
%Compute structure-aware region correspondences between two shapes
%Input:
%   S1, S2: two shapes
%   'IsPointCloud': [If_S1_isPointCloud, If_S2_isPointCloud], default [0,0]
%   'cacheDir': dir that stores the corresponding regions
%   'numComponentsRange': default [8,7] - the range of  #components
%
%2018-03-19
%Original file: run_example.m, run_breaksymmetry.m
%Paper:  Robust Structure-based Shape Correspondence (CGF2018)
%By:  Yanir Kleiman<yanirk@gmail.com> and Maks Ovsjanikov
%Complete code: https://github.com/hexygen/structure-aware-correspondence


inputs = parse_REGION_CORRES_inputs(S1,S2,varargin{:});
save_dir = inputs.cacheDir;

if inputs.SegExists
    fprintf('Loading from the cache...')
    Y1 = inputs.Y1; Y2 = inputs.Y2;
    fprintf('done.\n')
    return
else % if not exists, compute the region correspondence:
    [M1, M2] = ShapePairMapper_new( S1, S2, inputs.numComponentsRange,...
        inputs.S1_opts, inputs.S2_opts);
    
    R = MatchShapes(M1, M2, 0);
    
    R.filename1 = S1.name;
    R.filename2 = S2.name;
    R = VisualizeMatching(R,[save_dir,S1.name,'_',S2.name,'_sym']);
    X1 = R.M1.output;
    X2 = R.M2.output;
    % breaksymmetry
    R1 = R;
    if (isfield(R1.M1.shape, 'PCD')), R1.M1 = CloudToTris(R1.M1); end
    if (isfield(R1.M2.shape, 'PCD')), R1.M2 = CloudToTris(R1.M2); end
    
    R1 = BreakSymmetries(R1);
    R1 = VisualizeMatching(R1, [save_dir,S1.name,'_',S2.name,'_nonsym']);
    Y1 = R1.M1.output;
    Y2 = R1.M2.output;
    % save the segments
    fid = fopen([save_dir,S1.name,'_',S2.name,'.',S1.name,'.seg.sym'],'w'); fprintf(fid,'%d\n',X1); fclose(fid);
    
    fid = fopen([save_dir,S1.name,'_',S2.name,'.',S2.name,'.seg.sym'],'w'); fprintf(fid,'%d\n',X2); fclose(fid);
    
    fid = fopen([save_dir,S1.name,'_',S2.name,'.',S1.name,'.seg.nonsym'],'w'); fprintf(fid,'%d\n',Y1); fclose(fid);
    
    fid = fopen([save_dir,S1.name,'_',S2.name,'.',S2.name,'.seg.nonsym'],'w'); fprintf(fid,'%d\n',Y2); fclose(fid);
end
end

function inputs = parse_REGION_CORRES_inputs(S1,S2,varargin)
defaultCacheDir = './cache/';
defaultIsPointCloud = [0,0];
defaultNumComponentsRange = [8,7];

p = inputParser;
addParameter(p,'cacheDir',defaultCacheDir,@ischar);
addParameter(p,'IsPointCloud',defaultIsPointCloud, @isnumeric);
addParameter(p,'numComponentsRange',defaultNumComponentsRange, @isnumeric);

parse(p,varargin{:});
inputs = p.Results;

inputs.S1_opts.pcd = inputs.IsPointCloud(1);
inputs.S2_opts.pcd = inputs.IsPointCloud(2);

if inputs.S1_opts.pcd, inputs.S1_opts.np = 6e3; end % if S1 is a point cloud
if inputs.S2_opts.pcd, inputs.S2_opts.np = 6e3; end % if S2 is a point cloud
if ~isdir(inputs.cacheDir)
    fprintf('%s is not a directory.\n',inputs.cacheDir)
    mkdir(inputs.cacheDir)
end

% check if segmentations already exist.
filename1 = [inputs.cacheDir,S1.name,'_',S2.name,'.',S1.name,'.seg.nonsym'];
filename2 = [inputs.cacheDir,S2.name,'_',S1.name,'.',S1.name,'.seg.nonsym'];
if exist(filename1,'file')
    fid = fopen([inputs.cacheDir,S1.name,'_',S2.name,'.',S1.name,'.seg.nonsym']); inputs.Y1 = fscanf(fid,'%d\n'); fclose(fid);
    fid = fopen([inputs.cacheDir,S1.name,'_',S2.name,'.',S2.name,'.seg.nonsym']); inputs.Y2 = fscanf(fid,'%d\n'); fclose(fid);
    inputs.SegExists = 1;
elseif exist(filename2,'file')
    fid = fopen([inputs.cacheDir,S2.name,'_',S1.name,'.',S1.name,'.seg.nonsym']); inputs.Y1 = fscanf(fid,'%d\n'); fclose(fid);
    fid = fopen([inputs.cacheDir,S2.name,'_',S1.name,'.',S2.name,'.seg.nonsym']); inputs.Y2 = fscanf(fid,'%d\n'); fclose(fid);
    inputs.SegExists = 1;
else
    inputs.SegExists = 0;
end
end
