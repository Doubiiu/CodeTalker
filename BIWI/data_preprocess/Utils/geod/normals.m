function mesh = normals(mesh)
% computes mesh normals per face and per vertex

F = mesh.surface.TRIV'; 
V = [mesh.surface.X'; mesh.surface.Y'; mesh.surface.Z'];

mesh.Nf = zeros(3, size(F,2));
mesh.Nf = cross(V(1:3,F(2,:)) - V(1:3,F(1,:)), V(1:3,F(3,:)) - V(1:3, F(1,:)));
Fa = 0.5 * sqrt( sum( mesh.Nf.^2, 1) );
for i = 1:size(F,2)
    mesh.Nf(:, i) = mesh.Nf(:, i) ./ sqrt( sum( mesh.Nf(:, i).^2 ) );
end

mesh.Nv = zeros(3, size(V, 2));

for i = 1:size(F,2)
    for j = 1:3
        if j == 1
            la = sum((V( 1:3, F(1, i) ) - V( 1:3, F(2, i) )).^2);
            lb = sum((V( 1:3, F(1, i) ) - V( 1:3, F(3, i) )).^2);
            W = Fa(i) / (la * lb);
            if (isinf(W) || isnan(W)) W = 0; end
        elseif j == 2
            la = sum((V( 1:3, F(2, i) ) - V( 1:3, F(1, i) )).^2);
            lb = sum((V( 1:3, F(2, i) ) - V( 1:3, F(3, i) )).^2);
            W = Fa(i) / (la * lb);
            if (isinf(W) || isnan(W)) W = 0; end
        else
            la = sum((V( 1:3, F(3, i) ) - V( 1:3, F(1, i) )).^2);
            lb = sum((V( 1:3, F(3, i) ) - V( 1:3, F(2, i) )).^2);
            W = Fa(i) / (la * lb);
            if (isinf(W) || isnan(W)) W = 0; end
        end
        mesh.Nv(1:3, F(j, i) ) = mesh.Nv(1:3, F(j, i)) + mesh.Nf(1:3, i) * W;
    end
end
%%%%%%%%%%%%%%


% normalize the normal vectors so that they are unit length
for i = 1:size(V,2)
    mesh.Nv(:, i) = mesh.Nv(:, i) ./ sqrt( sum( mesh.Nv(:, i).^2 ) );
end

mesh.Nv = mesh.Nv'; 
mesh.Nf = mesh.Nf'; 

end