function F = hks(L1, ts)
    N = size(L1.evecs,2);
    D1 = L1.evecs(:,1:N)'*(L1.A*L1.evecs(:,1:N).^2);
    T1 = exp(-abs(L1.evals(1:N))*ts);
    F = D1*T1;
    F = L1.evecs*F;
end