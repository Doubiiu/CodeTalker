% get the edge list and the corresponding edge weight
function [Elist,K] = get_edge_list(S)
    T = S.surface.TRIV;

    I = [T(:,1);T(:,2);T(:,3)];
    J = [T(:,2);T(:,3);T(:,1)];

    Elisto = [I,J];
    sElist = sort(Elisto,2);
    [Elist,~] = unique(sElist, 'rows');
    
    if nargout > 1  % get edge weight
        n = size(S.A,1); % num of vtx
        ind = sub2ind([n,n],Elist(:,1),Elist(:,2));
        if isfield(S,'W')
            W = S.W;
            K = -W(ind);  % true edge weights
        else
            W = cotLaplacian([S.surface.X, S.surface.Y, S.surface.Z], S.surface.TRIV);
            K = -W(ind);
        end
    end    
end