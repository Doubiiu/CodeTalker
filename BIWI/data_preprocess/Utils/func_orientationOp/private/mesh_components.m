function An = mesh_components(S, F)
            T = S.surface.TRIV;
            nv = S.surface.nv;
            
            I = [T(:,1);T(:,2);T(:,3)];
            J = [T(:,2);T(:,3);T(:,1)];
            E = unique([F(I),F(J)],'rows');
            
            nv = max(F);

            An = sparse(E(:,1),E(:,2),ones(size(E(:,1))),nv,nv);
end