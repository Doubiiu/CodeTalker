function x = proj_doubly_stochastic(y0, mu_src, mu_tar, ifVerb)
% Dykstra's projection algorithm

if ~exist('ifVerb', 'var')
    ifVerb = false;
end

p = zeros(size(y0));
q = zeros(size(y0));
x = y0;

maxIter = 1000;
err = zeros(maxIter,1);
for i = 1:maxIter
    y = proj_simplex_array(x + p, mu_tar');
    p = x + p - y;
    x = proj_simplex_array((y + q)', mu_src')';
    q = y + q - x;
    
    err(i) = norm(sum(x,2) - mu_src)/norm(mu_src) + norm(sum(x,1) - mu_tar')/norm(mu_tar);
    if ifVerb
        disp(['Iter : ', num2str(i), ' -- Err : ', num2str(err(i))]);
    end
    
    if err(i) < 1e-10
        break;
    end
end