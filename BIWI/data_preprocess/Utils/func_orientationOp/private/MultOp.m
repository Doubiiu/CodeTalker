function [ Mop ] = MultOp( f, B1, B2, Shape )
%MULTOP output the multiplicative operator ascociated with the function f
%in basis B1, B2 (we assume that the basis are orthonormal for L2 inner
%product)
%   Detailed explanation goes here
    Mop = (B2'*Shape.Ae)*(repmat(f, [1,size(B1,2)]).*B1);    
end

