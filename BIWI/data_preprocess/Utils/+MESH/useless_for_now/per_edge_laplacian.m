function [W,Le] = per_edge_laplacian(T2E, E2V, area, perEdge)

nv = max(max(E2V));
ne = size(E2V,1);

ILe = [T2E(:,1); T2E(:,2); T2E(:,3)];
JLe = [T2E(:,2); T2E(:,3); T2E(:,1)];
SLe = 1/8*1./[area; area; area];
Le = sparse(ILe,JLe,-SLe,ne,ne);
Le = Le + Le' + sparse(ILe,ILe,SLe,ne,ne);

Ie = E2V(:,1);
Je = E2V(:,2);
S = Le*perEdge;
W = sparse(double([Ie;Je;Ie;Je]), double([Je;Ie;Ie;Je]), [S;S;-S;-S], nv, nv);