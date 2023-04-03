function [ JVf ] = J( shape, Vf )
%J Summary of this function goes here
%   Detailed explanation goes here
JVf = cross(Vf, shape.normals_face, 2);

end

