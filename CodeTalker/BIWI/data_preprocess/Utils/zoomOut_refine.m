function [T12, C21, all_T12, all_C21] = zoomOut_refine(B1_all, B2_all, T12, para)

if nargout > 2, all_T12 = {}; all_C21 = {}; end

for k = para.k_init : para.k_step : para.k_final
    B1 = B1_all(:, 1:k);
    B2 = B2_all(:, 1:k);
    C21 = B1\B2(T12,:);
    T12 = knnsearch(B2*C21', B1);

    if nargout > 2, all_T12{end+1} = T12; all_C21{end+1} = C21;

end

end