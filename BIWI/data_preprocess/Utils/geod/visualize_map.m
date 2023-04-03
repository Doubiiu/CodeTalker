function visualize_map(S1, S2, T12)

g1 = S2.surface.X;
g2 = S2.surface.Y;
g3 = S2.surface.Z;

g1 = normalize_function(0,1,g1);
g2 = normalize_function(0,1,g2);
g3 = normalize_function(0,1,g3);

f1 = g1(T12);
f2 = g2(T12);
f3 = g3(T12);

X1 = S1.surface.X; Y1 = S1.surface.Y; Z1 = S1.surface.Z;
X2 = S2.surface.X; Y2 = S2.surface.Y; Z2 = S2.surface.Z;

subplot(121); 
trimesh(S1.surface.TRIV, X1, Y1, Z1, ...
    'FaceVertexCData', [f1 f2 f3], 'FaceColor','interp', ...
    'FaceAlpha', 0.6, 'EdgeColor', 'none');
axis equal; axis off; title('source')%hold on; 
view([0, 90]); 
subplot(122); 
trimesh(S2.surface.TRIV, X2, Y2, Z2, ...
    'FaceVertexCData', [g1 g2 g3], 'FaceColor','interp', ...
    'FaceAlpha', 0.6, 'EdgeColor', 'none'); 
axis equal; axis off; title('target'); %hold on;
view([0, 90]); 
end