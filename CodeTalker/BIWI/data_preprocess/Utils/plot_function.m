function plot_function(shape, f, para)
    
    rot_flag = false;
    view_angle = [0, 0]; 
    
    if nargin > 2
        if isfield(para, 'rot_flag'), rot_flag = para.rot_flag; end
        if isfield(para, 'view_angle'), view_angle = para.view_angle; end
    end
    if ~isfield(shape, 'surface'), shape.surface = shape; end
    
    if norm(f) > 1e-7
        f = f/max(abs(f)); 
    end
    
    if rot_flag
        trimesh(shape.surface.TRIV, shape.surface.Y, shape.surface.Z, shape.surface.X, f, ...
            'EdgeColor', 'flat', 'FaceColor', 'interp', ...
            'AmbientStrength', 0.35, 'DiffuseStrength', 0.65,  'FaceLighting', 'gouraud', ...
            'SpecularExponent', 10, 'BackFaceLighting', 'reverselit', 'LineStyle', 'none');
        view(view_angle);
        axis equal;
        axis off;
    else
        trimesh(shape.surface.TRIV, shape.surface.X, shape.surface.Y, shape.surface.Z, f, ...
            'EdgeColor', 'flat', 'FaceColor', 'interp', ...
            'AmbientStrength', 0.35, 'DiffuseStrength', 0.65,  'FaceLighting', 'gouraud', ...
            'SpecularExponent', 10, 'BackFaceLighting', 'reverselit', 'LineStyle', 'none');
        view(view_angle);
        axis equal;
        axis off;
    end
    
    colormap('hot');
    colormap(flipud(colormap)); 
    set(gca, 'Projection', 'perspective');    

    camlight('headlight'); 
end