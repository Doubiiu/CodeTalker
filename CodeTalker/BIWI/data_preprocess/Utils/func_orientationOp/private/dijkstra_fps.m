function idx = dijkstra_fps(shape, k, idx_init)

nv = size(shape.surface.X, 1);

if ~exist('idx_init', 'var') || isempty(idx_init)
    idx_init = randi(nv,1);
    dists = dijkstra_to_all(shape.surface, idx_init);
    idx_init = find(dists == max(dists), 1, 'first');
end

idx = idx_init;
for i = 1:k-length(idx_init)
    dists = dijkstra_to_all(shape.surface, idx);
    
    maxi = find(dists == max(dists), 1, 'first');
    idx = [idx; maxi];
end

idx = idx(1:end);