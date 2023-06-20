function plot_vf(mesh,vf,ff,fids,dirs)

X = mesh.vertices; 
T = mesh.triangles;
Xm = (X(T(:,1),:)+X(T(:,2),:)+X(T(:,3),:))/3;

nf = mesh.nf;

if nargin > 2
    fv = ff;
else
    fv = normv(vf);
end

% vf = vf ./ repmat(normv(vf),1,3);
hold on; show_func(mesh,fv); 
% plot_vf_fquiver2(mesh,nf/2,vf);
plot_vf_fquiver2(mesh,1,vf);
colorbar;

if nargin > 3
    show_direction(Xm,fids,dirs,'k');
end

hold off;