function fmap = pMap2fMap(L1, L2, map, nev)
% map: L1 -> L2
% fmap: L2 -> L1

if isstruct(L1) && isstruct(L2)
    V1 = L1.evecs;
    V2 = L2.evecs;
else
    V1 = L1;
    V2 = L2;
end

if nargin > 3
    V1 = V1(:,1:nev(1));
    V2 = V2(:,1:nev(2));
end

fmap = V1\V2(map,:);
end
