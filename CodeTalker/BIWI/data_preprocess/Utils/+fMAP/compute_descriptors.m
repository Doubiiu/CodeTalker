% original file: test_commute_faust.m
% paper: Informative Descriptor Preservation via Commutativity for Shape Matching
function [fct] = compute_descriptors(S,varargin)
inputs = parse_FCT_COMPUTATION_inputs(S,varargin{:});
numEigs = inputs.numEigsDescriptors;
numTimes = inputs.numTimes;

Basis = S.evecs(:,1:numEigs);
Ev = S.evals(1:numEigs);
A = S.A;

fct = [];
% only skip the WKS descriptors but keep all the lmk/region descriptors
fct = [fct, waveKernelSignature(Basis, Ev, A, numTimes)];

% descriptors based on landmarks;
if inputs.HaveLmks
    fct = [fct, waveKernelMap(Basis, Ev, A, numTimes, inputs.lmk)];
end

% descriptors based on regions
fct_region = [];
if inputs.HaveRegions
    if inputs.HaveWeights
        fct_region = waveKernelMap_region(Basis, Ev, A, numTimes, inputs.Regions, inputs.RegionsWeights); % with region weight given
    else
        fct_region = waveKernelMap_region(Basis, Ev, A, numTimes, inputs.regions); % with region weight given
    end
end
fct = [fct,fct_region];
fct = fct(:,1:inputs.numSkip:end);
end


function [inputs,p] = parse_FCT_COMPUTATION_inputs(S,varargin)
defaultLmks = [];
defaultRegions = {};
defaultRegions_weights = [];
defaultNumSkip = 40;  % skip size of the descriptors
defaultNumEigs = min(size(S.evecs,2), 100); % #Eigs to compute heat/wave kernel signatures
defaultNumTimes = 200;

p = inputParser;
addParameter(p,'Landmarks',defaultLmks,@isnumeric);
addParameter(p,'numSkip',defaultNumSkip,@isnumeric);
addParameter(p,'numTimes',defaultNumTimes,@isnumeric);
addParameter(p,'numEigsDescriptors',defaultNumEigs,@isnumeric);
addParameter(p,'Regions',defaultRegions,@iscell);
addParameter(p,'RegionsWeights',defaultRegions_weights,@isnumeric);

parse(p,varargin{:});
inputs = p.Results;

if isempty(inputs.Landmarks)
    inputs.HaveLmks = false;
else
    inputs.HaveLmks = true;
    inputs.lmk = inputs.Landmarks;
end

if isempty(inputs.Regions)
    inputs.HaveRegions = false;
else
    inputs.HaveRegions = true;
    inputs.regions = inputs.Regions;
end

if isempty(inputs.RegionsWeights)
    inputs.HaveWeights = false;
else
    inputs.HaveWeights = true;
    inputs.regions_weights_src = inputs.RegionsWeights;
end
end

