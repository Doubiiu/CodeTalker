function M = mass_matrix(mesh)

T = mesh.surface.TRIV; 
X = mesh.surface.VERT;
v1 = X(T(:,1),:);
v2 = X(T(:,2),:);
v3 = X(T(:,3),:); 

Ar = 0.5*sum((cross(v3-v2,v1-v2)).^2,2); % area per face
nv = mesh.nv;

I = [T(:,1);T(:,2);T(:,3)];
J = [T(:,2);T(:,3);T(:,1)];
Mij = 1/12*[Ar; Ar; Ar];
Mji = Mij;
Mii = 1/6*[Ar; Ar; Ar];
In = [I;J;I];
Jn = [J;I;I];
Mn = [Mij;Mji;Mii];
M = sparse(In,Jn,Mn,nv,nv);
end