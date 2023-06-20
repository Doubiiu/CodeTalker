function wks = waveKernelSignature(laplaceBasis, eigenvalues, Ae, numTimes)
% This method computes the wave kernel signature for each vertex on a list.
% It uses precomputed LB eigenstuff stored in "mesh" and automatically
% chooses the time steps based on mesh geometry.

numEigenfunctions = size(eigenvalues,1);

D = laplaceBasis' * (Ae * laplaceBasis.^2);

absoluteEigenvalues = abs(eigenvalues);
emin = log(absoluteEigenvalues(2));
emax = log(absoluteEigenvalues(end));
s = 7*(emax-emin) / numTimes; % Why 7?
emin = emin + 2*s;
emax = emax - 2*s;
es = linspace(emin,emax,numTimes);

T = exp(-(repmat(log(absoluteEigenvalues),1,numTimes) - ...
    repmat(es,numEigenfunctions,1)).^2/(2*s^2));
wks = D*T;
wks = laplaceBasis*wks;