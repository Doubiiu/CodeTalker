function [ A, V, Dg, P, Pos, IDX ] = ExtendedTangentMap( Src, Tar, C )
%EXTENDEDTAGENTMAP Summary of this function goes here
%   Detailed explanation goes here




nfSrc = Src.nf;
nfTar = Tar.nf;
nvSrc = Src.nv;
nvTar = Tar.nv;

% warning we must have numEigsSrc == numEigsTar (take the min ... )
numEigsSrc = size(C, 2);
numEigsTar = size(C, 1);
SrcLb = Src.laplaceBasis(:, 1:numEigsSrc);
TarLb = Tar.laplaceBasis(:, 1:numEigsTar);
SrcLbIm = TarLb*C;

%% select only most probable pairs of triangles
k = 15;
[IDX, D] = knnsearch((C*SrcLb')', TarLb,'k', k);
P = zeros(nvTar, nvSrc);
% for i = 1:nvTar
%     for j = 1:k
%         P(i, IDX(i,j)) = sum(sum((TarLb(i,:)'*SrcLb(IDX(i,j),:)).*C));
%     end
% end
% we have most probable pairs of points we must select all adjacent
% triangles
% compute sparse vertex to triangle adjacency matrix in mesh info

% nfProd = sum( sum(Src.V2T(:,IDX)',2).*sum(Tar.V2T',2) );
degTar = sum(Tar.V2T',2);
degSrc = sum(Src.V2T',2);

nfProd = 0;
for i = 1:nvTar
    nfProd = nfProd + degTar(i)*sum(degSrc(IDX(i,:)));
end

% % create sparse matrix of valid pairs of faces
% I = zeros(nfProd,1);
% J = zeros(nfProd,1);
% K = ones(nfProd,1);
% 
% for i = 1:nvTar
%     I()
%     for j = 1:nvSrc
%         
%         J
%     end
% end

ProdT = zeros(Tar.nf, Src.nf);
for i = 1:nvTar
    ProdT(Tar.V2T(:,i) > 0, sum(Src.V2T(:,IDX(i,:)),2) > 0 ) = 1;  
end


% F = zeros(nvTar, nvSrc);
% 
% F = TarLb*C
% for i = 1:nvTar
%     for j = 1:nvSrc
%         F C
%     end
% end


%% compute the gradient fields


SrcGLb = zeros(numEigsSrc,nfSrc,3);
TarGLb = zeros(numEigsTar,nfTar,3);

for i = 1:numEigsSrc
    SrcGLb(i,:,:) = face_grads(Src, SrcLb(:,i));
end


for i = 1:numEigsSrc
    TarGLb(i,:,:) = face_grads(Tar, SrcLbIm(:,i));
end

%% define local basis for the tangent map
t = 1;
eps = 0.001;

Hsrc = hks( Src, t );
GHsrc = face_grads(Src, Hsrc);
vnsrc  = sqrt(sum(GHsrc'.^2))';
vnsrc = vnsrc + eps;
vnsrc = repmat(vnsrc,1,3);
Usrc = GHsrc./vnsrc;
Vsrc = J(Src,Usrc);

Htar = hks( Tar, t );
GHtar = face_grads(Tar, Htar);
vntar  = sqrt(sum(GHtar'.^2))';
vntar = vntar + eps;
vntar = repmat(vntar,1,3);
Utar = GHtar./vntar;
Vtar = J(Tar,Utar);

%% project gradient fields on local basis
X = zeros(2,numEigsSrc,nfSrc);
Y = zeros(2,numEigsTar,nfTar);

disp(size(Usrc));
disp(size(SrcGLb(1,:,:)));
for i = 1:numEigsSrc
    X(1,i,:) = dot(Usrc, reshape(SrcGLb(i,:,:), [nfSrc,3]), 2);
    X(2,i,:) = dot(Vsrc, reshape(SrcGLb(i,:,:), [nfSrc,3]), 2);
end

for i = 1:numEigsTar
    Y(1,i,:) = dot(Utar, reshape(TarGLb(i,:,:), [nfTar,3]), 2);
    Y(2,i,:) = dot(Vtar, reshape(TarGLb(i,:,:), [nfTar,3]), 2);
end

%% compute extended tangent map
v = zeros(nfTar, nfSrc);
dg = zeros(nfTar, nfSrc);
pos = zeros(nfTar, nfSrc);
A = zeros(nfTar, nfSrc, 2, 2);
k = 0;
for i = 1:nfTar
    if norm(Utar(i,:)) > 0.5     
        for j = 1:nfSrc
            if ProdT(i,j) > 0
%             disp(size(Y(:,:,i)));
%             disp(size(X(:,:,j)));
             A(i,j,:,:) = (reshape(Y(:,:,i),[2,numEigsTar])*pinv(reshape(X(:,:,j),[2,numEigsSrc])))';
             v(i,j) = sqrt( sum(sum(( Y(:,:,i) - reshape(A(i,j,:,:), [2,2])'*X(:,:,j)).^2))./sum(sum(( X(:,:,j) ).^2)));
             dg(i,j) = sqrt( (A(i,j,1,2)^2 + A(i,j,2,1)^2) / sum(sum(A(i,j,:,:).^2 )));
             if(A(i,j,1,1) > 0 && A(i,j,2,2) > 0)
                 pos(i,j) = 1;
             else
                 pos(i,j) = -1;
             end
            end
        end
    end
    disp(i/nfTar);
end


%% convert to point func
V = zeros(nvTar, nvSrc);

tmp1 = zeros(nvTar, nfSrc);
tmp2 = zeros(nfTar, nvSrc);


for j = 1:nfSrc
    tmp1(:,j) = Tar.T2VMat*v(:,j);
end
for i = 1:nfTar
    tmp2(i,:) = (Src.T2VMat*v(i,:)')';
end

for j = 1:nvSrc
    V(:,j) = V(:,j) + Tar.T2VMat*tmp2(:,j);
end

for i = 1:nvTar
    V(i,:) = V(i,:) + (Src.T2VMat*tmp1(i,:)')';
end

V = V./2;

Dg = zeros(nvTar, nvSrc);

for j = 1:nfSrc
    tmp1(:,j) = Tar.T2VMat*dg(:,j);
end
for i = 1:nfTar
    tmp2(i,:) = (Src.T2VMat*dg(i,:)')';
end

for j = 1:nvSrc
    Dg(:,j) = Dg(:,j) + Tar.T2VMat*tmp2(:,j);
end

for i = 1:nvTar
    Dg(i,:) = Dg(i,:) + (Src.T2VMat*tmp1(i,:)')';
end

Dg = Dg./2;

Pos = zeros(nvTar, nvSrc);

for j = 1:nfSrc
    tmp1(:,j) = Tar.T2VMat*pos(:,j);
end
for i = 1:nfTar
    tmp2(i,:) = (Src.T2VMat*pos(i,:)')';
end

for j = 1:nvSrc
    Pos(:,j) = Pos(:,j) + Tar.T2VMat*tmp2(:,j);
end

for i = 1:nvTar
    Pos(i,:) = Pos(i,:) + (Src.T2VMat*tmp1(i,:)')';
end

Pos = Pos./2;


end



