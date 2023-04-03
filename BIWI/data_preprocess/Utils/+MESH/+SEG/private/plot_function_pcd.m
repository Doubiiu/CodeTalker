function [ ] = plot_function_pcd( pcd, f )
% PLOT_FUNCTION_PCD Plots a point cloud and colors it by the function.

scatter3(pcd(:, 1), pcd(:, 2), pcd(:, 3), 12, f, 'filled', ...
    'MarkerFaceAlpha', 1, ...
    'MarkerEdgeColor', [0.5 0.5 0.5], ...
    'MarkerEdgeAlpha', 1, ...
    'LineWidth', 0.5);

axis equal;
axis off;

% Set aspect ratio
daspect([1 1 1]);



end

