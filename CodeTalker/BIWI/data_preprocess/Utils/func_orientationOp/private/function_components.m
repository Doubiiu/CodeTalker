function C = function_components(S, F)
    if(size(F,1) == 1)
        F = F';
    end
    
%     if (~isfield(S, 'PCD'))
        T = S.T;
    
        I = [T(:,1);T(:,2);T(:,3)];
        J = [T(:,2);T(:,3);T(:,1)];
%     else
%         knn = 6;
%         
%         % Compute the k-nearest neighbors of each point in the point cloud.
%         NN = annquery(S.PCD', S.PCD', knn+1);
%         NN = NN';
%         n = size(NN, 1);
%         I = zeros(knn*n, 1);
%         J = zeros(knn*n, 1);
%         for i=1:n
%             for j=1:knn
%                 ind = knn*(i-1) + j;
%                 I(ind) = NN(i, 1);
%                 J(ind) = NN(i, j+1);
%             end;
%         end;
%     end;

    K = double(F(I)==F(J));

    In = [I;J;I;J];
    Jn = [J;I;I;J];
    Sn = [K;K;K;K];

    nv = S.nv;
    A = sparse(In,Jn,Sn,nv,nv);

    C = components(A);
end