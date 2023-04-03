function x = vec(X)
% x = vec(X)
%
% Y = VEC(x)  Given an m x n matrix x, this produces the vector Y of length
%   m*n that contains the columns of the matrix x, stacked below each other.
%
% See also mat.

x = reshape(X,numel(X),1);
