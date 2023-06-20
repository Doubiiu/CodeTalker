function C = extract_latent_basis(A, B)
% Input A, B are two square cells. 
% W is a large matrix whose smallest eigenvectors are minimizer of 
% || A{i, j}*y_i - B{j}*y_j ||_F^2.  

n = size(A, 1); 
k = size(A{1, 1}, 1); 

if nargin < 2
    B = cell(n, 1); 
    for i = 1:n
        B{i} = eye(k); 
    end
end

W = cell(n); 
for i = 1:n
    W{i, i} = zeros(k); 
    for j = 1:n 
        if i ~= j
            W{i, i} = W{i, i} + A{i,j}'*A{i,j} + B{i}'*B{i}; 
            W{i, j} = -(A{i,j}'*B{j} + B{i}'*A{j, i});
        end
    end
end

C.mat = cell2mat(W); 
[u, v] = eigs(C.mat, k, -1E-6); 
[C.evals, ind] = sort(diag(v), 'ascend'); 
C.evecs = u(:, ind); 
C.bases = mat2cell(C.evecs, k*ones(n, 1), k); 


end
        

    