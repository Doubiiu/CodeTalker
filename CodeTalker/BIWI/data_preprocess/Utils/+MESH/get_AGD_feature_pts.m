% 2017-12-26
% get the Avergae Geodesic Distance feature points
function [fp_id] = get_AGD_feature_pts(S,num,alpha)
import MESH.*;
import MESH.PLOT.*;

if nargin < 2, num = 5; end
if nargin < 3, alpha = 2; end % the AGD(n): ~Euclidean(n)

if ~isfield(S,'Gamma')
    d = compute_geodesic_dist_matrix(S);
else
    d = S.Gamma;
end

area = S.area;
AGD = d.^alpha*area;

% feature point id
fp_id = zeros(num,1);
v_id = 1:length(AGD);
for k = 1:num
    [~,id] = max(AGD(v_id));
    max_id = v_id(id);
    fp_id(k) = max_id;
    % TODO: how to detect the local maximum
    v_id = setdiff(v_id,...
        find(d(max_id,:) < quantile(d(max_id,:),0.05)));
end
%%
figure('Name','Average-Geodesic-Distance feature points');
subplot(1,2,1); plot_func_on_mesh(S,AGD./min(AGD)); title('Average Geodesic Distance')
subplot(1,2,2); plot_vtx_on_mesh(S,fp_id); title('feature points')
end
