function plot_function_tosca(shape, f, S)
    if (nargin == 1)
        f = shape.X.*shape.Y.*shape.Z;
    end
    trimesh(shape.TRIV, shape.X, shape.Y, shape.Z, f, ...
        'EdgeColor', 'interp', 'FaceColor', 'interp');
%    view([-88 28]);
    axis equal;
    axis off;
end