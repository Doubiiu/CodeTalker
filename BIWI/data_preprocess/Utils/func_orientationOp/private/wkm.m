function [f] = wkm(laplaceBasis, eigenvalues, Ae, segment_indicator, numTimes)
    nv = size(laplaceBasis,2);

    emin1 = log(eigenvalues(2));
    emax1 = log(eigenvalues(end));
    s1 = 7*(emax1-emin1)/numTimes;
    emin1 = emin1 + 2*s1;
    emax1 = emax1 - 2*s1;
    es1 = linspace(emin1,emax1,numTimes);

    T = exp(-(repmat(log(eigenvalues),1,numTimes) - repmat(es1,nv,1)).^2/(2*s1^2));
    wkm = T.*repmat(laplaceBasis'*Ae*segment_indicator, 1, numTimes);
    f = (laplaceBasis)*real(wkm);
end