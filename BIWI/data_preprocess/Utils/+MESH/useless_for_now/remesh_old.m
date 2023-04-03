function [S, f_o2n, f_n2o] = remesh(S1,num_faces, num_Eigs)
addpath('C:\RJ\MATLAB_toolbox\toolbox_gpeyre\toolbox_wavelet_meshes\')
addpath('C:\RJ\MATLAB_toolbox\toolbox_gpeyre\toolbox_wavelet_meshes\toolbox\')
addpath('C:\RJ\MATLAB_toolbox\toolbox_gpeyre\toolbox_fast_marching\toolbox\')
nf = size(S1.surface.TRIV,1);
F = S1.surface.TRIV;
V = [S1.surface.X, S1.surface.Y, S1.surface.Z];
if nf > num_faces
    [FF,VV] = reducepatch(F,V,num_faces);
else % original mesh has fewer faces than num_faces
    VV = V'; FF = F';
    % upsampling first
    while size(FF,2) < num_faces
        options.sub_type = 'loop';
        [VV,FF] = perform_mesh_subdivision(VV,FF,2,options);
        %         [VV,FF] = upsample(VV,FF,'Iterations',2); % point subdivision
    end
    VV = VV'; FF = FF';
    % downsampling to the input size
    [FF,VV] = reducepatch(FF,VV,num_faces);
end
S.surface.X = VV(:,1);
S.surface.Y = VV(:,2);
S.surface.Z = VV(:,3);
S.surface.VERT = VV;
S.surface.TRIV = FF;
S.nv = size(VV,1);

if isfield(S1,'name')
    if S.nv < 1e3
        S.name = [S1.name,'_',num2str(S.nv)];
    else
        S.name = [S1.name,'_',num2str(floor(S.nv/1e3)),'k'];
    end
end
% Nearest neighbor map: old-to-new
f_o2n = knnsearch(S.surface.VERT,S1.surface.VERT);
% new-to-old
f_n2o = knnsearch(S1.surface.VERT,S.surface.VERT);

if nargin > 2
    S = compute_laplacian_basis(S,num_Eigs);
end

end

function v = getoptions(options, name, v, mendatory)

% getoptions - retrieve options parameter
%
%   v = getoptions(options, 'entry', v0, mendatory);
% is equivalent to the code:
%   if isfield(options, 'entry')
%       v = options.entry;
%   else
%       v = v0;
%   end
%
%   Copyright (c) 2007 Gabriel Peyre

if nargin<3
    error('Not enough arguments.');
end
if nargin<4
    mendatory = 0;
end

if isfield(options, name)
    v = eval(['options.' name ';']);
elseif mendatory
    error(['You have to provide options.' name '.']);
end
end

% Gabriel: butterfly subdivision
function [f1,face1] = perform_mesh_subdivision(f, face, nsub, options)

% perform_mesh_subdivision - perfrom a mesh sub-division
%
%   [face1,f1] = perform_mesh_subdivision(face,f,nsub,options);
%
%   face is a (3,nface) matrix of original face adjacency
%   face1 is the new matrix after subdivision
%   f is a (d,nvert) matrix containing the value f(:,i) of a function
%       at vertex i on the original mesh. One should have
%           nvert=max(face(:))
%       (can be multi dimensional like point position in R^3, d=3)
%   f1 is the value of the function on the subdivided mesh.
%
%   options.sub_type is the kind of subvision applied:
%       'linear4': 1:4 tolopoligical subivision with linear interpolation
%       'linear3': 1:3 tolopoligical subivision with linear interpolation
%       'loop': 1:4 tolopoligical subivision with loop interpolation
%       'butterfly': 1:4 tolopoligical subivision with linear interpolation
%       'sqrt3': 1:3 topological subdivision with sqrt(3) interpolation
%          (dual scheme).
%       'spherical4': 1:4 tolopoligical subivision with linear
%           interpolation and projection of f on the sphere
%       'spherical3': 1:3 tolopoligical subivision with linear
%           interpolation and projection of f on the sphere
%
%   An excellent reference for mesh subdivision is
%       Subdivision for Modeling and Animation,
%       SIGGRAPH 2000 Course notes.
%       http://mrl.nyu.edu/publications/subdiv-course2000/
%
%   The sqrt(3) subdivision is explained in
%       \sqrt{3}-subdivision, Leif Kobbelt
%       Proc. of SIGGRAPH 2000
%
%   Copyright (c) 2007 Gabriel Peyré

options.null = 0;
if nargin<2
    error('Not enough arguments');
end
if nargin==2
    nsub=1;
end

sub_type = getoptions(options, 'sub_type', '1:4');
spherical = getoptions(options, 'spherical', 0);
sanity_check = getoptions(options, 'sanity_check', 1);

switch lower(sub_type)
    case 'linear3'
        interpolation = 'linear';
        topology = 3;
    case 'linear4'
        interpolation = 'linear';
        topology = 4;
    case 'loop'
        interpolation = 'loop';
        topology = 4;
    case 'butterfly'
        interpolation = 'butterfly';
        topology = 4;
    case 'sqrt3';
        interpolation = 'sqrt3';
        topology = 3;
    case 'spherical3'
        interpolation = 'linear';
        topology = 3;
        spherical = 1;
    case 'spherical4'
        interpolation = 'linear';
        topology = 4;
        spherical = 1;
    case '1:3'
        interpolation = 'linear';
        topology = 3;
    case '1:4'
        interpolation = 'linear';
        topology = 4;
end

if nsub==0
    f1 = f;
    face1 = face;
    return;
end

if nsub>1
    % special case for multi-subdivision
    f1 = f;
    face1 = face;
    for i = 1:nsub
        [f1,face1] = perform_mesh_subdivision(f1,face1,1, options);
    end
    return;
end


if size(f,1)>size(f,2) && sanity_check
    f=f';
end
if size(face,1)>size(face,2) && sanity_check
    face=face';
end

m = size(face,2);
n = size(f,2);

verb = getoptions(options, 'verb', n>500);
loop_weigths = getoptions(options, 'loop_weigths', 1);

if topology==3
    f1 = ( f(:,face(1,:)) + f(:,face(2,:)) + f(:,face(3,:)))/3;
    f1 = cat(2, f, f1 );
    %%%%%% 1:3 subdivision %%%%%
    switch interpolation
        case 'linear'
            face1 = cat(2, ...
                [face(1,:); face(2,:); n+(1:m)], ...
                [face(2,:); face(3,:); n+(1:m)], ...
                [face(3,:); face(1,:); n+(1:m)] );
        case 'sqrt3'
            face1 = [];
            edge = compute_edges(face);
            ne = size(edge,2);
            e2f = compute_edge_face_ring(face);
            face1 = [];
            % create faces
            for i=1:ne
                if verb
                    progressbar(i,n+ne);
                end
                v1 = edge(1,i); v2 = edge(2,i);
                F1 = e2f(v1,v2); F2 = e2f(v2,v1);
                if min(F1,F2)<0
                    % special case
                    face1(:,end+1) = [v1 v2 n+max(F1,F2)];
                else
                    face1(:,end+1) = [v1 n+F1 n+F2];
                    face1(:,end+1) = [v2 n+F2 n+F1];
                end
            end
            % move old vertices
            vring0 = compute_vertex_ring(face);
            for k=1:n
                if verb
                    progressbar(k+ne,n+ne);
                end
                m = length(vring0{k});
                beta = (4-2*cos(2*pi/m))/(9*m);         % warren weights
                f1(:,k) = f(:,k)*(1-m*beta) + beta*sum(f(:,vring0{k}),2);
            end
            
        otherwise
            error('Unknown scheme for 1:3 subdivision');
    end
else
    %%%%%% 1:4 subdivision %%%%%
    i = [face(1,:) face(2,:) face(3,:) face(2,:) face(3,:) face(1,:)];
    j = [face(2,:) face(3,:) face(1,:) face(1,:) face(2,:) face(3,:)];
    I = find(i<j);
    i = i(I); j = j(I);
    [tmp,I] = unique(i + 1234567*j);
    i = i(I); j = j(I);
    ne = length(i); % number of edges
    s = n+(1:ne);
    
    A = sparse([i;j],[j;i],[s;s],n,n);
    
    % first face
    v12 = full( A( face(1,:) + (face(2,:)-1)*n ) );
    v23 = full( A( face(2,:) + (face(3,:)-1)*n ) );
    v31 = full( A( face(3,:) + (face(1,:)-1)*n ) );
    
    face1 = [   cat(1,face(1,:),v12,v31),...
        cat(1,face(2,:),v23,v12),...
        cat(1,face(3,:),v31,v23),...
        cat(1,v12,v23,v31)   ];
    
    
    switch interpolation
        case 'linear'
            % add new vertices at the edges center
            f1 = [f, (f(:,i)+f(:,j))/2 ];
            
        case 'butterfly'
            
            global vring e2f fring facej;
            vring = compute_vertex_ring(face1);
            e2f = compute_edge_face_ring(face);
            fring = compute_face_ring(face);
            facej = face;
            f1 = zeros(size(f,1),n+ne);
            f1(:,1:n) = f;
            for k=n+1:n+ne
                if verb
                    progressbar(k-n,ne);
                end
                [e,v,g] = compute_butterfly_neighbors(k, n);
                f1(:,k) = 1/2*sum(f(:,e),2) + 1/8*sum(f(:,v),2) - 1/16*sum(f(:,g),2);
            end
            
        case 'loop'
            
            global vring e2f fring facej;
            vring = compute_vertex_ring(face1);
            vring0 = compute_vertex_ring(face);
            e2f = compute_edge_face_ring(face);
            fring = compute_face_ring(face);
            facej = face;
            f1 = zeros(size(f,1),n+ne);
            f1(:,1:n) = f;
            % move old vertices
            for k=1:n
                if verb
                    progressbar(k,n+ne);
                end
                m = length(vring0{k});
                if loop_weigths==1
                    beta = 1/m*( 5/8 - (3/8+1/4*cos(2*pi/m))^2 );   % loop original construction
                else
                    beta = 3/(8*m);         % warren weights
                end
                f1(:,k) = f(:,k)*(1-m*beta) + beta*sum(f(:,vring0{k}),2);
            end
            % move new vertices
            for k=n+1:n+ne
                if verb
                    progressbar(k,n+ne);
                end
                [e,v] = compute_butterfly_neighbors(k, n);
                f1(:,k) = 3/8*sum(f(:,e),2) + 1/8*sum(f(:,v),2);
            end
            
        otherwise
            error('Unknown scheme for 1:3 subdivision');
    end
end

if spherical
    % project on the sphere
    d = sqrt( sum(f1.^2,1) );
    d(d<eps)=1;
    f1 = f1 ./ repmat( d, [size(f,1) 1]);
end
end

% Alec: midpoint subdivision
function [VV,FF,FO] = upsample(V,F,varargin)
% UPSAMPLE Upsample a mesh by adding vertices on existing edges/faces
%
% [VV,FF] = upsample(V,F)
% [VV,FF,FO] = upsample(V,F,'ParameterName',ParameterValue, ...)
%
% Inputs:
%   V  #V by dim list of vertex positions
%   F  #F by simplex-size list of simplex indices
%   Optional:
%     'KeepDuplicates' followed by either true or {false}}
%     'OnlySelected' followed by a list of simplex indices into F to
%       subdivide.
%     'Iterations' followed by number of recursive calls {1}
% Outputs:
%  VV  #VV by dim list new vertex positions, original V always comes first.
%  FF  #FF by simplex-size new list of face indices into VV
%  FO  #FF list of indices into F of original "parent" simplex
%
% This is Loop subdivision without moving the points
%
% Copyright 2011, Alec Jacobson (jacobson@inf.ethz.ch)
%

%   % Add a new vertex at each face barycenter
%   % compute barycenters
%   C = (V(F(:,1),:)+V(F(:,2),:)+V(F(:,3),:))./3;
%   % append barycenters to list of vertex positions
%   VV = [V;C];
%   % list of indices to barycenters
%   i = size(V,1) + (1:size(C,1))';
%   % New face indices, 3 new face for each original face
%   FF = [F(:,1) F(:,2) i; F(:,2) F(:,3) i; F(:,3) F(:,1) i];
%

%      o           o
%     / \         / \
%    x   x  ---> o---o
%   /     \     / \ / \
%  o---x---o   o---o---o
    function [U14,F14,E14] = one_four(offset,V,F)
        % compute midpoints (actually repeats, one midpoint per edge per face)
        E14 = [F(:,2) F(:,3);F(:,3) F(:,1);F(:,1) F(:,2)];
        U14 = (V(E14(:,1),:)+V(E14(:,2),:))/2;
        % indices of midpoints
        nu = size(U14,1);
        i1 = offset+(1:(nu/3))';
        i2 = offset+((nu/3)) + (1:(nu/3))';
        i3 = offset+((nu/3)+(nu/3)) + (1:(nu/3))';
        % new face indices, 4 new faces for each original face. As if we simply
        % ignored the duplicates in m and had appended m to V
        F14 = [ F(:,1) i3 i2 ; F(:,2) i1 i3 ; F(:,3) i2 i1 ; i1 i2 i3];
    end

%      o           o
%     / \         /|\
%    x   \  ---> o | \
%   /     \     / \|  \
%  o---x---o   o---o---o
    function [U13,F13,E13] = one_three(offset,V,F,M)
        E = [F(:,2) F(:,3);F(:,3) F(:,1);F(:,1) F(:,2)];
        A = cumsum(M,2);
        [SJ,SI] = find(M'==0);
        % Vertex opposite non-subdivided edge
        flip = SJ==2;
        O1  = F(sub2ind(size(A),SI,SJ));
        % Next vertex
        O2  = F(sub2ind(size(A),SI,mod(SJ,3)+1));
        % Next next vertex
        O3  = F(sub2ind(size(A),SI,mod(SJ+1,3)+1));
        % Vertex opposite first subdivided edge
        first = M'==1 & A'==1;
        [SJ,SI] = find(first);
        I1 = sub2ind(size(A),SI,SJ);
        E13 = [ ...
            F(sub2ind(size(A),SI,mod(SJ,3)+1)) ...
            F(sub2ind(size(A),SI,mod(SJ+1,3)+1))];
        % Vertex opposite second subdivided edge
        [SJ,SI] = find(M'==1 & ~first);
        I2 = sub2ind(size(A),SI,SJ);
        E13 = [E13; ...
            F(sub2ind(size(A),SI,mod(SJ,3)+1)) ...
            F(sub2ind(size(A),SI,mod(SJ+1,3)+1))];
        
        % New vertex positions at midpoints
        U13 = (V(E13(:,1),:)+V(E13(:,2),:))/2;
        % indices of midpoints
        nu = size(U13,1);
        i1 = offset+(1:(nu/2))';
        i2 = offset+((nu/2)) + (1:(nu/2))';
        temp1 = i1;
        i1(flip) = i2(flip);
        i2(flip) = temp1(flip);
        F13 = [i1 O1 i2;i2 O2 O3;i2 O3 i1];
        %reshape(F13,[],9)
    end

%      o           o
%     / \         /|\
%    /   \  ---> / | \
%   /     \     /  |  \
%  o---x---o   o---o---o
    function [U12,F12,E12] = one_two(offset,V,F,M)
        [SJ,SI] = find(M'==1);
        O1  = F(sub2ind(size(M),SI,SJ));
        O2  = F(sub2ind(size(M),SI,mod(SJ+0,3)+1));
        O3  = F(sub2ind(size(M),SI,mod(SJ+1,3)+1));
        E12 = [O2 O3];
        % New vertex positions at midpoints
        U12 = (V(E12(:,1),:)+V(E12(:,2),:))/2;
        nu = size(U12,1);
        i1 = offset + (1:nu)';
        F12 = [O1 O2 i1;O1 i1 O3];
    end

keep_duplicates = false;
sel = [];
iters = 1;
% default values
% Map of parameter names to variable names
params_to_variables = containers.Map( ...
    {'KeepDuplicates','OnlySelected','Iterations'}, ...
    {'keep_duplicates','sel','iters'});
v = 1;
while v <= numel(varargin)
    param_name = varargin{v};
    if isKey(params_to_variables,param_name)
        assert(v+1<=numel(varargin));
        v = v+1;
        % Trick: use feval on anonymous function to use assignin to this workspace
        feval(@()assignin('caller',params_to_variables(param_name),varargin{v}));
    else
        error('Unsupported parameter: %s',varargin{v});
    end
    v=v+1;
end
if isempty(sel)
    sel = (1:size(F,1))';
end

if iters<1
    FF = F;
    VV = V;
    FO = (1:size(F,1))';
    return;
end

if islogical(sel)
    sel = find(sel);
end
sel = sel(:);

switch size(F,2)
    % http://mathoverflow.net/questions/28615/tetrahedron-splitting-subdivision
    case 3
        % Add a new vertex at the midpoint of each edge
        nsel = setdiff((1:size(F,1))',sel);
        
        Fsel = F(sel,:);
        
        E = [F(:,2) F(:,3);F(:,3) F(:,1);F(:,1) F(:,2)];
        Esel = [F(sel,2) F(sel,3);F(sel,3) F(sel,1);F(sel,1) F(sel,2)];
        Ensel = [F(nsel,2) F(nsel,3);F(nsel,3) F(nsel,1);F(nsel,1) F(nsel,2)];
        
        [I] = ismember(sort(Ensel,2),sort(Esel,2),'rows');
        nn = numel(nsel);
        M = sparse(repmat(1:nn',1,3),repmat([1 2 3],nn,1),reshape(I,nn,3),nn,3);
        C = sum(M,2);
        M13 = M(C==2,:);
        S13 = nsel(C==2);
        M12 = M(C==1,:);
        S12 = nsel(C==1);
        
        n = size(V,1);
        S14 = union(sel,nsel(C==3));
        
        S11 = setdiff((1:size(F,1))',[S14(:);S13(:);S12(:)]);
        [U14,F14,EU14] = one_four(size(V,1),V,F(S14,:));
        [U13,F13,EU13] = one_three(size(V,1)+size(U14,1),V,F(S13,:),M13);
        [U12,F12,EU12] = one_two(size(V,1)+size(U14,1)+size(U13,1),V,F(S12,:),M12);
        F11 = F(S11,:);
        
        FF = [F14;F13;F12;F11];
        FO = [S14;S14;S14;S14;S13;S13;S13;S12;S12;S11];
        U = [U14;U13;U12];
        EU = [EU14;EU13;EU12];
        nu = size(U,1);
        
        % find unique midpoints (potentially slow, though matlab is good at
        % these)
        if keep_duplicates
            U = U;
            J = (1:nu)';
        else
            [~,I,J] = unique(sort(EU,2),'rows');
            U = U(I,:);
        end
        % append unique midpoints to vertex positions
        VV = [V ; U];
        % reindex map from duplicate midpoint indices to unique midpoint indices
        J = [(1:n)';J+n];
        % reindex faces
        FF = J(FF);
    case 2
        if numel(sel)==size(F,1)
            m = [ (V(F(:,1),:) + V(F(:,2),:))/2 ];
            % indices of new midpoint vertices
            im = size(V,1) + (1:size(m,1))';
            % insert new face indices
            FF = [F(:,1) im;im F(:,2)];
            nf = size(F,1);
            FO = [1:nf 1:nf]';
            % append unique midpoints to vertex positions
            VV = [V;m];
            % No duplicates in 2D case
        else
            Fsel = F(sel,:);
            nsel = setdiff(1:size(F,1),sel);
            Fnsel = F(nsel,:);
            [VV,FF,FO] = upsample(V,Fsel,'KeepDuplicates',keep_duplicates);
            FF = [Fnsel;FF];
            FO = [nsel;sel(FO)];
        end
end

% Recursive call (iters=0 base case will be handled at top)
if isempty(sel)
    sel = 1:size(F,1);
end
[VV,FF,FOr] = upsample( ...
    VV,FF, ...
    'OnlySelected',find(ismember(FO,sel)), ...
    'Iterations',iters-1, ...
    'KeepDuplicates',keep_duplicates);
FO = FO(FOr);

end
