function C12 = compute_fMap(S1,S2,varargin)
%Compute fMap with(-out) adjoint operator
%Output:
%   C12: S1 -> S2
%Input:
%   (Requested)
%   Shapes S1 and S2 with pre-calculated Eigen-vectors and values
%   'BasisSize': [numEigs_Src, numEigs_tar], e.g., [50, 50] (default)
%   'type': 'adjoint' or 'regular' (default)
%   'Landmarks': corresponding landmarks [vec_lmk_src, vec_lmk_tar], e.g., [(1:10)',(1:10)']
%   'Regions': corresponding regions {cell_region_src, cell_region_tar}
%   'RegionWeights': weights for the regions, {[ones(num_region,1)],[ones(num_region,1)]}
%   
%   (Optional)
%   'numSkip': #desriptors to skip to speed up the optimization. when = 1, i.e., ues all the descriptors. (default 40)
%   'numTimes': difussion time in wks/hks computation, default 200
%   'numEigsDescriptors': #Eigs to compute wks/hks
%
%2018-03-18
%original file: test_commute_faust.m, Adjoint_regularization_F1.m
%paper: Informative Descriptor Preservation via Commutativity for Shape Matching
%       Adjoint Map Representation for Shape Analysis and Matching
%By Ruqi Huang, Maks Ovsjanikov
%complete code: https://github.com/ruqihuang/AdjointFmaps
%----------------------------------------------------------------------------------------------
   
inputs = parse_FMAP_COMPUTATION_inputs(varargin{:});

B1 = S1.evecs(:,1:inputs.numEigs_src);
B2 = S2.evecs(:,1:inputs.numEigs_tar);
Ev1 = S1.evals(1:inputs.numEigs_src);
Ev2 = S2.evals(1:inputs.numEigs_tar);

fct1 = fMAP.compute_descriptors(S1,'Landmarks',inputs.lmk_src,...
    'numEigsDescriptors',inputs.numEigsDescriptors,...
    'Regions',inputs.regions_src,...
    'RegionsWeights',inputs.regions_weights_src,...
    'numSkip',inputs.numSkip,...
    'numTimes',inputs.numTimes);

fct2 = fMAP.compute_descriptors(S2,'Landmarks',inputs.lmk_tar,...
    'numEigsDescriptors',inputs.numEigsDescriptors,...
    'Regions',inputs.regions_tar,...
    'RegionsWeights',inputs.regions_weights_tar,...
    'numSkip',inputs.numSkip,...
    'numTimes',inputs.numTimes);

switch inputs.type
    case 'regular'
        fprintf('Computing regular fMap.\n')
        C12 = fMAP.compute_fMap_regular(S1,S2,B1,B2,Ev1,Ev2,fct1,fct2);
%         C12 = fMAP.compute_fMap_regular_new(S1,S2,B1,B2,Ev1,Ev2,fct1,fct2);
    case 'adjoint'
        fprintf('Computing fMap with adjoint operator.\n');
        C12 = fMAP.compute_fMap_adjoint(S1,S2,B1,B2,Ev1,Ev2,fct1,fct2);
    otherwise
        error(['Unsupported type: ',inputs.type]);
end
end
%%
function [inputs,p] = parse_FMAP_COMPUTATION_inputs(varargin)
defaultBasisSize = [50,50];
defaultLmks = [];
defaultRegions = {};
defaultRegions_weights = {};
defaultNumSkip = 40;  % skip size of the descriptors
defaultNumEigs = 100; % #Eigs to compute heat/wave kernel signatures
defaultNumTimes = 200;
defaultType = 'regular';

p = inputParser;
addParameter(p,'BasisSize',defaultBasisSize,@isnumeric);
addParameter(p,'Landmarks',defaultLmks,@isnumeric);
addParameter(p,'numSkip',defaultNumSkip,@isnumeric);
addParameter(p,'numTimes',defaultNumTimes,@isnumeric);
addParameter(p,'numEigsDescriptors',defaultNumEigs,@isnumeric);
addParameter(p,'Regions',defaultRegions,@iscell);
addParameter(p,'RegionsWeights',defaultRegions_weights,@iscell);
addParameter(p,'type', defaultType, @ischar);
parse(p,varargin{:});
inputs = p.Results;

if length(size(inputs.BasisSize)) ~= 2
    error('Wrong input Basis size.');
else
    inputs.numEigs_src = inputs.BasisSize(1);
    inputs.numEigs_tar = inputs.BasisSize(2);
end

if isempty(inputs.Landmarks)
    inputs.HaveLmks = false;
    inputs.lmk_src = [];
    inputs.lmk_tar = [];
else
    if size(inputs.Landmarks,2) ~= 2
        error('Wrong input: corresponding landmarks');
    else
        inputs.HaveLmks = true;
        inputs.lmk_src = inputs.Landmarks(:,1);
        inputs.lmk_tar = inputs.Landmarks(:,2);
    end
end

if isempty(inputs.Regions)
    inputs.HaveRegions = false;
    inputs.regions_src = {};
    inputs.regions_tar = {};
else
    if length(inputs.Regions) ~= 2
        error('Wrong input: corresponding Regions');
    else
        inputs.HaveRegions = true;
        inputs.regions_src = inputs.Regions{1};
        inputs.regions_tar = inputs.Regions{2};
        if length(inputs.regions_src)~= length(inputs.regions_tar)
            error('Wrong input: regions do not match')
        end
    end
end

if isempty(inputs.RegionsWeights)
    inputs.HaveWeights = false;
    inputs.regions_weights_src = [];
    inputs.regions_weights_tar = [];
else
    if length(inputs.RegionsWeights) ~= 2
        error('Wrong input: Regions weights');
    else
        inputs.HaveWeights = true;
        inputs.regions_weights_src = inputs.RegionsWeights{1};
        inputs.regions_weights_tar = inputs.RegionsWeights{2};
    end
end
fprintf('-------------------- Compute fMap -------------------\n')
fprintf('Basis size: %d (src) and %d (tar)\n', inputs.BasisSize(1),inputs.BasisSize(2));
fprintf('#Eigs to compute wavekernel signatures: %d\n',inputs.numEigsDescriptors);
fprintf('Diffusion time for wavekernel signatures: %.2f\n', inputs.numTimes);
fprintf('Skip size for descriptors: %d\n', inputs.numSkip);
if inputs.HaveLmks, fprintf('#corresponding landmarks: %d\n', length(inputs.lmk_src)); end
if inputs.HaveRegions
    fprintf('# corresponding regions: %d, ', length(inputs.regions_src));
    if inputs.HaveWeights
        fprintf('with region weights.\n');
    else
        fprintf('without region weights.\n');
    end    
end
fprintf('-----------------------------------------------------\n')
end