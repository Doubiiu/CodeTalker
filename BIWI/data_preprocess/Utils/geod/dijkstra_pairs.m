% Function to compute the geodesic distances on a shape between a set of 
% pairs of vertices using Dijkstra's algorithm. 
% Pairs must be given as a Nx2 matrix, where each row 
% represents a pair vid1, vid2 to compute the distance.
%
% NOTE: vertex ids start at 1 (Matlab-style), NOT at 0 (C++ style).
%
% Output: a Nx1 matrix of geodesic distances.
function D = dijkstra_pairs(shape, pairs)
    S = shape.surface;
    
    if (size(pairs,2) ~= 2)
        error('pairs must be a Nx2 matrix');
    end
    
    if (min(min(pairs)) < 1)
        error('vertex ids should start at 1');
    end
        
    D = comp_geodesics_pairs(double(S.X), double(S.Y), double(S.Z), ...
                             double(S.TRIV'), double(pairs'), 1);
end