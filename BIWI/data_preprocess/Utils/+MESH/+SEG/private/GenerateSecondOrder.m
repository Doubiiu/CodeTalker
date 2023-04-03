% GenerateSecondOrder Generates the quadratic optimization formula for
% comparing two shape graphs.
function [ Aff, n, m ] = GenerateSecondOrder( cluster1, cluster2, adj1, adj2, use_cluster )

t_generate = tic;

n = size(adj1, 1);
m = size(adj2, 1);

nm = n*m;
D = zeros(nm);
sigma = 0.5;
cluster_weight = 1;

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
    same_cluster = double(cluster1(xi) ~= cluster2(yi)) * cluster_weight;
    
    h1 = H1(xi, :);
    h2 = H2(yi, :);

    d_hist = norm(h1 - h2);
    
    %%% First order value:
    if (use_cluster == 0)
        D(i, i) = d_hist;
    else
    %%% Alternative option: give extra weights to nodes from different
    %%% clusters:
        D(i, i) = same_cluster + d_hist;
    end
    %%%

    

    j = (i+1:nm)';
    [xj, yj] = ind2sub([n m], j);

    % This value indicates whether one of the matched pairs have the same
    % cluster id and the other has different clusters id:
    d_cluster = double(((cluster1(xi) == cluster2(yi)) & (cluster1(xj) ~= cluster2(yj))) | ...
                       ((cluster1(xi) ~= cluster2(yi)) & (cluster1(xj) == cluster2(yj)))) * cluster_weight;

    dhist = H1(xj, :) - H2(yj, :);
    d_hist2 = sqrt(sum(dhist.^2,2));

    d_hist_diff = abs(d_hist - d_hist2);

    adj_x = adj1(xj, xi);
    adj_y = adj2(yj, yi);

    min_adj = min(adj_x, adj_y);
    min_adj(min_adj == 0) = 0.1;

    d_adj = (max(adj_x, adj_y) ./ min_adj) - 1;

    if (use_cluster == 0)
        %%% Second order values based on difference of histograms and
        %%% adjacencies:
        d = d_adj + d_hist_diff;
    else
        %%% Alternative second order value, adding extra weight to matches
        %%% where one of the matched pairs have the same
        %%% cluster id and the other has different clusters id:
        d = d_adj + d_cluster + d_hist_diff;
    end

    D(i, j) = d;
    D(j, i) = d;
end

Aff = exp(-D * sigma); % For sigma = 0.5, affinity for 1 distance is 0.6

t = toc(t_generate);
display(['Generated second order affinity matrix in ' num2str(t) ' seconds.']);

end

