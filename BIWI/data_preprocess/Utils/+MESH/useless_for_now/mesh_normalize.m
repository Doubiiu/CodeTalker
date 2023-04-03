function S_new = mesh_normalize(S,a)
    X = [S.surface.X, S.surface.Y, S.surface.Z];
    val = norm(X);
    if nargin < 2, a = 10; end
    S_new.surface.X = a*S.surface.X/val;
    S_new.surface.Y = a*S.surface.Y/val;
    S_new.surface.Z = a*S.surface.Z/val;
    S_new.surface.TRIV = S.surface.TRIV;
end