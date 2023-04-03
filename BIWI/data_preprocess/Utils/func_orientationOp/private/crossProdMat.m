function [ Cr ] = crossProdMat( T, N , Y)
%CROSSPRODMAT Summary of this function goes here
%   Detailed explanation goes here
nt = size(T, 1);
e1 = [1, 0, 0];
e2 = [0, 1, 0];
e3 = [0, 0, 1];
u = cross(e1, e2);
v = cross(e2, e3);
w = cross(e1, e3);

cr = zeros(3,3);
 
I = zeros(3*nt,1);
J = zeros(3*nt,1);
V = zeros(3*nt,1);

for k = 1:nt
   I(3*k-2) = k;
   I(3*k-1) = k;
   I(3*k) = k;
   J(3*k-2) = 3*k-2;
   J(3*k-1) = 3*k-1;
   J(3*k) = 3*k;

   cr(1,2) = dot(u,N(k,:));
   cr(1,3) = dot(v,N(k,:));
   cr(2,3) = dot(w,N(k,:));
   
   cr(3,1) = -dot(v,N(k,:));
   cr(3,2) = -dot(w,N(k,:));
   cr(2,1) = -dot(u,N(k,:));
   
   V(3*k-2:3*k) = (Y(k,:)*cr)';
   
   
%    V(3*k-2) = ;
%    V(3*k-2) = ;
end

Cr = sparse(I,J,V, nt, 3*nt); 
end

