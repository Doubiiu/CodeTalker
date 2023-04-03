function plot_function(shape, f, FaceColor)
    if (nargin == 1)
        f = shape.X.*shape.Y.*shape.Z;
    end
    
    if (nargin < 3)
        FaceColor = 'flat';
    end
    
    
    trimesh(shape.TRIV, shape.X, shape.Y, shape.Z, f, ...
        'EdgeColor', 'none', 'FaceColor', FaceColor, 'FaceLighting','flat');
    axis equal;
    axis off;
end