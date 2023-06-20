%%% ShapePairMapper
% Creates shape graphs of a pair of shapes in a joint
% manner by clustering the descriptor values and generating a shape graph
% from the connected components of the clusters. Every vertex is mapped to
% two clusters. A node is generated for each intersection of two clusters,
% and every two nodes which share the same cluster are connected by an edge.
%
% This is equivalent to the 1D construct of Mapper graphs with 100% overlap.
%
%%% If you use this code, please cite the following paper:
%
%  Robust Structure-based Shape Correspondence
%  Yanir Kleiman and Maks Ovsjanikov
%  Computer Graphics Forum, 2018
%
%%% Copyright (c) 2017 Yanir Kleiman <yanirk@gmail.com>
function [ M1, M2, perfect_score, MM1, MM2 ] = ShapePairMapper_new( S1, S2, nc_range, S1_opts, S2_opts)

S1.surface.nv = S1.nv;
S2.surface.nv = S2.nv;

if (nargin < 5)
    S2_opts.pcd = 0;
end
if (nargin < 4)
    S1_opts.pcd = 0;
end



if (S1_opts.pcd) % if the input is a triangle mesh -> convert to point cloud
    % Parse parameters:
    if (isfield(S1_opts, 'np'))
        np1 = S1_opts.np;
    else
        np1 = 3000;
    end
    if (isfield(S1_opts, 'noise'))
        noise_level1 = S1_opts.noise;
    else
        noise_level1 = 0;
    end
    
    % Turn shape 1 into a point cloud:
    vertices = [S1.surface.X S1.surface.Y S1.surface.Z];
    faces = S1.surface.TRIV;
    % Sample point cloud from mesh vertices:
    [S1.PCD, S1.pcd_map] = sample_mesh(vertices, faces, np1);
    % Add noise:
    S1.PCD = S1.PCD + noise_level1*(rand(size(S1.PCD))-1/2)*(max(max(S1.PCD)-min(S1.PCD)));
    % Update shape struct:
    S1.surface.X = S1.PCD(:, 1);
    S1.surface.Y = S1.PCD(:, 2);
    S1.surface.Z = S1.PCD(:, 3);
    S1.surface.nv = length(S1.surface.X);
end



if (S2_opts.pcd)
    % Parse parameters:
    if (isfield(S2_opts, 'np'))
        np2 = S2_opts.np;
    else
        np2 = 3000;
    end
    if (isfield(S2_opts, 'noise'))
        noise_level2 = S2_opts.noise;
    else
        noise_level2 = 0;
    end
    
    % Turn shape 2 into a point cloud:
    vertices = [S2.surface.X S2.surface.Y S2.surface.Z];
    faces = S2.surface.TRIV;
    % Sample point cloud from mesh vertices:
    [S2.PCD, S2.pcd_map] = sample_mesh(vertices, faces, np2);
    % Add noise:
    S2.PCD = S2.PCD + noise_level2*(rand(size(S2.PCD))-1/2)*(max(max(S2.PCD)-min(S2.PCD)));
    % Update shape struct:
    S2.surface.X = S2.PCD(:, 1);
    S2.surface.Y = S2.PCD(:, 2);
    S2.surface.Z = S2.PCD(:, 3);
    S2.surface.nv = length(S2.surface.X);
end

% This constant should always be 6:
knn = 6;        % number of nearest neighbors to consider for point clouds.
% knn = 6 = average connectivity of a triangular mesh

%%% Some method parameters:
nt = 15;        % number of time steps
min_t = 0.03;   % minimum time step
max_t = 0.25;   % maximum time step
neig = 100;     % number of eigenvectors in basis

% Steps are evenly spaced in logspace:
log_ts = linspace(log(min_t), log(max_t), nt);
ts = exp(log_ts);

%%% Alternate selection of paramters, for example using only 3 time steps:
% ts = [0.05 0.1 0.15];
% nt = 3;
%%% ... or only one time step:
% ts = 0.1;
% nt = 1;
%%%

fprintf('computing the input function...\n');
tic;

% Computing the laplacian basis of first shape:
if (S1_opts.pcd)
    L1 = lb_basis_pcd(S1.PCD, neig, knn);
else
    L1 = lb_basis_surface(S1, neig);
end

% Computing descriptors of first shape:
f1 = hks(L1, ts);


% Computing the laplacian basis of second shape:
if (S2_opts.pcd)
    L2 = lb_basis_pcd(S2.PCD, neig, knn);
else
    L2 = lb_basis_surface(S2, neig);
end

% Computing descriptors of second shape:
f2 = hks(L2, ts);


f1 = log(f1);
f2 = log(f2);

% For each column, compute the accumulated area up to the vertex's rank:
a1 = diag(L1.A);
a2 = diag(L2.A);
map = zeros(size(f2, 1), nt);

for i=1:nt
    f = f1(:, i);
    [~, ind1] = sort(f);
    % compute cummulative sum of areas for each vertex of shape 1:
    csa1 = cumsum(a1(ind1));
    csa1 = csa1 / csa1(end);
    
    f = f2(:, i);
    [~, ind2] = sort(f);
    % compute cummulative sum of areas for each vertex of shape 2:
    csa2 = cumsum(a2(ind2));
    csa2 = csa2 / csa2(end);
    
    % Create a map from f2 to f1:
    i1 = 1;
    for i2 = 1:size(f2, 1)
        % Finding the first index for which the cumulative sum of f2 is
        % greater than that of f1:
        while (i1 <= size(f1, 1)) && (csa1(i1 + 1) < csa2(i2))
            % When i1 == size(f1, 1) the loop will not be executed and it
            % will remain the last item for every subsequent i2.
            i1 = i1 + 1;
        end
        % Setting f2 to the value of f1 for this area:
        map(ind2(i2), i) = ind1(i1);
        f2(ind2(i2), i) = f1(ind1(i1), i);
    end
end

f12 = [f1; f2];


S1.f = f1;
S1.W = L1.W;
S2.f = f2;
S2.W = L2.W;

% Search for a number of intervals where the graphs are most similar:
perfect_score = false;
best_score_adj = 1000;
best_score_val = 1000;
best = 0;
best_M1 = [];
best_M2 = [];
MM1 = cell(1);
MM2 = cell(1);

i = 1;
for nc = nc_range
    
    % Since k means may produce a slightly different result in each run,
    % we perform the computation 3 times and choose the best matching
    % graphs.
    for r = 1:3
        
        display(['Computing graphs for nc = ' num2str(nc) ', r = ' num2str(r)]);
        
        % Compute joint k-means of the two shapes to get cluster centers:
        % (replicates = 3 for stability)
        [~, ~, ~, D] = kmeans(f12, nc, 'Replicates', 3, 'Distance', 'cityblock');
        [~, sort_ind] = sort(D, 2);
        
        idx = sort_ind(:, 1:2);
        idx1 = idx(1:length(f1), :);
        idx2 = idx(length(f1)+1:end, :);
        
        
        % Build Mapper graphs using cluster centers:
        M1 = MeshMapperSurfaceIdx(S1.name, S1, idx1);
        if (isempty(M1))
            % Could not create a decomposition of the shape:
            display('Decomposition failed! Try a different number of clusters.');
            continue;
        end
        if (size(M1.adj, 1) > 60)
            % Too many regions for effective matching:
            display(['Too many regions (' num2str(size(M1.adj, 1)) '), skipping.']);
            continue;
        end
        
        M2 = MeshMapperSurfaceIdx(S2.name, S2, idx2);
        if (isempty(M2))
            % Could not create a decomposition of the shape:
            display('Decomposition failed! Try a different number of clusters.');
            continue;
        end
        if (size(M2.adj, 1) > 60)
            % Too many regions for effective matching:
            display(['Too many regions (' num2str(size(M2.adj, 1)) '), skipping.']);
            continue;
        end
        
        MM1{i} = M1;
        MM2{i} = M2;
        i = i + 1;
        
        % Compare the graphs using the adjacency matrix (this is just a
        % hueristic but it works well):
        M1_desc_val = zeros(100, 1);
        
        hist_k = 10;
        hist_edges = (0:hist_k);
        % hist_weights = [0.3 0.2 0.1 0.1 ... 0.1], giving more weight to nodes
        % which are direct neighbors of the central node or 2 nodes away from it:
        hist_weights = ones(1, hist_k);
        hist_weights(1) = 0.3;
        hist_weights(2) = 0.2;
        
        H1 = histcounts(sum(M1.adj), hist_edges);
        
        % Find most central node by minimizing graph distance:
        [mv, mi] = min(sum(M1.graph_dist));
        % node value is graph distance from central node:
        sort_val1 = sort(M1.graph_dist(mi, :), 'descend');
        
        M1_desc_adj = H1 .* hist_weights;
        M1_desc_val(1:length(sort_val1)) = sort_val1;
        
        M2_desc_val = zeros(100, 1);
        
        H2 = histcounts(sum(M2.adj), hist_edges);
        
        % Find most central node by minimizing graph distance:
        [mv, mi] = min(sum(M2.graph_dist));
        % node value is graph distance from central node:
        sort_val2 = sort(M2.graph_dist(mi, :), 'descend');
        
        M2_desc_adj = H2 .* hist_weights;
        M2_desc_val(1:length(sort_val2)) = sort_val2;
        
        score_adj = norm(M1_desc_adj - M2_desc_adj);
        score_val = norm(M1_desc_val - M2_desc_val);
        
        if (score_adj < best_score_adj)
            best_score_val = score_val;
            best_score_adj = score_adj;
            best = nc;
            best_M1 = M1;
            best_M2 = M2;
        elseif (score_adj == best_score_adj)
            if (score_val < best_score_val)
                best_score_val = score_val;
                best = nc;
                best_M1 = M1;
                best_M2 = M2;
            end
        end
        
        display(['nc = ' num2str(nc) ', score_adj = ' num2str(score_adj) ', score_val = ' num2str(score_val)]);
        
        % If the histograms are exactly the same the graphs are isometric,
        % therefore a perfect match and better matching graphs cannot be found:
        if (best_score_adj == 0 && best_score_val == 0)
            perfect_score = true;
            break;
        end
        
    end % for r=1:4
    
    if (perfect_score)
        break;
    end
end

display(['best nc = ' num2str(best) ', best_score_adj = ' num2str(best_score_adj) ', best_score_val = ' num2str(best_score_val)]);

M1 = best_M1;
M2 = best_M2;

end

