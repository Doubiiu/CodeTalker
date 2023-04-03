function S_tri = calc_tri_areas(M)

getDiff  = @(a,b)M.VERT(M.TRIV(:,a),:) - M.VERT(M.TRIV(:,b),:);
getTriArea  = @(X,Y).5*sqrt(sum(cross(X,Y).^2,2));
S_tri = getTriArea(getDiff(1,2),getDiff(1,3));


% S_tri = zeros(size(M.TRIV,1),1);
% 
% for k=1:size(M.TRIV,1)
%     e1 = M.VERT(M.TRIV(k,3),:) - M.VERT(M.TRIV(k,1),:);
%     e2 = M.VERT(M.TRIV(k,2),:) - M.VERT(M.TRIV(k,1),:);
%     S_tri(k) = 0.5*norm(cross(e1,e2));
% end

end
