function [ M ] = T2VMat( T, area )
%T2VMAT Summary of this function goes here
%   Detailed explanation goes here
    nv = max(max(T));
    nt = size(T,1);
    
%     vdeg = zeros(nv, 1);
%     
%     for k = 1:nt
%         vdeg(T(k,1)) = vdeg(T(k,1)) + 1;
%         vdeg(T(k,2)) = vdeg(T(k,2)) + 1;
%         vdeg(T(k,3)) = vdeg(T(k,3)) + 1;
%     end
    
    
    I = zeros( 3*nt, 1 );
    J = zeros( 3*nt, 1 );
    V = zeros( 3*nt, 1 );
    
    j = 1;

    for k = 1:nt
        I(3*k-2) = T(k,1);
        J(3*k-2) = k;
        V(3*k-2) = area(k);
        
        I(3*k-1) = T(k,2);
        J(3*k-1) = k;
        V(3*k-1) = area(k);
        
        I(3*k) = T(k,3);
        J(3*k) = k;
        V(3*k) = area(k);       
    end
    
    M = sparse(I,J,V, nv, nt);
    M = bsxfun(@times, M, 1./(sum(M, 2)));
end

