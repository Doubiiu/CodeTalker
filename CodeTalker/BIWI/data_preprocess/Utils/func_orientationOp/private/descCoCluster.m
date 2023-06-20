function [ Idx, idx ] = descCoCluster( Src, Tar, k)
%DESCCLUSTER segment the shapes in k clusters in descriptor space and
%compute connected components within each cluster
%   Detailed explanation goes here
    FullDesc = [Src.desc; Tar.desc];
    [idx,C,sumd,D] = kmeans(FullDesc,nb_clusters);

end

