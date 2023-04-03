% 2017-10-29
% original file: Adjoint_regularization_F1.m
% Paper: Adjoint Map Representation for Shape Analysis and Matching
% By Ruqi Huang, Maks Ovsjanikov
% complete code: https://github.com/ruqihuang/AdjointFmaps

function [C1_Adjoint, C1_Regular] = compute_fMap_adjoint(S1,S2,B1,B2,Ev1,Ev2,fct_src,fct_tar)
% set parameters
% paramters for the functional map optimization
a = 1e-1; % Descriptors preservation
b = 0.5;    % Commutativity with descriptors
c = 1e-3; % Commutativity with Laplacian
% paramters for the adjoint operator setting
epss1 = 500;
epss = 0.000000453999298;
numEigsSrc = size(B1,2); numEigsTar = size(B2,2);
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
%  fprintf('done\n');toc;

%--------------------------------------------------------------------------
% Fmap Computation
%fprintf('Optimizing the functional map...\n');tic;
Dlb = (repmat(Ev1, [1,numEigsTar]) - repmat(Ev2', [numEigsSrc,1])).^2;
Dlb = Dlb/norm(Dlb, 'fro')^2;
constFct = sign(B1(1,1)*B2(1,1))*[sqrt(sum(S2.area)/sum(S1.area)); zeros(numEigsTar-1,1)];

Dlb2 = (repmat(Ev2, [1,numEigsSrc]) - repmat(Ev1', [numEigsTar,1])).^2;
Dlb2 = Dlb2/norm(Dlb2, 'fro')^2;
constFct2 = sign(B2(1,1)*B1(1,1))*[sqrt(sum(S1.area)/sum(S2.area)); zeros(numEigsSrc-1,1)];

% a = 1e-1; % Descriptors preservation
% b = 0;    % Commutativity with descriptors
% c = 1e-3; % Commutativity with Laplacian
funObj = @(F) deal( a*sum(sum((reshape(F, [numEigsTar,numEigsSrc])*Fct_src - Fct_tar).^2))/2 + b*sum(cell2mat(cellfun(@(X,Y) sum(sum((X*reshape(F, [numEigsTar,numEigsSrc]) - reshape(F, [numEigsTar,numEigsSrc])*Y).^2)), OpTar', OpSrc', 'UniformOutput', false)), 2)/2 + c*sum( (F.^2 .* Dlb(:))/2 ),...
    a*vec((reshape(F, [numEigsTar,numEigsSrc])*Fct_src - Fct_tar)*Fct_src') + b*sum(cell2mat(cellfun(@(X,Y) vec(X'*(X*reshape(F, [numEigsTar,numEigsSrc]) - reshape(F, [numEigsTar,numEigsSrc])*Y) - (X*reshape(F, [numEigsTar,numEigsSrc]) - reshape(F, [numEigsTar,numEigsSrc])*Y)*Y'), OpTar', OpSrc', 'UniformOutput', false)), 2) + c*F.*Dlb(:));
funProj = @(F) [constFct; F(numEigsTar+1:end)];

funObj2 = @(F) deal( a*sum(sum((reshape(F, [numEigsSrc,numEigsTar])*Fct_tar - Fct_src).^2))/2 + b*sum(cell2mat(cellfun(@(X,Y) sum(sum((X*reshape(F, [numEigsSrc,numEigsTar]) - reshape(F, [numEigsSrc,numEigsTar])*Y).^2)), OpSrc', OpTar', 'UniformOutput', false)), 2)/2 + c*sum( (F.^2 .* Dlb(:))/2 ),...
    a*vec((reshape(F, [numEigsSrc,numEigsTar])*Fct_tar - Fct_src)*Fct_tar') + b*sum(cell2mat(cellfun(@(X,Y) vec(X'*(X*reshape(F, [numEigsSrc,numEigsTar]) - reshape(F, [numEigsSrc,numEigsTar])*Y) - (X*reshape(F, [numEigsSrc,numEigsTar]) - reshape(F, [numEigsSrc,numEigsTar])*Y)*Y'), OpSrc', OpTar', 'UniformOutput', false)), 2) + c*F.*Dlb(:));
funProj2 = @(F) [constFct2; F(numEigsSrc+1:end)];

funProj3 = @(F) [funProj(F(1:end/2)); funProj2(F(end/2+1:end))];

F_lb = zeros(numEigsTar*numEigsSrc, 1); F_lb(1) = constFct(1);
F_lb2 = zeros(numEigsTar*numEigsSrc, 1); F_lb2(1) = constFct2(1);

% Compute the optional functional map using a quasi-Newton method.
options.verbose = 0;
Finit = [F_lb; F_lb2];

lb1 = diag(Ev1(1:numEigsSrc));
lb2 = diag(Ev2(1:numEigsTar));
% use regular pipeline to initialize
F = minConf_PQN(@(F) funObj4(F, epss1,  epss, numEigsSrc, numEigsTar, funObj, funObj2, lb1, lb2), Finit, funProj3, options);
C1_Adjoint = reshape(F(1:end/2),numEigsTar, numEigsSrc);
%--------------------------------------------------------------------------
if nargout > 1
    % Regular pipeline:
    F = minConf_PQN(@(F) funObj4(F, 0,  0, numEigsSrc, numEigsTar, funObj, funObj2, lb1, lb2), Finit, funProj3, options);
    C1_Regular = reshape(F(1:end/2),numEigsTar, numEigsSrc);
end
end

function [a,b] = funObj4(F,eps1, eps2, numEigsSrc, numEigsTar,funObj,funObj2,lb1,lb2)
[a1,b1] = funObj(F(1:end/2));
[a2,b2] = funObj2(F(end/2+1:end));

C1 = reshape(F(1:end/2),numEigsTar, numEigsSrc);
C2 = reshape(F(end/2+1:end),numEigsSrc, numEigsTar);
a = a1 + a2 + eps1*norm(C1-C2','fro').^2/2 + eps2*norm(lb2*C1-C2'*lb1,'fro').^2/2;

b = [b1 + eps1*reshape(C1-C2',[],1) + eps2*reshape(lb2*(lb2*C1-C2'*lb1),[],1);...
    b2 + eps1*reshape(C2-C1',[],1) + eps2*reshape(lb1*(lb1*C2-C1'*lb2),[],1)];
end
