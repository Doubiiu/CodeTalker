% 2018-04-02
% Given the 1ring neighborhood list: 
%   Neigh_list{vid} gives the neighbors of vid-th vertex
% Return the n-ring neighbors of vid-th vertex (excluding vid-th vertex)
function [neigh] = find_nRing_neigh(Neigh_list,vid,n)
    neigh = Neigh_list{vid};
    for i = 1:n-1
        neigh = vertcat(Neigh_list{neigh});
        neigh = unique(neigh);
    end
    neigh = setdiff(neigh, vid);
end