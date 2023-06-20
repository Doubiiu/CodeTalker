function C2 = normalize_shape(C)
    center = mean(C);
    C2 = C-repmat(center,size(C,1),1);
    
    scale = max(max(C2)-min(C2));
    C2 = C2/scale;
end