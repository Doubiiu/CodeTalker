function [C, matches] = icp_refine(L1, L2, C, nk)
    Vs = L1;
    Vt = L2;
    n1 = size(L1,2);
    n2 = size(L2,2);
        
    for k=1:nk
        matches = knnsearch((C*Vs')',Vt);
        W = L2\L1(matches,:);
       % W = Vt(:,matches)*Vs';
        [s,~,d] = svd(W);
        C = s*eye(n2,n1)*d';
        
%        err = sum(sum((X-X(matches,:)).^2));
        %fprintf('%d %f\n', k, err);
    end
end