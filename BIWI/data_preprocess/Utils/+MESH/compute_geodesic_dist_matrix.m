function D = compute_geodesic_dist_matrix(S, samples)
% Compute the Geodesic distance matrix of a mesh (or a set of samples)
M = S.surface;
M.n = S.nv;

if nargin==1 || isempty(samples)
    samples = 1:M.n;
end

fprintf('Compute geodesic distance matrix for %d samples...',length(samples)); tic;

march = fastmarchmex('init', int32(M.TRIV-1), double(M.VERT(:,1)), double(M.VERT(:,2)), double(M.VERT(:,3)));

D = zeros(length(samples));

for i=1:length(samples)
%     fprintf('(%d/%d)\n', i, length(samples));
    source = inf(M.n,1);
    source(samples(i)) = 0;
    d = fastmarchmex('march', march, double(source));
    D(:,i) = d(samples);
end

fastmarchmex('deinit', march);

D = 0.5*(D+D');
t = toc; fprintf('done:%.4fs\n',t);
end
