function T21 = fMap2pMap(L1, L2, fmap)
dim1 = size(fmap,2);
dim2 = size(fmap,1);

if isstruct(L1) && isstruct(L2)
    V1 = L1.evecs;
    V2 = L2.evecs;
else
    V1 = L1;
    V2 = L2;
end

B1 = V1(:,1:dim1);
B2 = V2(:,1:dim2);
C12 = fmap;
T21 = knnsearch(B1*C12', B2);
end