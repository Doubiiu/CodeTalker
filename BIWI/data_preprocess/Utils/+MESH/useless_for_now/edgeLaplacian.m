% original file: fvf_code(functional vector fields):dec_it2.m
% paper: An Operator Approach to Tagent Vector field processing
% return the edge_based Laplacian (dec.nabla1 in det_it2.m)
function [W_e] = edgeLaplacian(mesh)

if ~isfield(mesh,'triangles')
    T = mesh.surface.TRIV;
else
    T = mesh.triangles;
end

if ~isfield(mesh,'vertices')
    X = [mesh.surface.X,mesh.surface.Y,mesh.surface.Z];
else
    X = mesh.vertices;
end

nv = length(X);
nf = length(T);

I = [T(:,1);T(:,2);T(:,3)];
J = [T(:,2);T(:,3);T(:,1)];
S = [1:nf,1:nf,1:nf]';
E = sparse(I,J,S',nv,nv);

Elisto = [I,J];
sElist = sort(Elisto,2);
s = (normv(Elisto - sElist) > 1e-12);
t = S.*(-1).^s;
[Elist,une] = unique(sElist, 'rows');
e2t = zeros(length(Elist),4);
t2e = zeros(nf,3);
for m=1:length(Elist)
    i = Elist(m,1); j = Elist(m,2);
    t1 = t(une(m));
    t2 = -(E(i,j) + E(j,i) - abs(t1))*sign(t1);
    e2t(m,1:2) = [t1, t2];
    f = T(abs(t1),:); loc = find(f == (sum(f) - i - j));
    t2e(abs(t1),loc) = m*sign(t1);
    e2t(m,3) = loc;
    if t2 ~= 0
        f = T(abs(t2),:); loc = find(f == (sum(f) - i - j));
        t2e(abs(t2),loc) = m*sign(t2);
        e2t(m,4) = loc;
    end
end

% v2e = sparse(Elist(:,1),Elist(:,2),[1:length(Elist)],nv,nv);

ne = length(Elist);

% Boundray 1: 0 --> 1
I = [Elist(:,1);Elist(:,2)];
J = [1:ne,1:ne]';
S = [repmat(-1,ne,1); repmat(1,ne,1)];
b1 = sparse(I,J,S,nv,ne);

% Boundary 2: 1 --> 2
I = [1:ne, 1:ne]';
J = [abs(e2t(:,1)); abs(e2t(:,2))];
S = [sign(e2t(:,1)); sign(e2t(:,2))];
locs = find(J ~= 0);
I = I(locs); J = J(locs); S = S(locs);
b2 = sparse(I,J,S,ne,nf);

% Differential
d0 = b1';
d1 = b2';

% Hodge star
L1 = normv(X(T(:,2),:)-X(T(:,3),:));
L2 = normv(X(T(:,1),:)-X(T(:,3),:));
L3 = normv(X(T(:,1),:)-X(T(:,2),:));
A1 = (L2.^2 + L3.^2 - L1.^2) ./ (2.*L2.*L3);
A2 = (L1.^2 + L3.^2 - L2.^2) ./ (2.*L1.*L3);
A3 = (L1.^2 + L2.^2 - L3.^2) ./ (2.*L1.*L2);
A = [A1,A2,A3];
A = acos(A);
EL = [L1, L2, L3];

% *0 - dual voronoi areas
ar = (1/8)*cot(A).*EL.^2;
I = [T(:,1);T(:,2);T(:,3)];
J = [T(:,2);T(:,3);T(:,1)];
S = [ar(:,3);ar(:,1);ar(:,2)];
In = [I;J];
Jn = In;
Sn = [S;S];
h0 = sparse(In,Jn,Sn,nv,nv); h0d = full(diag(h0));
h0i = spdiags(1./h0d,0,nv,nv);

% *1 - cot weights
I = [T(:,1);T(:,2);T(:,3)];
J = [T(:,2);T(:,3);T(:,1)];
S = 0.5*cot([A(:,3);A(:,1);A(:,2)]);
In = [I;J];
Jn = [J;I];
Sn = [S;S];
W = sparse(In,Jn,Sn,nv,nv);
h1d = zeros(length(Elist),1);
for i=1:length(h1d)
    h1d(i) = W(Elist(i,1),Elist(i,2));
end
h1 = spdiags(h1d,0,ne,ne);
% h1i = spdiags(1./h1d,0,ne,ne);

% *2 - 1/triangle areas
N = cross(X(T(:,1),:)-X(T(:,2),:), X(T(:,1),:) - X(T(:,3),:));
Ar = normv(N)/2;
% N = N./repmat(normv(N),1,3);
h2 = spdiags(1./Ar, 0, nf, nf);

% delta = inv(*)d'*
% delta1 = h0i*d0'*h1; % 1 --> 0
% delta2 = h1i*d1'*h2; % 2 --> 1

% Laplacians - nabla = delta d + d delta
% nabla0 = d0'*h1*d0;
% nabla0w = h0i*nabla0;

% h1i*d1'*h2*d1 + d0*h0i*d0'*h1;
d0th1 = d0'*h1;

Mcross = d1'*h2*d1;
Mdiv = d0th1'*h0i*d0th1;

nabla1 = Mcross + Mdiv;
% nabla1w = speye(ne);%h1i*nabla1;

% d1*h1i*d1'*h2;
% nabla2 = d1*h1i*d1'*h2;


% mesh.Elist = Elist; mesh.E = E; mesh.nv = nv; mesh.nf = nf; mesh.ne = ne;
% mesh.e2t = e2t; mesh.t2e = t2e; mesh.v2e = v2e; mesh.Ar = Ar; mesh.N = N;
% 
% dec.b1 = b1; dec.b2 = b2;
% dec.d0 = d0; dec.d1 = d1;
% dec.h0 = h0; dec.h0i = h0i; dec.h1 = h1; dec.h1i = h1i; dec.h2 = h2;
% dec.delta1 = delta1; dec.delta2 = delta2;
% dec.nabla0 = nabla0; dec.nabla1 = nabla1; dec.nabla2 = nabla2;
% dec.nabla0w = nabla0w; dec.nabla1w = nabla1w;
% dec.Mcross = Mcross; dec.Mdiv = Mdiv;
W_e = nabla1;
end

function nn = normv(V)
nn = sqrt(sum(V.^2,2));
end