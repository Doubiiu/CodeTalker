function [ f ] = innerProd( Shape, v, w )
%INNERPROD Summary of this function goes here
%   Detailed explanation goes here
f = Shape.T2VMat*dot(v,w,2);

end

