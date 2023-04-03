function S = compute_normalize(S)
%Compute the eigen vectors of the cotangent Laplacian matrix

% A: mixed voronoi area weights
[W, A] = cotLaplacian(get_mesh_vtx_pos(S), S.surface.TRIV);
% A: one-ring neighbor area weights
% A = vertexAreas(get_mesh_vtx_pos(S), S.surface.TRIV);

A = sparse(1:length(A), 1:length(A), A);
S.A = A;
S.W = W;
S.area = diag(S.A);
S.sqrt_area = sqrt(sum(S.area));

end
