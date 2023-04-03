function [nnidx, dists] = annquery(Xr, Xq, k, varargin)
%ANNQUERY Performs Approximate K-Nearest-Neighbor query for a set of points
%
% [ Syntax ]
%   - nnidx = annquery(Xr, Xq, k)
%   - nnidx = annquery(Xr, Xq, k, ...)
%   - [nnidx, dists] = annquery(...)
%   - annquery -doc
%
% [ Arguments ]
%   - Xr:       the reference points to construct the kd-tree (d x n matrix)
%   - Xq:       the query points (d x nq matrix)
%   - k:        the number of neighbors for each query point
%
%   - nnidx:    the array of indices of nearest neighbors (k x n matrix)
%   - dists:    the array of distances between the neighbors and the query
%               points (k x n matrix)
%
% [ Description ]
%   - nnidx = annquery(Xr, Xq, k) finds the nearest neighbors of the query
%     points with default options. 
%
%     Suppose we are dealing with d-dimensional points, and there are n 
%     reference points, and nq query points. Then Xr and Xq should be 
%     d x n and d x nq matrix respectively, with each column representing
%     a point. 
%
%     For each point in Xq (say the i-th point, that is Xq(:,i)), the
%     function finds k nearest points to it in Xr. The indices of these
%     k points in Xr are stored in the i-th column of nnidx. 
%
%   - nnidx = annquery(Xr, Xq, k, ...) performs the k-NN search with
%     user-specified options. The options can be specified by name-value
%     list.
%     
%     Here are the options that can be set
%     \{:
%          - use_bdtree:    whether to use box-decomposition tree
%                           (default = false).
%
%                           bd-tree is a variant kd-tree structure, which
%                           is more effectively in dealing with the highly 
%                           clustered points by incorporating shrinking
%                           operations. However, it is not necessary for
%                           typical datasets.
%       
%          - bucket_size:   the size of each bucket in the tree.
%                           (default = 1).
%
%          - split:         the name of the splitting rule in kd-tree
%                           construction. (default = 'suggest')
%                           
%                           Here is a list of available split rules:
%                           \{:
%                               - std:      the standard kd-tree splitting
%                                           rule
%                               - midpt:    the mid-point splitting rule
%                               - sl_midpt: the sliding mid-point splitting
%                                           rule
%                               - fair:     the fair splitting rule
%                               - sl_fair:  the sliding fair splitting rule
%                               - suggest:  the suggested rule, which
%                                           performs best for typical cases.
%                           \:}
%
%          - shrink:        the name of the shrinking rule in bd-tree
%                           construction. (default = 'suggest')
%
%                           Here is a list of available shrinking rules:
%                           \{:
%                               - none:     no shrinking is performed.
%                                           Without shrinking, bd-tree is
%                                           equivalent to normal kd-tree.
%                               - simple:   simple shrinking. 
%                               - centroid: centroid shrinking.
%                               - suggest:  the suggested rule, which
%                                           performs best for typical
%                                           cases.
%                           \:}
%                           The shrink option only takes effect when
%                           use_bdtree is set to true.
%
%          - search_sch:    the search scheme to use. (default = 'std')
%
%                           Here is a list of available search schemes:
%                           \{:
%                               - std:      the standard k-NN search
%                               - pri:      the priority search
%
%                                           By this scheme, the cell that
%                                           contains the query point is
%                                           located, and cells are visited
%                                           in increasing order of distance
%                                           from the query point.
%
%                               - fr:       the fixed-radius search
%
%                                           By this scheme, only the
%                                           reference points whose
%                                           distances to the query point
%                                           is less than a radius is found.
%                           \:}
%
%          - eps:           the upper bound on the search error.
%
%                           For 1 <= i <= k, the ratio between the distance
%                           to the i-th reported point and that to the true
%                           i-th nearest neighbor is at most 1 + eps.
%
%                           Typically, eps controls the trade-off between 
%                           efficiency and accuracy. When eps is set
%                           larger, the approximation is less accurate, and
%                           the search completes faster.
%
%          - radius:        the maximum distance between the neighbors and
%                           the query point. This option only takes effects
%                           when search_sch is set to 'fr'. In other words,
%                           it only applies to fixed-radius search.
%     \:}
%
%     Generally, the default options can work well for typical cases. In
%     special cases, you can change some options with others left in default
%     value by only specifying the options you would like to change.
%
%   - [nnidx, dists] = annquery(...) also returns the corresponding distance values.
%
%     In the output, dists is a k x nq double matrix. dists(i, j) is the distance of
%     the j's query point's distance to its i-th neighbor. 
%
%     Since that nnidx(i, j) is the index of j's query point's i-th neighbor, 
%     nnidx and dists are corresponding.
%
%   - annquery -doc or annquery('-doc') shows the HTML help in the MATLAB
%     embeded browser.
%
% [ Remarks ]
%   - The function is based on a mex-wrapper (ann_mex.m in private folder)
%     of the Approximate Nearest Neighbors Library version 1.1.1.
%
%   - It is strongly recommended to gather all queries together and conduct
%     the queries in batch. Since for each time this function is invoked, 
%     it constructs the kd-tree from the reference points. Hence, it may
%     lead to considerable overhead if the queries are done one by one.
%
%   - The found nearest points for each query point are sorted in ascending
%     order of distance. It means that the first result refers to the point
%     nearest to the query, while the second one refers to the second
%     nearest, and so on.
%
%   - If fixed-radius scheme is used (set search_sch option to 'fr'), it
%     is probable that for some query points, there are less than k
%     neighbors within the specified range.
%
%     For example, if k = 5, and there are only 2 neighbors in the
%     specified range for the i-th query, then nnidx(:, i) would be a
%     column, in which the first 2 entries are the indices of the two
%     nearest neighbors, while the last 3 entries are all zeros.
%     Correspondingly, the last 3 entries in dists(:, i) are all inf.
%
%     To summarize, the function uses 0 to indicate that a neighbor is not
%     found, and uses inf to give the corresponding distance. This only 
%     applies to fixed-radius scheme. (For other schemes, it is impossible
%     that the neighbors are not sufficient).
%
%   - If fixed-radius search is used, it is required that a positive radius
%     be explicitly set.
%
% [ Examples ]
%   - For each of 100 points of 5 dimensions, find its 3 nearesr neighbors in 
%     a reference set of 200 points, using default options.
%     \{
%         Xq = rand(5, 100);
%         Xr = rand(5, 200);
%
%         inds = annquery(Xr, Xq, 3);
%     \}
%     If you would like to get the corresponding Euclidean distances as
%     well, you can use the following command
%     \{
%         [inds, dists] = annquery(Xr, Xq, 3);
%     \}
%
%   - Use user-specified options.
%     \{
%         % use priority search scheme with a sliding fair rule
%         inds = annquery(Xr, Xq, k, 'search_sch', 'pri', 'split', 'sl_fair');
%
%         % set positive error bound to allow some errors 
%         % in order to increase efficiency
%         inds = annquery(Xr, Xq, k, 'eps', 0.1);
%
%         % use fixed-radius search with all neighbors confined within 
%         % a range of radius 0.08
%         inds = annquery(Xr, Xq, k, 'search_sch', 'fr', 'radius', 0.08);
%
%         % use bd-tree construction
%         inds = annquery(Xr, Xq, k, 'use_bdtree', true);
%
%         % use bd-tree construction with centroid shrinking rule
%         inds = annquery(Xr, Xq, k, 'use_bdtree', true, 'shrink', 'centroid');
%     \}
%
%   - If you want to find neighbors for each point within the same point
%     set with the query point itself excluded from neighbor set. 
%     \{
%         [inds, dists] = annquery(X, X, k+1, ...);
%         
%         inds = inds(2:end, :);
%         dists = dists(2:end, :);
%     \}
%
%     This simple way is based on the rationale that the query point itself
%     is the most nearest point to the query when searching in the same
%     set. It works in most cases.
%
%     However, if there are two points reside in EXACTLY the same position,
%     then it is probable that another point in the same position is
%     removed while the query point remains. However, such circumstances
%     rarely happen in real data. 
%     
% [ History ]
%   - Created by Dahua Lin, on Jul 06, 2007
%

%% For help

if nargin == 1 && ischar(Xr) && strcmpi(Xr, '-doc')
    showdoc(mfilename('fullpath'));
    return;
end
    

%% parse and verify input arguments

narginchk(3, inf);

% some predicates
is_normal_matrix = @(x) isnumeric(x) && ndims(x) == 2 && isreal(x) && ~issparse(x);
is_posint_scalar = @(x) isnumeric(x) && isscalar(x) && x == fix(x) && x > 0;
is_switch = @(x) islogical(x) && isscalar(x);
is_float_scalar = @(x) isfloat(x) && isscalar(x); 

% Xr and Xq
require_arg(is_normal_matrix(Xr), 'Xr should be a full numeric real matrix');
require_arg(is_normal_matrix(Xq), 'Xq should be a full numeric real matrix');
        
[d, n] = size(Xr);
require_arg(size(Xq, 1) == d, 'The point dimensions in Xr and Xq are inconsistent.')

% k
require_arg(is_posint_scalar(k), 'k should be a positive integer scalar');
require_arg(k <= n, 'The value k exceeds the number of reference points');         

% options
opts = struct( ...
    'use_bdtree', false, ...
    'bucket_size', 1, ...
    'split', 'suggest', ...
    'shrink', 'suggest', ...
    'search_sch', 'std', ...
    'eps', 0, ...
    'radius', 0);

if ~isempty(varargin)
    opts = setopts(opts, varargin{:});
end

require_opt(is_switch(opts.use_bdtree), 'The option use_bdtree should be a logical scalar.');
require_opt(is_posint_scalar(opts.bucket_size), 'The option bucket_size should be a positive integer.');

split_c = get_name_code('splitting rule', opts.split, ...
                        {'std', 'midpt', 'sl_midpt', 'fair', 'sl_fair', 'suggest'});

if opts.use_bdtree                    
    shrink_c = get_name_code('shrinking rule', opts.shrink, ...
                             {'none', 'simple', 'centroid', 'suggest'});
else
    shrink_c = int32(0);
end

ssch_c = get_name_code('search scheme', opts.search_sch, ...
                        {'std', 'pri', 'fr'});

require_opt(is_float_scalar(opts.eps) && opts.eps >= 0, ...
            'The option eps should be a non-negative float scalar.');

use_fix_rad = strcmp(opts.search_sch, 'fr');
if use_fix_rad
    require_opt(is_float_scalar(opts.radius) && opts.radius > 0, ...
                'The option radius should be a positive float scalar in fixed-radius search');
    rad2 = opts.radius  * opts.radius;
else
    rad2 = 0;
end
        
%% main (invoking ann_mex)

internal_opts = struct( ...
    'use_bdtree', opts.use_bdtree, ...
    'bucket_size', int32(opts.bucket_size), ...
    'split', split_c, ...
    'shrink', shrink_c, ...
    'search_sch', ssch_c, ...
    'knn', int32(k), ...
    'err_bound', opts.eps, ...
    'search_radius', rad2);

[nnidx, dists] = ann_mex(Xr, Xq, internal_opts);

nnidx = nnidx + 1;        % from zero-based to one-based        
if nargout >= 2
    dists = sqrt(dists);  % from squared distance to euclidean
    
    if use_fix_rad
        dists(nnidx == 0) = inf;
    end
end


%% Auxiliary function

function c = get_name_code(optname, name, names)

require_opt(ischar(name), ['The option ' optname ' should be a string indicating a name.']);

cidx = find(strcmp(name, names));
require_opt(~isempty(cidx), ['The option ' optname ' cannot be assigned to be ' name]);

c = int32(cidx - 1);


function require_arg(cond, msg)

if ~cond
    error('ann_mwrapper:annquery:invalidarg', msg);
end

function require_opt(cond, msg)

if ~cond
    error('ann_mwrapper:annquery:invalidopt', msg);
end

