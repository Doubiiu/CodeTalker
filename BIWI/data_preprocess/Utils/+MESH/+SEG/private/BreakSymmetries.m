%%% BreakSymmetries(R)
% This function breaks the symmetry of a given matching between shapes,
% producing two (or more) possible non-symmetric matchings.
%
% Input: A matching construct R which is the result of MatchMeshesSym.
%
% Algorithm:
% * Select one segment which have symmetric matches. Decide arbitrarily on
%   one matching segment from the second shape (repeat for the two options)
% * Compute average geodesic distances to all other segments
% * Order segments according to distance to selected segments and use the order as a score for each segment.
% * Break symmetries using said score.
%
%%% If you use this code, please cite the following paper:
%  
%  Robust Structure-based Shape Correspondence
%  Yanir Kleiman and Maks Ovsjanikov
%  Computer Graphics Forum, 2018
%
%%% Copyright (c) 2017 Yanir Kleiman <yanirk@gmail.com>
function [ R ] = BreakSymmetries( R )


n = size(R.matching, 1);
m = size(R.matching, 2);

matching = R.matching;
altmatching{1} = matching;

%% Step 1 - find a segment which have two matches in the second shape:

row_groups = find(sum(matching, 2) > 1);
row_2s = find(sum(matching, 2) == 2);
if (~isempty(row_groups))

    if (~isempty(row_2s))
        seg1 = row_2s(1);
    else
        seg1 = row_groups(1);
    end

    seg2row = find(matching(seg1, :));
    nalt = length(seg2row);
    
    altmatching = cell(nalt, 1);

    for si=1:nalt
        
        matching = R.matching;
        row_groups = find(sum(matching, 2) > 1);
        
        % circulate which segments are matched according to the first segment:
        seg2 = seg2row(si);

        % Find vertices associated with selected segments:
        v1 = find(R.M1.GT == seg1);
        v2 = find(R.M2.GT == seg2);

        while (~isempty(row_groups))
            %% Step 2 - compute average geodesic distances to all other segments in each shape:

            D1 = geodesics_to_all(R.M1.shape, v1);
            D2 = geodesics_to_all(R.M2.shape, v2);

            D1_segs = accumarray(R.M1.GT, D1, [], @mean);
            D2_segs = accumarray(R.M2.GT, D2, [], @mean);

            %% Step 3 - find group of segments with lowest distance to selected distance,
            %  and break symmetries of this group:    
            [min_val, mi] = min(D1_segs(row_groups));
            i = row_groups(mi);

            % Find the segments of this group in the second shape:
            jj = find(matching(i, :));

            % Find which of these segment is closest to v2:
            [min_val, mj] = min(D2_segs(jj));
            j = jj(mj);

            %% Step 4 - set matching between i and j:
            matching(i, :) = 0;
            matching(:, j) = 0;
            matching(i, j) = 1;

            %% Step 5 - add vetrices to set of core vertices:
            v1 = [v1; find(R.M1.GT == i)];
            v2 = [v2; find(R.M2.GT == j)];

            %% Step 6 - find remaining groups:
            row_groups = find(sum(matching, 2) > 1);


        end

        altmatching{si} = matching;
    end
end


R.matching = altmatching{1};
R.altmatching = altmatching;

end

