function [ G ] = face_grads_mat( X, T, N, A )
%FACE_GRADS_MAT Summary of this function goes here
%   Detailed explanation goes here

nv = size(X,1);
nt = size(T,1);

I = zeros(9*nt, 1);
J = zeros(9*nt, 1);
V = zeros(9*nt, 1);

i = 0;

for k = 1:nt
    i = 3*k-2;
    I(9*k-8) = i;
    I(9*k-7) = i+1;
    I(9*k-6) = i+2;
    
    I(9*k-5) = i;
    I(9*k-4) = i+1;
    I(9*k-3) = i+2;
    
    I(9*k-2) = i;
    I(9*k-1) = i+1;
    I(9*k) = i+2;
    
    J(9*k-8) = T(k,1);
    J(9*k-7) = T(k,1);
    J(9*k-6) = T(k,1);
    
    J(9*k-5) = T(k,2);
    J(9*k-4) = T(k,2);
    J(9*k-3) = T(k,2);
    
    J(9*k-2) = T(k,3);
    J(9*k-1) = T(k,3);
    J(9*k) = T(k,3);
    
    V(9*k-8:9*k-6) = cross(N(k,:), X(T(k,3),:) - X(T(k,2),:))./(2*A(k));
    V(9*k-5:9*k-3) = cross(N(k,:), X(T(k,1),:) - X(T(k,3),:))./(2*A(k));
    V(9*k-2:9*k) = cross(N(k,:), X(T(k,2),:) - X(T(k,1),:))./(2*A(k));
    
end
G = sparse(I,J,V, 3*nt, nv);
end

