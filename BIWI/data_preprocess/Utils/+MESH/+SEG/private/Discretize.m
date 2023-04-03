function [ out ] = Discretize( Xm )
% DISCRETIZE Converts a continuous vector to a discretize matching matrix

n = size(Xm, 1);
m = size(Xm, 2);

out_i = zeros(n, m);

%%% Rows:
for i=1:n
    x = Xm(i, :); 
    [sort_val, sort_ind] = sort(x, 'descend');
    diff = (sort_val(1:end-1) - sort_val(2:end)) ./ sort_val(1:end-1);
    diff(sort_val(1:end-1) == 0) = 0;
    
    f = find(diff > 0.05, 1, 'first');
    if (f <= 10)
        ind = sort_ind(1:f);
        out_i(i, ind) = 1;
    end
end

%%% Columns:
out_j = zeros(n, m);
for j=1:m
    x = Xm(:, j); 
    [sort_val, sort_ind] = sort(x, 'descend'); 
    diff = (sort_val(1:end-1) - sort_val(2:end)) ./ sort_val(1:end-1);
    diff(sort_val(1:end-1) == 0) = 0;

    f = find(diff > 0.05, 1, 'first');
    if (f <= 10)
        ind = sort_ind(1:f);
        out_j(ind, j) = 1;
    end
end

% Output only matches which appear in both rows and columns, i.e. the match
% of a region is mapped back to the same region when running on the second
% shape.
out = out_i & out_j;

end

