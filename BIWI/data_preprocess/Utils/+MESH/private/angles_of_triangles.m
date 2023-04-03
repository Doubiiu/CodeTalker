function [A] = angles_of_triangles(V, T)
    % Computes for each triangle the 3 angles among its edges.
    % Input:
    %   option 1:   [A] = angles_of_triangles(V, T)
    %
    %               V   - (num_of_vertices x 3) 3D coordinates of
    %                     the mesh vertices.
    %               T   - (num_of_triangles x 3) T[i] are the 3 indices
    %                     corresponding to the 3 vertices of the i-th
    %                     triangle. The indexing is based on -V-.
    %
    %   option 2:   [A] = angles_of_triangles(L)
    %
    %               L - (num_of_triangles x 3) L[i] is a triple
    %                   containing the lengths of the 3 edges
    %                   corresponding to the i-th triange.
    %
    % Output:
    %


    L1 = sqrt(sum((V(T(:,2),:) - V(T(:,3),:)).^2, 2));  
    L2 = sqrt(sum((V(T(:,1),:) - V(T(:,3),:)).^2, 2));
    L3 = sqrt(sum((V(T(:,1),:) - V(T(:,2),:)).^2, 2)); 
    
    A1 = (L2.^2 + L3.^2 - L1.^2) ./ (2. * L2 .* L3);
    A2 = (L1.^2 + L3.^2 - L2.^2) ./ (2 .* L1 .* L3);
    A3 = (L1.^2 + L2.^2 - L3.^2) ./ (2 .* L1 .* L2);
    A  = [A1, A2, A3];
    A  = acos(A);
end