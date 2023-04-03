function L = lb_basis_surface(S, k)
    C = [S.surface.X S.surface.Y S.surface.Z];
    W = cotWeights(C, S.surface.TRIV);
    A = vertexAreas(C, S.surface.TRIV);

    A = A/sum(A);
    
    if(nargin>1 && k>0)
        [e,v] = eigs(W,spdiags(A,0,S.surface.nv,S.surface.nv),k,-1e-5);

        [v,order] = sort(diag(v),'ascend');

        L.evals = v;
        L.evecs = e(:,order);
    end
    
    L.A = spdiags(A,0,S.surface.nv,S.surface.nv);
    L.W = W;
end