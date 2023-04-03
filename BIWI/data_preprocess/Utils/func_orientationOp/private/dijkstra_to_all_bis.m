function [ D, I ] = dijkstra_to_all_bis( shape, sources )
%DIJKSTRA_TO_ALL_BIS Summary of this function goes here
%   Detailed explanation goes here
    S = shape;
    
    if(size(sources,2) > size(sources,1))
        sources = sources';
    end
    
    if(size(sources,2) > 1)
        error('sources must be stored in a vector');
    end
    
    [D, I] = comp_geodesics_to_all(double(S.X(:,1)), double(S.X(:,2)), double(S.X(:,2)), ...
        double(S.T'), sources, 1);

end

