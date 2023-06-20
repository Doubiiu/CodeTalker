function [ h ] = hks( shape, t )
%HKS Summary of this function goes here
%   Detailed explanation goes here

LB = shape.evecs(:, 1:200 );
eigs = shape.evals(1:200 );
squaredLb = LB.^2;
    
T = exp(-abs(eigs*t));

h = squaredLb*T;

end

