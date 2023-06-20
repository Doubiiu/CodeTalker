function [ NN ] = ann_single_component( data, k )
% ANN_SINGLE_COMPONENT A wrapper to annquery that ensures the nearest
% neighbors form a single connected component.

    % Compute the k-nearest neighbors of each point in the point cloud.
    NN = annquery(data', data', k+1);
    
    % Ensure that there is only one connected component:
    n = size(NN, 2);
    
    I = repmat(NN(1, :)', k+1, 1);
    J = reshape(NN', [(n*(k+1)), 1]);
    In = double([I;J]);
    Jn = double([J;I]);
    Vn = double(ones(size(In)));
    
    A = sparse(In,Jn,Vn,n,n);
    C = components(A);
    
    if (max(C) > 1)
        % Create connection between each component and the next:
        for i=1:max(C)-1
            % Find nearest neighbors between component i and i+1:
            idq = find(C == i);
            idr = find(C == i+1);
            dq = data(idq, :);
            dr = data(idr, :);
            [ids, dists] = annquery(dr', dq', 1);
            
            [min_val, min_id] = min(dists);
            
            % Connect components by minimal edge:
            q = idq(min_id);
            r = idr(ids(min_id));
            NN(end, q) = r;
            NN(end, r) = q;
        end
    end


    % remove the first nearest neighbor (the point itself)
    NN = NN(2:end,:)';


end

