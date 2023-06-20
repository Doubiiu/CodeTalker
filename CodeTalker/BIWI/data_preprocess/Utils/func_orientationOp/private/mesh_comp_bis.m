function An = mesh_comp_bis(S, F)
            T = S.T;
            nv = S.nv;            
            I = [T(:,1);T(:,2);T(:,3)];
            J = [T(:,2);T(:,3);T(:,1)];
            E = unique([F(I),F(J)],'rows');            
            nv = max(F);
            An = sparse(E(:,1),E(:,2),ones(size(E(:,1))),nv,nv);
end

