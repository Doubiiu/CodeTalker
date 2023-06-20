function hkms = heatKernelMap(laplaceBasis, eigenvalues, Ae, numTimes, landmarks)
% This method computes the wave kernel signature for each vertex on a list.
% It uses precomputed LB eigenstuff stored in "mesh" and automatically
% chooses the time steps based on mesh geometry.

hkms = [];
%%
for li=1:length(landmarks)
    segment = zeros(size(laplaceBasis,1),1);
    segment(landmarks(li)) = 1;
    
    log_ts = linspace(log(0.005), log(0.2), numTimes);
    ts = exp(log_ts);
    
    N = size(laplaceBasis,2);    
    T = exp(-abs(eigenvalues(1:N))*ts);
    hkm = T.*repmat(laplaceBasis' * segment, 1, size(T,2));
    hkm  = laplaceBasis*hkm;
     
    hkms = [hkms hkm];
end