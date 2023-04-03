function op = vf2op(mesh, Vf)

X = mesh.surface.VERT;
T = mesh.surface.TRIV;
nf = mesh.nf;
nv = mesh.nv;

Nf = mesh.normals_face;

v1 = X(T(:,1),:);
v2 = X(T(:,2),:);
v3 = X(T(:,3),:); 
C1 = v3 - v2;
C2 = v1 - v3;
C3 = v2 - v1;
Jc1 = cross(Nf, C1);
Jc2 = cross(Nf, C2);
Jc3 = cross(Nf, C3);

I = [T(:,1);T(:,2);T(:,3)];
J = [T(:,2);T(:,3);T(:,1)];
Sij = 1/6*[dot(Jc2,Vf,2); dot(Jc3,Vf,2); dot(Jc1,Vf,2)];
Sji = 1/6*[dot(Jc1,Vf,2); dot(Jc2,Vf,2); dot(Jc3,Vf,2)];
In = [I;J;I;J];
Jn = [J;I;I;J];
Sn = [Sij;Sji;-Sij;-Sji];
W = sparse(In,Jn,Sn,nv,nv);

M = mass_matrix(mesh);
%op = spdiags(1./mesh.origAreaWeights,0,nv,nv)*W;
op = spdiags(1./sum(M,2),0,nv,nv)*W;
end