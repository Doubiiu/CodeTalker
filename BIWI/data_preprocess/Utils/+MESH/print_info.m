function [] = print_info(S)
if ~isfield(S,'name')
    S.name = '';
end

fprintf('-------- Mesh Info: %s --------\n',S.name)
fprintf('The number of vertices: %d\n', S.nv)
fprintf('The number of faces   : %d\n', S.nf)
fprintf(['--------------------',repmat('-',1,length(S.name)),'---------\n'])
end