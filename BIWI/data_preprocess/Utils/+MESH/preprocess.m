function [S] = preprocess(S_in,varargin)
%Preprocess a mesh
%   Input: S_in
%       - a mesh structure with surface (X,Y,Z, TRIV)
%       - the mesh filename
%   Optional Input:
%       - cacheDir: the dir to load/save the cache of the mesh
%       - IfComputeLB: if compute the Laplace-Beltrami Basis (evecs, evals)
%       - numEigs: if IfComputeLB, the number of Eigenvectors.
%       - IfFindNeigh: if find the one-ring neighbor for each vertex (vtx_neigh)
%       - IfFindEdge: if find the edge list and the corresponding cotangent weight (Elist, EdgeWeight)
%       - IfComputeGeoDist: if find the geodesic distance matrix (Gamma)
%       - IfComputeNormals: if compute the face and vertex normals (normals_vtx, normals_face)

if ischar(S_in)
    S = MESH.MESH_IO.read_shape(S_in);
    filepath = S_in(1:end-length(S.name));
elseif isstruct(S_in)
    S = S_in;
    if ~isfield(S,'nv'), S.nv = length(S.surface.X); end
    if ~isfield(S,'nf'), S.nf = size(S.surface.TRIV,1); end
    filepath ='/';
else
    error('Unsupported input type.')
end

default_param = load_MESH_PREPROCESS_default_params(S);
default_param.cacheDir = [filepath, 'cache/'];
param = parse_MESH_PREPROCESS_params(default_param,varargin{:});
S.name = param.MeshName;

save_filename = [param.cacheDir,S.name,'.mat'];
if exist(save_filename,'file')
    fprintf('Loading from the cache...'); tic;
    S = load(save_filename);
    t = toc; fprintf('done: %.4fs\n',t);
else
    % compute the Laplacian basis
    if param.IfComputeLB
        %param.numEigs
        S = MESH.compute_LaplacianBasis(S,param.numEigs);
    end
    
    % get the one-ring neighbor
    if param.IfFindNeigh
        S.vtx_neigh = MESH.find_one_ring_neigh(S);
    end
    
    % edge list and weight
    if param.IfFindEdge
        [S.Elist,S.EdgeWeight] = MESH.get_edge_list(S);
    end
    
    % compute the geodesic distance
    if param.IfComputeGeoDist
        S.Gamma = MESH.compute_geodesic_dist_matrix(S);
    end
    
    % Normals and areas
    if param.IfComputeNormals
        [S.normals_vtx, S.normals_face] = compute_vtx_and_face_normals(S);
    end
    if isdir(param.cacheDir)
        fprintf('Saving to cache...'); tic;
        save([param.cacheDir,S.name,'.mat'],'-struct','S');
        t = toc; fprintf('done: %.4f\n', t);
    end
    S.sqrt_area = sqrt(sum(S.area));
end
end
%%
function default_param = load_MESH_PREPROCESS_default_params(S)
default_param.numEigs = 250;
default_param.IfComputeLB = true;
default_param.IfComputeGeoDist = true;
if S.nv > 5000
    default_param.IfComputeGeoDist = false;
end
default_param.IfComputeNormals = false;
default_param.IfFindEdge = true;
default_param.IfFindNeigh = true;
default_param.MeshName = S.name;
end

function [param,p] = parse_MESH_PREPROCESS_params(default_param,varargin)
p = inputParser;
addParameter(p,'IfComputeNormals',default_param.IfComputeNormals,@islogical);
addParameter(p,'IfComputeLB',default_param.IfComputeLB,@islogical);
addParameter(p,'IfComputeGeoDist',default_param.IfComputeGeoDist,@islogical);
addParameter(p,'IfFindEdge',default_param.IfFindEdge,@islogical);
addParameter(p,'IfFindNeigh',default_param.IfFindNeigh,@islogical);
addParameter(p,'numEigs',default_param.numEigs,@isnumeric);
addParameter(p,'MeshName',default_param.MeshName,@ischar);
addParameter(p,'cacheDir',default_param.cacheDir,@ischar);
parse(p,varargin{:});
param = p.Results;

end