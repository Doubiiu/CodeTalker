function diam = shape_diameter(X, T)

S.surface.X = X(:,1);
S.surface.Y = X(:,2);
S.surface.Z = X(:,3);
S.surface.TRIV = T;
S.surface.nv = size(X,1);

% Shape diameter
[d,~] = dijkstra_to_all(S.surface, randi(size(X,1)));
[~,i] = max(d);
[d,~] = dijkstra_to_all(S.surface, i);
diam = max(d);
