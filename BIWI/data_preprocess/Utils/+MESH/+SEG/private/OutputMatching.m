function [ M1, M2, matchID1, matchID2 ] = OutputMatching( M1, M2, matching )
% OUTPUTMATCHES outputs the matched segments files for two shapes such that
% all matching vertices have the same segment id.

n = size(M1.adj, 1);
m = size(M2.adj, 2);

M = logical(matching(1:n,1:m));

%% Step 1: Give an id to each clique of matches:
matchID1 = zeros(n, 1);
matchID2 = zeros(m, 1);
c = 1;
for i=1:n
    % Collect all rows and columns related to that match:
    j = M(i, :);
    ii = M(:, j);
    if (~isempty(ii))
        [ii, ~] = ind2sub(size(ii), find(ii));
        ii = unique(ii);

        jj = M(ii, :);
        [~, jj] = ind2sub(size(jj), find(jj));
        jj = unique(jj);

        matchID1(ii) = c;
        matchID2(jj) = c;
        c = c + 1;

        % Remove used rows from M:
        M(ii, jj) = 0;
    end
end


%% Step 2: Give clique id to each vertex in both M1 and M2:
out1 = zeros(size(M1.GT));
for i=1:n
    out1(M1.GT == i) = matchID1(i);
end

out2 = zeros(size(M2.GT));
for j=1:m
    out2(M2.GT == j) = matchID2(j);
end

% Output match IDs in structures M1 and M2:
M1.output = out1;
M2.output = out2;

end

