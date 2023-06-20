function [ G ] = computeGrad( shape, f )
%COMPUTEGRAD compute gradient vector on each triangle
%   Detailed explanation goes here

X = shape.X;
T = shape.T;
Ar = shape.area;
Nf = shape.normal;

v1 = X(T(:,1),:);
v2 = X(T(:,2),:);
v3 = X(T(:,3),:); 
Ar = repmat(Ar, 1, 3);
G = repmat(f(T(:,1)),1,3).*cross(Nf, v3 - v2)./(2*Ar) + ...
    repmat(f(T(:,2)),1,3).*cross(Nf, v1 - v3)./(2*Ar) + ...
    repmat(f(T(:,3)),1,3).*cross(Nf, v2 - v1)./(2*Ar);

end

