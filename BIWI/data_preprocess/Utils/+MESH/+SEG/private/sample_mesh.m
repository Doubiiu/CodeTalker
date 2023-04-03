% Samples n points on a mesh given by vertices and faces.
% points = the x,y,z positions of sampled points.
% map = for each point the closest vertex on the mesh, for evaluation purpose.
%
%%% If you use this code, please cite the following paper:
%  
%  Robust Structure-based Shape Correspondence
%  Yanir Kleiman and Maks Ovsjanikov
%  Computer Graphics Forum, 2018
%
%%% Copyright (c) 2016 Yanir Kleiman <yanirk@gmail.com>
function [points, map] = sample_mesh(vertices, faces, n )

areas = computeArea(vertices, faces);

cum_areas = cumsum(areas);
cum_areas = cum_areas - cum_areas(1);
cum_areas = cum_areas / cum_areas(end);

points = zeros(n, 3);
map = zeros(n, 1);

for i=1:n
    % Choose face by area:
    r = rand;
    faceind = binarysearch(cum_areas,r(1));
    v = faces(faceind,:);
    va = vertices(v(1),:);
    vb = vertices(v(2),:);
    vc = vertices(v(3),:);
    
    % Choose position on vertex:
    rx = rand;
    ry = rand;
    
    ra = (1-sqrt(rx));
    rb = sqrt(rx)*(1-ry);
    rc = sqrt(rx)*ry;
    
    p = ra*va + rb*vb + rc*vc;
    %p = (1-sqrt(rx))*faces(index1,1) + sqrt(rx)*(1-ry)*faces(index1,2) + sqrt(rx)*ry*faces(index1,3);

    points(i, :) = p;
    
    % Finding the closest vertex on the shape:
    if (ra > rb && ra > rc)
        map(i, :) = v(1);
    elseif (rb > rc)
        map(i, :) = v(2);
    else
        map(i, :) = v(3);
    end;
end


end