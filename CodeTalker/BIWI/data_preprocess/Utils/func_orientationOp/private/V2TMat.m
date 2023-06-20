function [ M ] = V2TMat( nv, T )
%V2TMAT Summary of this function goes here
%   Detailed explanation goes here
    nt = size(T, 1);
  
    I = zeros(3*nt);
    J = zeros(3*nt);
    V = zeros(3*nt);
    
    for k = 1:nt
        I(3*k - 2) = T(k,1);
        I(3*k - 1) = T(k,2);
        I(3*k) = T(k,3);
        J(3*k - 2) = k;
        J(3*k - 1) = k;
        J(3*k) = k;
        V(3*k - 2) = 1.0/6.0;
        V(3*k - 1) = 1.0/6.0;
        V(3*k) = 1.0/6.0;
    end
    M = sparse(I, J, V, nt, nv);
end

