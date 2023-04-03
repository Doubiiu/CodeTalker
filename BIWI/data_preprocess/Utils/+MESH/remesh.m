% remesh    Surface simplification
%
% Usage:
%
%  [surface]   = remesh (surface, opt)
%  [surface]   = remesh (TRI, X, Y, Z, opt)
%  [TRI,X,Y,Z] = remesh (surface, opt)
%  [TRI,X,Y,Z] = remesh (TRI, X, Y, Z, opt)
% 
% Description:
%  
%  Reduces the vertex and face count of a surface using the QSlim
%  algorithm.
%
% Input: 
%
%  TRIV    - ntx3 triangulation matrix with 1-based indices (as the one
%            returned by the MATLAB function delaunay).
%  X,Y,Z   - vectors with nv vertex coordinates.
%  surface - alternative way to specify the mesh as a struct, having .TRIV,
%            .X, .Y, and .Z as its fields.
%  opt       - (optional) settings
%              .placement  [-O] Optimal placement policy (default: 3)
%                                0 - end points, 
%                                1 - end or mid points, 
%                                2 - line, 
%                                3 - optimal
%              .boundary   [-B] Use boundary preservation planes with given weight
%                               (default: 1000)
%              .weight     [-W] Quadric weighting policy (default: 1)
%                                0 - uniform, 
%                                1 - area, 
%                                2 - angle
%              .contract   [-F] Contraction of faces ('faces') or edges ('edges')
%                               (default: 'edges')
%              .penalty    [-m] Penalty for bad meshes (default: 1)
%              .compact    [-c] Compactness ratio (default: 0)
%              .join       [-j] Join only without removing faces (default: 'false')
%              .faces      [-t] Target number of faces 
%              .vertices        Target number of vertices (default: 2000)
%              .verbose         Verbosity level (default: 1)
%                                0 - no display, 
%                                1 - display results
%
% Output: 
%
%  TRIV    - ntx3 triangulation matrix of the simplified surface.
%  X,Y,Z   - list of vertices of the simplified surface.
%  surface - alternative way to specify the simplified surface.
%
% References:
%
% [1] http://www.cs.cmu.edu/~garland/quadrics/
%
% TOSCA = Toolbox for Surface Comparison and Analysis
% Web: http://tosca.cs.technion.ac.il
% Version: 0.9
%
% (C) QSlim 2.0 copyright Michael Garland, 1998.
% (C) Mex iterface copyright Alex Bronstein, 2007.

function [TRIV_, X_, Y_, Z_] = remesh(surface, options)

if isstruct(surface)
    TRI = surface.TRIV;
    X = surface.VERT(:,1);
    Y = surface.VERT(:,2);
    Z = surface.VERT(:,3);
else
    TRI = surface;
    X = varargin{1};
    Y = varargin{2};
    Z = varargin{3};
    varargin = varargin(4:end);
end

opt = [3 1000 1 0 1 0 0];
% verts = min(length(X), 2000);
verts = min(length(X), 1e4);
faces = 0;
verbose = 0;

if nargin > 1
    if isfield(options, 'placement')
        opt(1) = options.placement;
    end
    if isfield(options, 'boundary')
        opt(2) = options.boundary;
    end
    if isfield(options, 'weight')
        opt(3) = options.weight;
    end
    if isfield(options, 'contract')
        if strcmpi(value,'face') || strcmpi(value,'faces')
            opt(4) = 1;
        elseif strcmpi(value,'edge') || strcmpi(value,'edges')
            opt(4) = 0;
        else
            error('Invalid value setting for .contract. Must be "faces" or "edges".');
        end
    end
    if isfield(options, 'penalty')
        opt(5) = options.penalty;
    end
    if isfield(options, 'compact')
        opt(6) = options.compact;
    end
    if isfield(options, 'join')
        if strcmpi(options.join,'true') || value == 1
            opt(7) = 1;
        elseif strcmpi(options.join,'false') || value == 0
            opt(7) = 0;
        else
            error('Invalid value setting for .join. Must be "true" or "false".');
        end
    end
    if isfield(options, 'vertices')
        verts = options.vertices;
    end
    if isfield(options, 'faces')
        faces = options.faces;
    end
    if isfield(options, 'verbose')
        verbose = options.verbose;
    end

end



if verts < 1 && faces < 1
    error('Either face or vertex positive count targets have to be specified.'); 
end

switch opt(1)
    case 0, placement_policy = 'end point';
    case 1, placement_policy = 'end or mid point';
    case 2, placement_policy = 'line';
    case 3, placement_policy = 'optimal';
    otherwise, error('Invalid placement policy. Use .placement = 0-3.');
end

switch opt(3)
    case 0, weighting_policy = 'uniform';
    case 1, weighting_policy = 'area';
    case 2, weighting_policy = 'angle';
    otherwise, error('Invalid weighting policy. Use .weigh = 0-2.');
end

if opt(4), contract = 'face'; else contract = 'edge'; end
if opt(7), join = 'on'; else join = 'off'; end

if verbose > 0
    fprintf (1, 'Surface simplification\n');
    fprintf (1, 'Placement policy:         %s\n', placement_policy);
    fprintf (1, 'Weighting policy:         %s\n', weighting_policy);
    fprintf (1, 'Boundary preserv. weight: %-8.6g\n', opt(2));
    fprintf (1, 'Contraction:              %s\n', contract);
    fprintf (1, 'Bad mesh penalty:         %-8.6g\n', opt(5));
    fprintf (1, 'Compactness ratio:        %-8.6g\n', opt(6));
    fprintf (1, 'Join only:                %s\n', join);
    fprintf (1, 'Original faces:           %-d\n', size(TRI,1));
    fprintf (1, 'Original vertices:        %-d\n', length(X));
    fprintf (1, 'Target faces:             %-d\n', faces);
    fprintf (1, 'Target vertices:          %-d\n', verts);
end


[TRIV_,X_,Y_,Z_] = qslim(TRI, X, Y, Z, faces, verts, opt);
if verbose > 0
    fprintf (1, 'Done. faces = %d vertices = %d\n\n', size(TRIV_,1), length(X_));
end

idx = find( X_.^2 + Y_.^2 + Z_.^2 > 0 );
N = max(idx);
X_ = X_(1:N);
Y_ = Y_(1:N);
Z_ = Z_(1:N);

if nargout <= 1
    surface_ = [];
    surface_.TRIV = TRIV_;
    surface_.VERT    = [X_ Y_ Z_];
    surface_.nv = size(surface_.VERT,1);
    surface_.nf = size(surface_.TRIV,1);
    TRIV_ = surface_;
    if isstruct(surface) && isfield(surface,'D')
        warning('The returned result is an uninitialized surface. Use init_surface to initialize.');
    end
end
    

