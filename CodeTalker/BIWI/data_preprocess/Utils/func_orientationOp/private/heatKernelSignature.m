function hks = heatKernelSignature( laplaceBasis, eigenvalues, Ae, numTimes )
%HEATKERNELSIGNATURE Summary of this function goes here
%   Detailed explanation goes here
numEigenfunctions = size(eigenvalues,1);

D = laplaceBasis' * (Ae * laplaceBasis.^2);

absoluteEigenvalues = abs(eigenvalues);
emin = absoluteEigenvalues(2);
emax = absoluteEigenvalues(end);

t = linspace(emin,emax,numTimes);

T = exp(-abs(eigenvalues*t));

hks = D*T;
hks = laplaceBasis*hks;

end

