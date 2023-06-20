function area = surfaceArea(mesh)
    mesh = mesh.surface;
    X = [mesh.X mesh.Y mesh.Z]; T = mesh.TRIV;

    v = cross(X(T(:,1),:) - X(T(:,2),:), X(T(:,1),:) - X(T(:,3),:));
    Ar = sqrt(sum(v.^2,2))/2;
    area = sum(Ar);
end
