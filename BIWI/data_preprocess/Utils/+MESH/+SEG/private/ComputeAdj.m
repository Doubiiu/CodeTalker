function [ adj_n ] = ComputeAdj( adj )
% COMPUTEADJ Computes distance between nodes from binary adjacency matrix

    nseg = size(adj, 1);

    % Calculate higher level adjacencies and keep the minimum value in
    % adjacency matrix:
    adj_i = adj; 
    adj_n = adj;

    for i=2:nseg
        adj_i = adj_i * adj;
        % If segment b can be reached from segment a in i steps and no less
        % the value of adj_n(a, b) will be i:
        adj_n((adj_n == 0) & (adj_i > 0)) = i;
    end
    %%%%% FIX: taking care of parts that cannot be reached (adj = 0):
    adj_n(adj_n == 0) = nseg + 1;
    
    for i=1:nseg
        adj_n(i, i) = 0;
    end


end

