function diam = shapeDiameter(S)
% Shape diameter
d = geodesics_to_all(S, 1);
[~,i] = max(d);
d = geodesics_to_all(S, i);
diam = max(d);
end
