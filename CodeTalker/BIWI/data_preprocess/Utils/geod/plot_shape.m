function plot_shape(shape, para)
    
    if ~isfield(shape, 'surface'), shape.surface = shape; end
    f = zeros(length(shape.surface.X), 1); 
    
    plot_function(shape, f, para); 
    caxis([0, 1]); 



end