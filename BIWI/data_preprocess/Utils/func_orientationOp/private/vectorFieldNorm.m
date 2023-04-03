function [ norm_v ] = vectorFieldNorm( shape, v )
%VECTORFIELDNORM Summary of this function goes here
%   Detailed explanation goes here
% per triangle norm
norm_t = sqrt(sum(v.^2, 2));
% average norm 
 T = shape.T;
% for i = 1:shape.nv
%     t1 = T( T(:,1) == i);
%     t2 = T( T(:,2) == i);
%     t3 = T( T(:,3) == i);
%     
% end

norm_v = zeros(shape.nv, 1);
v_area = zeros(shape.nv, 1);
for i = 1:shape.nf
    norm_v(T(i,1)) = norm_v(T(i,1)) + norm_t(i,1)*shape.area(i);
    norm_v(T(i,2)) = norm_v(T(i,2)) + norm_t(i,1)*shape.area(i);
    norm_v(T(i,3)) = norm_v(T(i,3)) + norm_t(i,1)*shape.area(i);
    v_area(T(i,1)) = v_area(T(i,1)) + shape.area(i);
    v_area(T(i,2)) = v_area(T(i,2)) + shape.area(i);
    v_area(T(i,3)) = v_area(T(i,3)) + shape.area(i); 
end
norm_v = norm_v./v_area;

end

