% original file: test_commute_faust.m
% paper: Informative Descriptor Preservation via Commutativity for Shape Matching
function [fct] = compute_descriptors_with_landmarks(S,numEigs,landmarks,t,num_skip)
if nargin < 4, t = 200; end;
Basis = S.evecs(:,1:numEigs);
Ev = S.evals(1:numEigs);
A = S.A;

fct = [];
% fprintf('Computing the descriptors...\n');tic;
fct = [fct, waveKernelSignature(Basis, Ev, A, t)];

% keep all the descriptors from the landmarks;
if nargin > 2
    if ~isempty(landmarks)
        fct = [fct, waveKernelMap(Basis, Ev, A, t, landmarks)];
    end
end

% Subsample descriptors (for faster computation). More descriptors is
% usually better, but can be slower.
if nargin < 5
    num_skip = 40;
end
fct = fct(:,1:num_skip:end);

% fprintf('done computing descriptors (%d with %d landmarks)\n',size(fct,2),length(landmarks)); toc;
end