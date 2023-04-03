function [F,nnidx] = icp_fmap2(nnidx, SrcBasis, TarBasis, TarAe)

tol = 0;

maxIter = 10;
for i = 1:maxIter
    disp(['Rafinnement Iteration : ', num2str(i)]);
    
    % Opti C
    [U, S, V] = svd(TarBasis'*TarAe*SrcBasis(nnidx,:)); % X = U*S*V'
    S = diag(S);
    S = (abs(S - 1) < tol).*S + (S - 1 >= tol).*(1 + tol) + (S - 1 <= -tol).*(1 - tol);
    F = U*diag(S)*V';
    
    % Opti pi
    nnidx = knnsearch((F*SrcBasis')', TarBasis);
end