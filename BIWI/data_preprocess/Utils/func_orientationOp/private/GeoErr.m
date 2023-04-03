function [dist, cdf, diam] = GeoErr(X, T, pi, piEx, Sym)

if exist('Sym', 'var')
    symmetry = true;
else
    symmetry = false;
end

pairs = [pi, piEx];

surface.X = X(:,1);
surface.Y = X(:,2);
surface.Z = X(:,3);
surface.TRIV = T;

% Shape diameter
[d,~] = dijkstra_to_all(surface, 1);
[~,i] = max(d);
[d,~] = dijkstra_to_all(surface, i);
diam = max(d);

dist = dijkstra_pairs(surface, pairs);
if (symmetry == true)
    dist = min(dist, dijkstra_pairs(surface, [pi, Sym(piEx)]));
end

dist = dist/diam;

dsort = sort(dist);
cdf = zeros(length(dist), 1);
for i = 1:length(dist)
    cdf(i) = sum(dist <= dsort(i));
end
cdf = cdf/length(dist);

end
