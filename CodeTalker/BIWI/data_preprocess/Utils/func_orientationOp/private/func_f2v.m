function g = func_f2v(mesh,f)

T = mesh.triangles;
% F = repmat(f,1,3);
% F = F.*mesh.VA;
% 
% I = [T(:,1); T(:,2); T(:,3)];
% J = ones(size(I));
% S = [F(:,1); F(:,2); F(:,3)];
% 
% g = sparse(I,J,S,mesh.nv,1);
% g = spdiags(1./mesh.origAreaWeights,0,mesh.nv,mesh.nv)*g;
% g = full(g);

J = [T(:,1); T(:,2); T(:,3)];
I = [1:mesh.nf, 1:mesh.nf, 1:mesh.nf]';
S = 1/3*ones(size(I));
A = sparse(I,J,S,mesh.nf,mesh.nv);

warning off; g = A\f; warning on;
