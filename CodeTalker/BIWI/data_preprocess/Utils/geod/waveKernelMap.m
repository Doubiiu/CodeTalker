function wkms = waveKernelMap(laplaceBasis, eigenvalues, numTimes, landmarks)
% This method computes the wave kernel signature for each vertex on a list.
% It uses precomputed LB eigenstuff stored in "mesh" and automatically
% chooses the time steps based on mesh geometry.

wkms = [];
%%
for li=1:length(landmarks)
    segment = zeros(size(laplaceBasis,1),1);
    segment(landmarks(li)) = 1;
    
    numEigenfunctions = size(eigenvalues,1);
    
    absoluteEigenvalues = abs(eigenvalues);
    emin = log(absoluteEigenvalues(2));
    emax = log(absoluteEigenvalues(end));
    s = 7*(emax-emin) / numTimes; % Why 7?
    emin = emin + 2*s;
    emax = emax - 2*s;
    es = linspace(emin,emax,numTimes);
    
    T = exp(-(repmat(log(absoluteEigenvalues),1,numTimes) - ...
        repmat(es,numEigenfunctions,1)).^2/(2*s^2));
    wkm = T.*repmat(laplaceBasis' * segment, 1, size(T,2));
    wkm  = laplaceBasis*wkm;
    
    wkms = [wkms wkm]; 
end