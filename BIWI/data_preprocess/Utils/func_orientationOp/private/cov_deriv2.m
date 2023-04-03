function [op, D, f2vOp] = cov_deriv2(mesh, Vf, basis, basisi);
X = mesh.vertices;
T = mesh.triangles;
nf = mesh.nf;
nv = mesh.nv;

Nf = mesh.N;

v1 = X(T(:,1),:);
v2 = X(T(:,2),:);
v3 = X(T(:,3),:); 
C1 = v3 - v2;
C2 = v1 - v3;
C3 = v2 - v1;
Jc{1} = cross(Nf, C1);
Jc{2} = cross(Nf, C2);
Jc{3} = cross(Nf, C3);

for i=1:3
    I = [T(:,i)];
    J = [1:nf]';
    S = ones(size(I));
    f2v{i} = sparse(I,J,S,nv,nf);
end

for i=1:3
    I = [1:nf]';
    J = [1:nf]';
    S = dot(Jc{i}/2,Vf,2)/3;
    JcVf{i} = sparse(I,J,S,nf,nf);
end

% op = sparse(nv,nv);
% for i=1:3
%     for j=1:3
%         op = op + f2v{i}*JcVf{j}*f2v{j}';
%     end
% end
% 

op = sparse(nf,nv);
for j=1:3
    op = op + JcVf{j}*f2v{j}';
end

M = sparse(nv,nf);
for i=1:3
    M = M + f2v{i};
end
f2vOp = spdiags(1./mesh.origAreaWeights,0,nv,nv)*M;
op = f2vOp*op;

D = basisi * op * basis;