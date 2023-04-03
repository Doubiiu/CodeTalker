function [ V ] = cross_grad( X, T, E2T, E2V, area )
%CROSS_GRAD Summary of this function goes here
%   Detailed explanation goes here
ne = size(E2V, 1);
v = zeros(2*ne, 1);
% faire une boucle sur les triangles 
% prendre les couples de sommets
% pr chaque couple de couple (y, x) , (z, x) 
% poser u = y - x, et v = z - x
% alors update les somets y et z avec + / - 4 (Aire(x,y,z)^2) * u cross v /
%  || u ||^2*||v||^2
for i = 1:ne
    e = X(E2T() ,:) - X(,:);
    f = X(,:) - X(,:);
    g = X(,:) - X(,:);
    h = X(,:) - X(,:);
    v(2*i-1) = cross(e,f)/(dot(e,e)*dot(f,f)) + cross(g,h)/(dot(g,g)*dot(h,h));
    v(2*i) = -v(2*i-1);
end

end

