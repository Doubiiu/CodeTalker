% Compute the cotangent weight Laplacian.
% W is the symmetric cot Laplacian, and A are the area weights (mixed voronoi area) 
function [W,A] = cotLaplacian(X, T)
nv = size(X,1);
nf = size(T,1);

% Find orig edge lengths and angles
L1 = normv(X(T(:,2),:)-X(T(:,3),:));
L2 = normv(X(T(:,1),:)-X(T(:,3),:));
L3 = normv(X(T(:,1),:)-X(T(:,2),:));
EL = [L1,L2,L3];
A1 = (L2.^2 + L3.^2 - L1.^2) ./ (2.*L2.*L3);
A2 = (L1.^2 + L3.^2 - L2.^2) ./ (2.*L1.*L3);
A3 = (L1.^2 + L2.^2 - L3.^2) ./ (2.*L1.*L2);
A = [A1,A2,A3];
A = acos(A);

% The Cot Laplacian 
I = [T(:,1);T(:,2);T(:,3)];
J = [T(:,2);T(:,3);T(:,1)];
S = 0.5*cot([A(:,3);A(:,1);A(:,2)]);
In = [I;J;I;J];
Jn = [J;I;I;J];
Sn = [-S;-S;S;S];
W = sparse(double(In), double(Jn), double(Sn), nv, nv);

% Compute the areas. Use mixed weights
% Voronoi areas
cA = 0.5*cot(A);
vp1 = [2,3,1]; vp2 = [3,1,2];
At = 1/4 * (EL(:,vp1).^2 .* cA(:,vp1) + EL(:,vp2).^2 .* cA(:,vp2));

% Triangle areas
N = cross(X(T(:,1),:)-X(T(:,2),:), X(T(:,1),:) - X(T(:,3),:));
Ar = normv(N);

% Use barycentric area when cot is negative
locs = find(cA(:,1) < 0);
At(locs,1) = Ar(locs)/4; At(locs,2) = Ar(locs)/8; At(locs,3) = Ar(locs)/8;
locs = find(cA(:,2) < 0);
At(locs,1) = Ar(locs)/8; At(locs,2) = Ar(locs)/4; At(locs,3) = Ar(locs)/8;
locs = find(cA(:,3) < 0);
At(locs,1) = Ar(locs)/8; At(locs,2) = Ar(locs)/8; At(locs,3) = Ar(locs)/4;

% Vertex areas = sum triangles near by
I = [T(:,1);T(:,2);T(:,3)];
J = ones(size(I));
S = [At(:,1);At(:,2);At(:,3)];
A = sparse(double(I),double(J),double(S),nv,1);
end