%%% MeshMapperSurfaceIdx(filename, S, idx)
% Maps a shape to a graph and outputs the adjacency matrix and the value
% of each node, based on a precomputed clustering of the points on the
% shape. The nearest clusters to each point are given as input in idx
% matrix (first column is nearest, second is second nearest, etc).
%
% Input: filename = shape file name to be used in the output structure.
%        S = shape structure given from read_off_shape
%        idx = a matrix of ids of the nearest clusters to each point.
%
% Output: M.val = value of each region. The value is computed as distance
%           on the shape graph from the root node (most central node in the
%           graph). Regions that belong to the same cluster should generally
%           have the same value.
%         M.adj = adjacency graph: a matrix where cell (i, j) is 1 if and
%           only if regions i and j are connected in the shape graph
%         M.GT = "ground truth" values, i.e. the region id for each point
%           on the shape (before the matching). This is used to evaluate the
%           matching between shapes which have a known correspondence between them.
%         M.shape = the shape structure coming from read_off_shape.
%         M.graph_dist = for each cell (i, j) the graph distance between
%           regions i and j.
%         M.ints = total number of clusters / intervals, before they are
%           broken into separate components (or regions).
%
%%% If you use this code, please cite the following paper:
%  
%  Robust Structure-based Shape Correspondence
%  Yanir Kleiman and Maks Ovsjanikov
%  Computer Graphics Forum, 2018
%
%%% Copyright (c) 2017 Yanir Kleiman <yanirk@gmail.com>
function [ M ] = MeshMapperSurfaceIdx( filename, S, idx)

nc = max(max(idx));

M.shape = S;
M.filename = filename;

fprintf('Computing the Mapper graph with %d clusters...\n', nc); tic;

% A cluster can contain several connected components (e.g. two hands), so
% here we split clusters into regions:
C = function_components(S, idx(:, 1));
[~,~,c] = unique(C);
GT = c;

n = max(GT);
% Translation table between the connected components and the individual
% clusters:
cluster_map = zeros(n, 1);
for i=1:n
    cluster_map(i) = idx(find(GT == i, 1, 'first'), 1);
end

An = zeros(n,n);
src_ind = zeros(n, 1);

% For each region, find connected 'region of influence' of secondary indices:
for i=1:n
    F = zeros(length(idx), 1);
    % Set indicator to include the region:
    F(GT == i) = 1;
    
    first = find(GT == i, 1, 'first');
    
    % Source index of region i:
    src = idx(first, 1);
    
    F(idx(:, 2) == src) = 1;
    % Compute the connected components of the indicator function of the cluster:
    C = function_components(S, F);

    % Find the connected component indicator of the relevant component:
    cc = C(first);

    % Find the primary index of every secondary component and connect it to
    % region i:
    primaries = unique(GT(C == cc));
    
    An(i, primaries) = 1;
    An(primaries, i) = 1;
end

[~,~,conn] = dmperm(An);
if (length(conn) > 2)
    % There are several connected components in the matrix, therefore it
    % should not be used. This can happen when the shape is not well
    % connected e.g. a sparse point cloud is given as input.
    M = [];
    return;
end

adj = An;

graph_dist = ComputeAdj(An);

% Note: values are no longer used in further computations.
% Find most central node by minimizing graph distance:
[mv, mi] = min(sum(graph_dist));
% node value is graph distance from central node:
val = graph_dist(mi, :);

% Get the positions of each region in the vertices list:
[~, indGT, ~] = unique(GT);
% Get the cluster index for each region:
cluster_ind = idx(indGT, 1);

% Output important values to struct:
[M.val, M.adj, M.GT, M.shape, M.graph_dist, M.ints, M.cluster_ind] = deal(val, adj, GT, S, graph_dist, nc, cluster_ind);

end

