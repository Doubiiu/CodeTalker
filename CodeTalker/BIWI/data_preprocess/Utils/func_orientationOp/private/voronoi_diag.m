function [pt, id, An, diam] = voronoi_diag(X, T, fps_samples, idx_init, ifplot)

if ~exist('idx_init', 'var')
    idx_init = [];
end

if ~exist('ifplot', 'var')
    ifplot = false;
end

S.surface.X = X(:,1);
S.surface.Y = X(:,2);
S.surface.Z = X(:,3);
S.surface.TRIV = T;
S.surface.nv = size(X,1);

fprintf('Sampling the source shape with %d points...', fps_samples);tic;
pt = dijkstra_fps(S, fps_samples, idx_init);
fprintf('done\n');toc;

fprintf('Computing the intrinsic Voronoi diagram...');tic;
[~,id] = dijkstra_to_all(S.surface, pt);
fprintf('done\n');toc;

% Compute the connectivity of the Voronoi diagram
An = mesh_components(S, id);

% Shape diameter
if nargout > 3
    [d,~] = dijkstra_to_all(S.surface, 1);
    [~,i] = max(d);
    [d,~] = dijkstra_to_all(S.surface, i);
    diam = max(d);
end

if ifplot
    figure;
    spy(An);
    title('Voronoi Connectivity');

    labels = {};
    for k = 1:fps_samples
        labels{k} = num2str(k);
    end
    
    figure;
    subplot(1,2,1);
    plot_graph_wbgl(An,labels);
    title('Voronoi Graph');
    subplot(1,2,2);
    trisurf(T, X(:,1), X(:,2), X(:,3), id);
    text(X(pt,1), X(pt,2), X(pt,3), labels, 'VerticalAlignment','bottom', 'HorizontalAlignment','right')
    axis equal; axis off;
    title('Voronoi Surface');
end