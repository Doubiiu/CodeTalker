function [W,Le] = per_edge_area(E2T, E2V, area)

nv = max(max(E2V));
ne = size(E2V,1);
nf = size(area, 1);

% I = [1:ne, 1:ne]';
% J = [E2T(:,1); E2T(:,2)];
% Le = sparse(I, J, ones(2*ne, 1)/12, ne, nf);
I = [find(E2T(:,1)); find(E2T(:,2))];
J = [E2T(E2T(:,1) ~= 0,1); E2T(E2T(:,2) ~= 0,2)];
Le = sparse(I, J, ones(length(I), 1)/12, ne, nf);

Ie = E2V(:,1);
Je = E2V(:,2);
S = Le*area;
W = sparse(double([Ie;Je;Ie;Je]), double([Je;Ie;Ie;Je]), [S;S;S;S], nv, nv);