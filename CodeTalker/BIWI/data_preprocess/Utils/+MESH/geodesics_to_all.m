function D = geodesics_to_all(shape, sources)
    S = shape.surface;
    
    if(size(sources,2) > size(sources,1))
        sources = sources';
    end
    
    if(size(sources,2) > 1)
        error('sources must be stored in a vector');
    end
    
    D = comp_geodesics_to_all(double(S.X), double(S.Y), double(S.Z), ...
                              double(S.TRIV'), sources,1);
end