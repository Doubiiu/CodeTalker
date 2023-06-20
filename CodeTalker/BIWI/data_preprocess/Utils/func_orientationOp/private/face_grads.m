function G = face_grads(mesh, f)

X = mesh.surface.VERT;
T = mesh.surface.TRIV;
Nf = mesh.normals_face;

v1 = X(T(:,1),:);
v2 = X(T(:,2),:);
v3 = X(T(:,3),:); 

Ar = 0.5*sum((cross(v3-v2,v1-v2)).^2,2); % area per face

Ar = repmat(Ar, 1, 3);
G = repmat(f(T(:,1)),1,3).*cross(Nf, v3 - v2)./(2*Ar) + ...
    repmat(f(T(:,2)),1,3).*cross(Nf, v1 - v3)./(2*Ar) + ...
    repmat(f(T(:,3)),1,3).*cross(Nf, v2 - v1)./(2*Ar);
