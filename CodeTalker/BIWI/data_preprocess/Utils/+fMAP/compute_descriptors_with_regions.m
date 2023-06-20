% original file: test_commute_faust.m
% paper: Informative Descriptor Preservation via Commutativity for Shape Matching
function [fct] = compute_descriptors_with_regions(S,numEigs,regions,region_weight,num_skip)
Basis = S.evecs(:,1:numEigs);
Ev = S.evals(1:numEigs);
A = S.A;

fct = [];
% fprintf('Computing the descriptors...\n');tic;
fct = [fct, waveKernelSignature(Basis, Ev, A, 200)];

% keep all the region descriptors
if nargin > 3
    fct = [fct, waveKernelMap_region(Basis, Ev, A, 200, regions, region_weight)]; % with region weight given
else
    fct = [fct, waveKernelMap_region(Basis, Ev, A, 200, regions)]; % unweighted version
end

% Subsample descriptors (for faster computation). More descriptors is
% usually better, but can be slower.
if nargin < 5
    num_skip = 40;
end
fct = fct(:,1:num_skip:end);

% fprintf('done computing descriptors (%d with %d landmarks)\n',size(fct,2),length(regions)); toc;
end