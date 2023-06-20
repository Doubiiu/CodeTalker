function [ Cr ] = crossProdOp( shape, v , B)
%CROSSPRODMAT create the matrix of f -> int v cross grad( f ) dot n
% in the reduced basis B
%   Detailed explanation goes here
    
    t2v = T2VMat( shape.T, shape.area);
%     v2t = T2VMat( shape.nv, T );
    G = face_grads_mat( shape.X, shape.T, shape.normal, shape.area );
    C = crossProdMat( shape.T, shape.normal , v);
    Cr = B'*shape.Ae*t2v*(C*(G*B));
end

