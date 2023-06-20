function [F,nnidx] = icp_fmap(fmap, SrcBasis, TarBasis, TarAe)

nv = size(SrcBasis,1);

tol = 0;
nbPt = 3000;
idx_cor = randperm(nv);
idx_cor = sort(idx_cor(1:nbPt))';

F = fmap;

maxIter = 10;
for i = 1:maxIter
    disp(['Rafinnement Iteration : ', num2str(i)]);
    
    % Opti pi
    nnidx = knnsearch((F*SrcBasis')', TarBasis);
    
    % Opti C
    [U, S, V] = svd(TarBasis'*TarAe*SrcBasis(nnidx,:)); % X = U*S*V'
    S = diag(S);
    S = (abs(S - 1) < tol).*S + (S - 1 >= tol).*(1 + tol) + (S - 1 <= -tol).*(1 - tol);
    F = U*diag(S)*V';
end