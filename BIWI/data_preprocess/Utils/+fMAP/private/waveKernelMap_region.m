function wkms = waveKernelMap_region(laplaceBasis, eigenvalues, Ae, numTimes, regions,region_weight)
% This method computes the wave kernel signature for each vertex on a list.
% It uses precomputed LB eigenstuff stored in "mesh" and automatically
% chooses the time steps based on mesh geometry.

if nargin > 5
    if length(regions) ~= length(region_weight)
        error('inconsistent regions and region weights.')
    end
    w = region_weight;
else
    w = ones(length(regions),1);
end

wkms = [];
%%
for li=1:length(regions)
    segment = zeros(size(laplaceBasis,1),1);
    segment(regions{li}) = w(li); % assign weight to the regions
    
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