function S = compute_laplacian_basis(S1, numEigs, flag)
    
if nargin < 3
    flag = true;
end

	S.surface = S1.surface;
    
    T = S1.surface.TRIV; 
    area_S = sum(vertexAreas(S1.surface.VERT, S1.surface.TRIV));
    if flag 
        tau = sqrt(area_S); 
    else
        tau = 1; 
    end
    
    S.surface.X = S.surface.X/tau; 
    S.surface.Y = S.surface.Y/tau; 
    S.surface.Z = S.surface.Z/tau; 
    S.surface.VERT = S.surface.VERT/tau; 

    X = S.surface.VERT; 
    % compute face normal
    S.Nf = cross(X(T(:,1),:) - X(T(:,2),:), X(T(:,1),:) - X(T(:,3),:));
	S.normals_face = S.Nf./repmat(sqrt(sum(S.Nf.^2, 2)), [1, 3]);

    S.W = cotWeights(X, S.surface.TRIV);
	S.A = diag(vertexAreas(X, S.surface.TRIV)); 
    nv = size(S.A,1);

	% compute laplacian eigenbasis.
	try
	    [S.evecs, S.evals] = eigs(S.W, S.A, numEigs, 1e-6);
	catch
	    % In case of trouble make the laplacian definite
	    [S.evecs, S.evals] = eigs(S.W - 1e-8*speye(nv), S.A, numEigs, 'sm');
	end

    [S.evals, order] = sort(diag(S.evals), 'ascend');
    S.evecs = S.evecs(:,order);
    

	S.nv = nv; 
    S.nf = length(T); 
	S.area = diag(S.A); 
    S.sqrt_area = sqrt(sum(S.area));  
    S.S = sum(S.area); 

end
