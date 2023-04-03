% GenerateSecondOrder Generates the quadratic optimization formula for
% comparing two shape graphs.
function [ Aff, n, m ] = GenerateSecondOrder( val1, val2, adj1, adj2, use_val )

t_generate = tic;

n = size(adj1, 1);
m = size(adj2, 1);

nm = n*m;
D = zeros(nm);
sigma = 0.5;

k = 20;
hist_edges = (0:k);

H1 = zeros(n, k);
for a=1:n
    H1(a, :) = histcounts(adj1(a, :), hist_edges);
end
H2 = zeros(m, k);
for b=1:m
    H2(b, :) = histcounts(adj2(b, :), hist_edges);
end

for i=1:nm
    [xi, yi] = ind2sub([n m], i);
    
    % Put first order term for (xi, yi) on the diagonal:
    i_max = max(val1(xi), val2(yi));
    i_min = min(val1(xi), val2(yi));

    val = i_max - i_min;
    
    same_cluster = 
        
    h1 = H1(xi, :);
    h2 = H2(yi, :);

    d_hist = norm(h1 - h2);
    
    %%% First order value:
    if (use_val == 0)
        D(i, i) = d_hist;
    else
    %%% Alternative option: use node value difference (node values indicate
    %%% the interval which the node belongs to in the initial segmentation):
        D(i, i) = val + d_hist;
    end
    %%%

    

    j = (i+1:nm)';
    [xj, yj] = ind2sub([n m], j);

    d_val = abs(abs(val1(xi) - val2(yi)) - abs(val1(xj)' - val2(yj)'));

    dhist = H1(xj, :) - H2(yj, :);
    d_hist2 = sqrt(sum(dhist.^2,2));

    d_hist_diff = abs(d_hist - d_hist2);

    adj_x = adj1(xj, xi);
    adj_y = adj2(yj, yi);

    min_adj = min(adj_x, adj_y);
    min_adj(min_adj == 0) = 0.1;

    d_adj = (max(adj_x, adj_y) ./ min_adj) - 1;

    if (use_val == 0)
        %%% Second order values based on difference of histograms and
        %%% adjacencies:
        d = d_adj + d_hist_diff;
    else
        %%% Alternative second order value, using the difference between difference of values:
        d = d_adj + d_val + d_hist_diff;
    end

    D(i, j) = d;
    D(j, i) = d;
end

Aff = exp(-D * sigma); % For sigma = 0.5, affinity for 1 distance is 0.6

t = toc(t_generate);
display(['Generated second order affinity matrix in ' num2str(t) ' seconds.']);

end

