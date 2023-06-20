function err = eval_pMap(S1, S2, T12, gt_corres, type)
% compute the error of the pMap
% Input:
%   T12: S1 -> S2
%   gt_corres: m-by-2 matrix, the m corresponding vertices (ground-truth to measure the T12)
%   type: 'geodesic' or ';euclidean' distance
if nargin < 5, type = 'geodesic'; end;
T12 = reshape(T12,[],1);
vid1 = gt_corres(:,1); % vtx on S1
vid2 = gt_corres(:,2); % vtx on S2 corresponding to vid1

if(strcmp(type, 'geodesic'))
    if isfield(S2,'Gamma') % we have geodesic distance matrix
        get_mat_entry = @(M,I,J) M(sub2ind(size(M),I,J));
        dists = get_mat_entry(S2.Gamma,vid2,T12(vid1));
    else
        dists = MESH.geodesics_pairs(S2, [T12(vid1), vid2]);
    end
elseif(strcmp(type, 'euclidean'))
    D = [S2.surface.X S2.surface.Y S2.surface.Z];
    dists = sqrt(sum((D(vid2, :) - D(T12(vid1), :)).^2,2));
else
    error('unknown type %s\n',type);
end

err = dists/S2.sqrt_area;

end