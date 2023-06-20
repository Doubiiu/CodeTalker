% by Adrien Poulenard :D
function [ SymOp, HOp ] = OrientationOp( surface, Lb , H)
%F Summary of this function goes here
%   Detailed explanation goes here

% compute heat kernel signature
t = 100; %??? numTimes?
if nargin < 3 % no input descriptors
    H = hks( surface, t );
end
% compute its gradient
G = face_grads(surface, H);

% normalize it so that it has unit norm
vn  = sqrt(sum(G'.^2))';
vn = vn + eps;
vn = repmat(vn,1,3);
G = G./vn;

% rotate it by pi/2 using cross product with the normal
JGsrc = -J(surface,G);

% create 1st order differential operators associated with the vector fields
SymOp = Lb'*surface.A*vf2op(surface, JGsrc)*Lb;
HOp = Lb'*surface.A*vf2op(surface, G)*Lb;

end

