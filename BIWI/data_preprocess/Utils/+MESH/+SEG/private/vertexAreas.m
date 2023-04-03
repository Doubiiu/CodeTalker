function A = vertexAreas(X, T)

% Triangle areas
N = cross(X(T(:,1),:)-X(T(:,2),:), X(T(:,1),:) - X(T(:,3),:));
At = normv(N);

% Vertex areas = sum triangles near by
I = [T(:,1);T(:,2);T(:,3)];
J = ones(size(I));
S = [At(:,1);At(:,1);At(:,1)];
nv = size(X,1);
A = sparse(I,J,S,nv,1);