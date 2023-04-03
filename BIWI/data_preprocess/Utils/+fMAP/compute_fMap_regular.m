
% original file: test_commute_faust.m
% paper: Informative Descriptor Preservation via Commutativity for Shape Matching
% Input:
%   S1: the source mesh with the new basis B1, and the corresponding eigenvalues Ev1
%   S2: the target mesh with the new basis B2, and the corresponding eigenvalues Ev2
%   fct_src: the descriptors of shape S1
%   fct_tar: the descriptors of shape S2
function [fMap] = compute_fMap_regular(S1,S2,B1,B2,Ev1,Ev2,fct_src,fct_tar,C_ini,para)
a = 1e-1; % Descriptors preservation
b = 1;    % Commutativity with descriptors
c = 1e-3; % Commutativity with Laplacian
d = 2;
numEigsSrc = size(B1,2); numEigsTar = size(B2,2);
if nargin > 9
    if isfield(para,'a'), a = para.a; end
    if isfield(para,'b'), b = para.b; end
    if isfield(para,'c'), c = para.c; end
    if isfield(para,'d'), d = para.d; end
end
if nargin < 9
    d = 0;
end
%--------------------------------------------------------------------------
% Descriptors
assert(size(fct_src,2)==size(fct_tar,2));
% Normalization
no = sqrt(diag(fct_src'*S1.A*fct_src))';
fct_src = fct_src ./ repmat(no, [S1.nv,1]);
no = sqrt(diag(fct_tar'*S2.A*fct_tar))';
fct_tar = fct_tar ./ repmat(no, [S2.nv,1]);
%--------------------------------------------------------------------------
% Multiplication Operators
%    fprintf('Pre-computing the multiplication operators...');tic;
numFct = size(fct_src,2);
OpSrc = cell(numFct,1);
OpTar = cell(numFct,1);
for i = 1:numFct
    OpSrc{i} = B1'*S1.A*(repmat(fct_src(:,i), [1,numEigsSrc]).*B1);
    OpTar{i} = B2'*S2.A*(repmat(fct_tar(:,i), [1,numEigsTar]).*B2);
end
Fct_src = B1'*S1.A*fct_src;
Fct_tar = B2'*S2.A*fct_tar;
%% Fmap Computation
%--------------------------------------------------------------------------
% fprintf('Optimizing the functional map...\n');tic;
Dlb = (repmat(Ev1, [1,numEigsTar]) - repmat(Ev2', [numEigsSrc,1])).^2;
Dlb = Dlb/norm(Dlb, 'fro')^2;
constFct = sign(B1(1,1)*B2(1,1))*[sqrt(sum(S2.area)/sum(S1.area)); zeros(numEigsTar-1,1)];

% with initial fMap: C_ini
if nargin > 8
    if ~isempty(C_ini)
        F_lb = reshape(C_ini,[],1);
        F_lb = F_lb*constFct(1)/F_lb(1);
    else % empty initialization
        F_lb = zeros(numEigsTar*numEigsSrc, 1); F_lb(1) = constFct(1);
    end
else
    F_lb = zeros(numEigsTar*numEigsSrc, 1); F_lb(1) = constFct(1);
end
% a = 1e-1; % Descriptors preservation
% b = 1;    % Commutativity with descriptors
% c = 1e-3; % Commutativity with Laplacian
funObj = @(F) deal( a*sum(sum((reshape(F, [numEigsTar,numEigsSrc])*Fct_src - Fct_tar).^2))/2 + b*sum(cell2mat(cellfun(@(X,Y) sum(sum((X*reshape(F, [numEigsTar,numEigsSrc]) - reshape(F, [numEigsTar,numEigsSrc])*Y).^2)), OpTar', OpSrc', 'UniformOutput', false)), 2)/2 + c*sum( (F.^2 .* Dlb(:))/2 ),...
    a*vec((reshape(F, [numEigsTar,numEigsSrc])*Fct_src - Fct_tar)*Fct_src') + b*sum(cell2mat(cellfun(@(X,Y) vec(X'*(X*reshape(F, [numEigsTar,numEigsSrc]) - reshape(F, [numEigsTar,numEigsSrc])*Y) - (X*reshape(F, [numEigsTar,numEigsSrc]) - reshape(F, [numEigsTar,numEigsSrc])*Y)*Y'), OpTar', OpSrc', 'UniformOutput', false)), 2) + c*F.*Dlb(:)+...
    d*(F - F_lb).^2);
funProj = @(F) [constFct; F(numEigsTar+1:end)];


% Compute the optional functional map using a quasi-Newton method.
options.verbose = 1;
F_lb = reshape(minConf_PQN(funObj, F_lb, funProj, options), [numEigsTar,numEigsSrc]);
% fprintf('done fmap optimization.\n');toc;

fMap = F_lb;
end

function x = vec(X)
x = reshape(X,numel(X),1);
end