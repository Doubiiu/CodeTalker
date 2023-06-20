function vtx_neigh = find_one_ring_neigh(S)
if isfield(S,'W')
    W = S.W;
else
    W = cotLaplacian(get_mesh_vtx_pos(S), S.surface.TRIV);
end
% compute the 1-ring neighbor
get_neighbor = @(W) cellfun(@(x,i) setdiff(reshape(find(x),[],1),i),...
    mat2cell(W,ones(size(W,1),1),size(W,2)),num2cell(1:size(W,1))','UniformOutput',false);
vtx_neigh = get_neighbor(W);
end