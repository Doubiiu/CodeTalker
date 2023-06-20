function x = proj_simplex_array(y, mu)
% Laurent Candat
% Projection onto sum_i x(i,j) = mu(j), x(i,j) >= 0

if ~exist('mu', 'var')
    mu = ones(1,size(y,2));
end

x = max( bsxfun( @minus, y, max( bsxfun( @rdivide, cumsum( sort( y, 1, 'descend'), 1) - repmat(mu, [size(y,1),1]), (1:size(y,1))' ), [], 1) ) , 0);