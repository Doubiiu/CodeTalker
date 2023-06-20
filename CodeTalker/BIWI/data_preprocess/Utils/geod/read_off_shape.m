function shape = read_off_shape(offfullname)
    fid = fopen(offfullname,'rt');
    off = textscan(fid, '%s', 1);
    nv = textscan(fid, '%d', 1);
    nv = nv{1};
    nt = textscan(fid, '%d', 1);
    nt = nt{1};
    tmp = textscan(fid, '%d', 1);

    verts = textscan(fid, '%f %f %f', nv);
    shape.surface.X = verts{1};
    shape.surface.Y = verts{2};
    shape.surface.Z = verts{3};
    tri = textscan(fid, '%d %d %d %d', nt);
    tri = [tri{2} tri{3} tri{4}];
    tri = tri+1;
    shape.surface.TRIV = double(tri);
    shape.surface.nv = size(shape.surface.X,1);
    fclose(fid);
    
    shape.surface.VERT = [verts{1}, verts{2}, verts{3}]; 
end
