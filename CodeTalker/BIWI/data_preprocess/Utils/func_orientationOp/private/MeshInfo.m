function mesh = MeshInfo(X, T, numEigs)

mesh.X = X;
mesh.T = T;
[mesh.E2V, mesh.T2E, mesh.E2T, mesh.T2T, mesh.V2T] = connectivity(mesh.T);

mesh.nf = size(mesh.T,1);
mesh.nv = size(mesh.X,1);
mesh.ne = size(mesh.E2V,1);
numEigs = min(numEigs, mesh.nv);

% Normals and areas
mesh.normal = cross(mesh.X(mesh.T(:,1),:) - mesh.X(mesh.T(:,2),:), mesh.X(mesh.T(:,1),:) - mesh.X(mesh.T(:,3),:));
mesh.area = sqrt(sum(mesh.normal.^2, 2))/2;
mesh.normal = mesh.normal./repmat(sqrt(sum(mesh.normal.^2, 2)), [1, 3]);

A = sparse(mesh.T, repmat((1:mesh.nf)', [3,1]), repmat(mesh.area, [3,1]), mesh.nv, mesh.nf);
mesh.Nv = A*mesh.normal;
mesh.Nv = mesh.Nv./repmat(sqrt(sum(mesh.Nv.^2,2)), [1,3]);

% Edge length
mesh.SqEdgeLength = sum((mesh.X(mesh.E2V(:,1),:) - mesh.X(mesh.E2V(:,2),:)).^2, 2);

% Eigenstuff
% [mesh.cotLaplacian, mesh.Av] = cotLaplacian(mesh.X, mesh.T);
[mesh.cotLaplacian,~] = per_edge_laplacian(abs(mesh.T2E), mesh.E2V, mesh.area, mesh.SqEdgeLength);
mesh.cotLaplacian = -mesh.cotLaplacian;
[mesh.Ae,~] = per_edge_area(mesh.E2T, mesh.E2V, mesh.area);

try
    [mesh.laplaceBasis, mesh.eigenvalues] = eigs(mesh.cotLaplacian, mesh.Ae, numEigs, 1e-5);
catch
    % In case of trouble make the laplacian definite
    [mesh.laplaceBasis, mesh.eigenvalues] = eigs(mesh.cotLaplacian - 1e-8*speye(mesh.nv), mesh.Ae, numEigs, 'sm');
end
mesh.eigenvalues = diag(mesh.eigenvalues);

mesh.T2VMat = T2VMat( T, mesh.area );

end
