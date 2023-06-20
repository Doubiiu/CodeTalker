function [idx,dist] = fps_geodesic(shape, k)
% farthest-point-sampling on mesh w.r.t. geodeisic distance
% return k vtx index (and the geod_dist of these k samples)
nv = size(shape.surface.X, 1);

idx = randi(nv,1);
dists = geodesics_to_all(shape, idx);
idx = find(dists == max(dists), 1, 'first');

for i = 1:k-1
    dists = geodesics_to_all(shape, idx);
    
    maxi = find(dists == max(dists), 1, 'first');
    idx = [idx; maxi];
end

idx = idx(1:end);

% compute the geodesic distance matrix of points [idx]
if nargout > 1  
    ind = find(triu(ones(k),1) == 1);
    [subi,subj] = ind2sub([k,k],ind);
    pt_pair = [idx(subi),idx(subj)];
    D = geodesics_pairs(shape, pt_pair);
    dist = zeros(k);
    dist(ind) = D;
    dist = dist + dist';
end
end

