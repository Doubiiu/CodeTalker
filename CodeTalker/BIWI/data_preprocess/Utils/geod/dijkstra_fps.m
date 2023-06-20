function idx = dijkstra_fps(shape, k)

nv = size(shape.surface.X, 1);

idx = randi(nv,1);
dists = dijkstra_to_all(shape, idx);
idx = find(dists == max(dists), 1, 'first');

for i = 1:k-1
    dists = dijkstra_to_all(shape, idx);
    
    maxi = find(dists == max(dists), 1, 'first');
    idx = [idx; maxi];
end

idx = idx(1:end);