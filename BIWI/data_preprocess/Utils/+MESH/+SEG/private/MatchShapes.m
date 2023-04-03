%%% MatchShapes(M1, M2)
% Matches two meshes according to their shape graph, using the
% provided symmetry (symmetry guided matching)
%
% Input: Two shape graphs as output from ShapePairMapper().
%        use_val = flag to determine whether the interval band (value) is
%                  used for the second order values or not.
% Output: A result set R containing the following fields:
%   R.matching: binary n x m matrix (n: number of nodes in M1 and m: in M2),
%               every row has at most 2 ones.
%   R.Aff:  original affinity matrix (see GenerateSecondOrder function).
%   R.x:    final continuous solution in matrix format n*m
%   R.M1, R.M2: same as input shapes
%
%%% If you use this code, please cite the following paper:
%  
%  Robust Structure-based Shape Correspondence
%  Yanir Kleiman and Maks Ovsjanikov
%  Computer Graphics Forum, 2018
%
%%% Copyright (c) 2017 Yanir Kleiman <yanirk@gmail.com>
function [ R ] = MatchShapes( M1, M2, use_val )

% Generate affinity matrix from second order data:
Aff = GenerateSecondOrder(M1.cluster_ind, M2.cluster_ind, M1.graph_dist, M2.graph_dist, use_val);

n = size(M1.adj, 1);
m = size(M2.adj, 1);

B = Aff;
ind = logical(1 - eye(size(Aff)));
% Normalizing off-diagonal in relation to diagonal:
B(ind) = B(ind) / (nnz(B));
x = firstEig(B);

% Discretize vector to find matching:
xm = reshape(x, n, m);
matching = Discretize(xm);


% Output results:
% matching: binary n x m matrix (n: number of nodes in M1 and m: in M2),
%           every row has at most 2 ones.
% Aff: original affinity matrix (see GenerateSecondOrder function).
% x:   final continuous solution in matrix format n*m

[R.matching, R.Aff, R.x, R.M1, R.M2] = deal(matching, Aff, xm, M1, M2);

    % Helper function to find first eigenvector (with highest eigenvalue):
    function [ e ] = firstEig(Aff)
        [V, ~] = eig(Aff);
        e = abs(V(:, end));
    end


end

