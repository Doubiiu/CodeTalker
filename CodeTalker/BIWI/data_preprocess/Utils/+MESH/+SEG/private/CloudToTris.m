function [ M ] = CloudToTris( M )
% Generates triangles from a point cloud using the knn of each point.
% The result is a non-manifold mesh!

knn = 10;

pcd = M.shape.PCD;
n = length(pcd);


% Compute the k-nearest neighbors of each point in the point cloud.
NN = annquery(pcd', pcd', knn+1);
% remove the first nearest neighbor (the point itself)
NN = NN(2:end,:)';

perm = randperm(knn);

T = zeros((knn-1)*n, 3);

ind = 1;
for i=1:n
    for j=1:knn-1
        T(ind, :) = [i, NN(i, perm(j)), NN(i, perm(j+1))];
        
        ind = ind + 1;
    end
end

M.shape.surface.TRIV = T;

end
