function A = computeArea(vertices, faces)


A = zeros(size(faces, 1), 1);

% Compute area
for i = 1:size(faces, 1)
    % Get face vertices
    v(1, :) = vertices(faces(i, 1), :);
    v(2, :) = vertices(faces(i, 2), :);
    v(3, :) = vertices(faces(i, 3), :);

    % Compute face normal
    v0 = v(2, :) - v(1, :);
    v1 = v(3, :) - v(1, :);
    n = cross(v0, v1);
    area = norm(n, 2)/2.0;

    % Assign area
    A(i) = area;
end

