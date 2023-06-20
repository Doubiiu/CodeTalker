function [] = plot_region_boundary(S,R)
n = size(S.A,1);

if isnumeric(R)
    if size(R,1) == 1 && size(R,2) == 1 % region: the number of regions
        region = get_Voronoi_area(S,R);
    elseif size(R,1) == n % region: a matrix
        region = mat2cell(R,size(R,1),ones(size(R,2),1));
    elseif size(R,2) == n
        R = R';
        region = mat2cell(R,size(R,1),ones(size(R,2),1));
    else
        error('The type of the input region is wrong.')
    end
elseif iscell(R)
    region = R;
else
    error('The type of the input region is wrong.')
end

%  find the edge index cross the regions
num_patch =  length(region);

if isfield(S,'Elist')
    Elist = S.Elist;
else
    Elist = get_mesh_edge_list(S);
    S.Elist = Elist;
end

e_id = [];
for i = 1:(num_patch-1)
r = find(region{i});
tmp = ismember(Elist(:,1),r) + ismember(Elist(:,2),r);
e_id = [e_id;find(tmp == 1)]; %#ok<AGROW>
end
e_id = unique(e_id);

% visualize the edges that cross two regions
plot_edges_on_mesh(S,e_id);

end