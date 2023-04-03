function visualize_map_lines_vertices(S1, S2, map, nsamples, prealign)
    C1 = normalize_shape([S1.X]);
    C2 = normalize_shape([S2.X]);
    
    if(nargin>4 && prealign==true)
        mu1 = mean(C1);
        mu2 = mean(C2(map));

        C1 = bsxfun(@plus,C1,-mu1);
        C2 = bsxfun(@plus,C2,-mu2);
        
        W = C2(map,:)\C1;
        [s v d] = svd(W);
        Cnew = s*d';
        
        C1 = (Cnew*C1')';        
    end
    
    g1 = normalize_function(0.1,0.99,C2(:,1));
    g2 = normalize_function(0.1,0.99,C2(:,2));
    g3 = normalize_function(0.1,0.99,C2(:,3));
    
    f1 = g1(map);
    f2 = g2(map);
    f3 = g3(map);
    
    trimesh(S1.T, C1(:,1), C1(:,2), C1(:,3), ...
        'FaceVertexCData', [f1 f2 f3], 'FaceColor','interp', 'FaceAlpha', 0.8, 'EdgeColor', 'none'); axis equal;
    hold on;
    
%    figure(2);
    xdiam = 4/2*(max(C1(:,1))-min(C1(:,1)));
    trimesh(S2.T, C2(:,1)+xdiam, C2(:,2), C2(:,3), ...
        'FaceVertexCData', [g1 g2 g3], 'FaceColor','interp', 'FaceAlpha', 0.8, 'EdgeColor', 'none'); axis equal;
    
    
    samples = round(linspace(1,size(C1,1),nsamples));
    target_samples = map(samples);
    
    Xstart = C1(samples,1)'; Xend = C2(target_samples,1)';
    Ystart = C1(samples,2)'; Yend = C2(target_samples,2)';
    Zstart = C1(samples,3)'; Zend = C2(target_samples,3)';

    Xend = Xend+xdiam;
    Colors = [f1 f2 f3];
    ColorSet = Colors(samples,:);
    set(gca, 'ColorOrder', ColorSet);
    plot3([Xstart; Xend], [Ystart; Yend], [Zstart; Zend]);
end