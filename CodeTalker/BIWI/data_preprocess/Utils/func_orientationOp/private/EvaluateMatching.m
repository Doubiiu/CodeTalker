function [ score, score_bim, score_ind ] = EvaluateMatching( M1, M2, bim_map )
% EVALUATEMATCHING Checks that every vertex belongs to matching segments
% in the two shapes.

% Compute vertices area:
S1 = M1.shape.surface;
A1 = vertexAreas([S1.X S1.Y S1.Z], S1.TRIV);
S2 = M2.shape.surface;
A2 = vertexAreas([S2.X S2.Y S2.Z], S2.TRIV);

A = (A1 + A2) / 2;
A = full(A / sum(A));

ns = max(M1.output);
seg_area = zeros(ns, 1);
for i=1:ns
    seg_area(i) = sum(A(M1.output == i));
end;


ind = (M1.output > 0 & M2.output > 0);
score = sum(double(M1.output(ind) == M2.output(ind)) .* A(ind));
% score = sum(double(M1.output(ind) == M2.output(ind)) .* (A(ind).^2) ./ seg_area(M1.output(ind)));

score_ind = score / sum(A(ind));
% score_ind = score / ns;
score_bim = 0;

if (nargin > 2)
    % Evaluate BIM map:
    bim_map = bim_map + 1;
    output1 = zeros(length(M1.GT), 1);
    for i=1:length(output1)
        output1(i) = M2.output(bim_map(i));
    end;

    score_bim = sum(double(output1 == M2.output) .* A);
    
%     seg_area(end+1) = 1;
%     outind = output1;
%     outind(outind == 0) = ns + 1;
%     score_bim = sum(double(output1 == M2.output) .* A ./ seg_area(outind)) / ns;

%     output2 = zeros(length(M2.GT), 1);
%     for i=1:length(M1.GT)
%         output2(bim_map(i)) = M1.GT(i);
%     end;
%     score_bim = sum(double(M1.GT == output2) .* A);
    
%     score_bim2 = sum(double(M1.output == M1.output(bim_map)) .* A);
%     score_bim = sum(M1.GT == M1.GT(bim_map+1)) / length(M1.output);
end;

end

