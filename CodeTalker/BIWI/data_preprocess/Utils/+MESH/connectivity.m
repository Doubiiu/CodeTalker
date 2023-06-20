function [E2V, T2E, E2T, T2T] = connectivity(T)
% Computes the adjacency properties given a list of triangles
%
% INPUT: 
% T : list of triangles
%
% OUTPUT:
% E2V : list of edges = per of vertices indexes
% T2E : edge indexes per triangles
% E2T : adjacent triangles to each edge , sign of the edge seen from triangle
% T2T : adjacent triangles to each triangle

nf = size(T,1);
nv = max(T(:));

E2V = [T(:,1) T(:,2) ; T(:,2) T(:,3) ; T(:,3) T(:,1)];
[E2V,id] = sort(E2V,2);
[E2V,ia,ic] = unique(E2V,'rows');

edgeSg = id(:,1) - id(:,2);
t2es = [edgeSg(1:nf), edgeSg((nf+1):(2*nf)), edgeSg((2*nf+1):end)];
edgeSg = edgeSg(ia);

e1 = ic(1:nf);
e2 = ic((nf+1):(2*nf));
e3 = ic((2*nf+1):end);
T2E = [e1 e2 e3];

% bound = find(accumarray(T2E(:), 1) == 1);
% [~, idx] = sort([e1; e2; e3]);
% idx = mod(idx-1, nf)+1;
% E2T = reshape(idx', [2, size(E2V,1)])';
% E2T = [E2T, edgeSg, -edgeSg];
bound = find(accumarray(T2E(:), 1) == 1);
nB = length(bound);
% if ~isempty(bound)
%     warning(['Mesh with ', num2str(nB), ' boundary edges: length retrieval might not work']);
% end
[~, idx] = sort([e1; e2; e3; bound]);
idx(idx <= 3*nf) = mod(idx(idx <= 3*nf)-1, nf)+1;
E2T = reshape(idx', [2, size(E2V,1)])';
E2T(E2T > nf) = 0;
E2T = [E2T, edgeSg, -edgeSg];

T2T = [E2T(T2E(:,1),1), E2T(T2E(:,2),1), E2T(T2E(:,3),1), E2T(T2E(:,1),2), E2T(T2E(:,2),2), E2T(T2E(:,3),2)];
T2T = sort((T2T ~= repmat((1:nf)', [1,6])).*T2T, 2);
T2T = T2T(:,4:6);


T2E = T2E.*t2es;

% [Ts,id] = sort(T);
% V2T = cell(3, 1);
% for i = 1:3
%     nbTri = zeros(nv, 1);
%     nbTri(1:max(Ts(:,i))) = accumarray(Ts(:,i), 1);
%     V2T{i} = mat2cell(id(:,i), nbTri, 1);
% end
% V2T = cellfun(@(a,b,c) [a;b;c], V2T{1}, V2T{2}, V2T{3}, 'UniformOutput', false);
