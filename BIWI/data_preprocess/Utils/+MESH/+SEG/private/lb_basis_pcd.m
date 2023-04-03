function L = lb_basis_pcd(C, k, knn)

    % number of vertices
    nv = size(C,1);
    
    % Compute the k-nearest neighbors of each point in the point cloud.
    NN = ann_single_component(C, knn);
    
%     NN = annquery(C', C', knn+1);
%     % remove the first nearest neighbor (the point itself)
%     NN = NN(2:end,:)';
    
    
    
    
    % matrix of pairwise squared distances
    Dx = (repmat(C(:,1),1,knn)-reshape(C(NN,1),[],knn)).^2;
    Dy = (repmat(C(:,2),1,knn)-reshape(C(NN,2),[],knn)).^2;
    Dz = (repmat(C(:,3),1,knn)-reshape(C(NN,3),[],knn)).^2;
    D = Dx + Dy + Dz;
    
    % mean average distance -- sigma in the Gaussian model
    t = mean(mean(sqrt(D),2));
    
    % matrix of exponentials of squared distances
    ED = exp(-D/(4*t^2));
    
    I = reshape(repmat(double((1:nv)'),1,knn),[],1);
    J = reshape(double(NN),[],1);
    K = reshape(ED,[],1);
    
    W = sparse(I,J,K,nv,nv);
    W = (W+W')/2;
    W = spdiags(sum(W)',0,-W);
    
    % rough local area estimator (might want to use mean(D,2)^(3/2)
    % instead).
%   A = mean(D,2);    
  A = mean(D,2).^(3/2);
%     A = ones(nv,1);
    A = A/sum(A);
        
    if(nargin>1 && k>0)
        [e,v] = eigs(W,spdiags(A, 0, nv, nv),k,-1e-5);

        [v,order] = sort(diag(v),'ascend');

        L.evals = v;
        L.evecs = e(:,order);
    end
    
    L.A = spdiags(A, 0, nv, nv);
    L.W = W;
end