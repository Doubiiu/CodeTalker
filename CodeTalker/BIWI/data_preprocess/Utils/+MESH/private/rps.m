function idx = rps(surface,k)
    C = [surface.X surface.Y surface.Z];
    nv = size(C,1);

    idx = unique(randi(nv,2*k,1));
    
    idx = idx(1:min(k,length(idx)),1);
end