% generate texture coordinates per vertex by projecting to the plane of
% col1, col2 coordinates (signed) and stretch so that the texture appears
% mult_const times.
function vt = generate_tex_coords(v, col1, col2, mult_const)

vt = [sign(col1)*v(:, abs(col1)), sign(col2)*v(:, abs(col2))];
vt = bsxfun(@minus, vt, min(vt));

max_vt = max(vt(:));
vt = mult_const * vt / max_vt;
end

