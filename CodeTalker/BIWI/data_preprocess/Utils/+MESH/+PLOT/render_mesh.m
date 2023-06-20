% 2018-10-17: rendering a mesh, using **gptoolbox**
% 'MeshVtxColor':
%       same as 'FaceVertexCData', n-by-1 or n-by-3 matrix
%       note that, if we want to add the isolines (i.e., set IfPlotIsolines to true)
%       this needs to be a n-by-1 vector (a scalar function to find the isolines)
% 'LightPos': the 3D position of the light
% 'CameraPos': the position of the camera/view
% 'BackgroundColor': the background color
% 'RotationOps': a cell of rotation vectors (apply the rotations in a seq)
% 'VecField': vector field
function [t,X] = render_mesh(S,varargin)
default_param = load_MeshPlot_default_params(S);
param = parse_MeshPlot_params(default_param, varargin{:});

X = param.VtxPos;
T = S.surface.TRIV;
f = param.MeshVtxColor;

if ~isempty(param.RotationOps)
    center = mean(X);
    X = X - center;
    for i = 1:length(param.RotationOps)
        R = param.RotationOps{i};
        X = X*rotx(R(1))*roty(R(2))*rotz(R(3));
    end
    X = X + center;
end

% plot the mesh
t = trimesh(T, X(:,1), X(:,2), X(:,3),...
    'FaceColor',param.FaceColor,...
    'FaceAlpha',param.FaceAlpha,...
    'EdgeColor',param.EdgeColor);
axis equal; axis off; hold on;
view(param.CameraPos);

teal = [144 216 196]/255;
pink = [254 194 194]/255;
orange = [249,198,7]/255;

if ~isempty(param.VecField)
    J = param.VecField;
    if size(J,1) == S.nv
        quiver3(X(:,1),X(:,2),X(:,3),J(:,1),J(:,2),J(:,3));
    elseif size(J,1) == S.nf
        T = S.surface.TRIV;
        Fc = (X(T(:,1),:) + X(T(:,2),:) + X(T(:,3),:))/3;
        quiver3(Fc(:,1),Fc(:,2),Fc(:,3),J(:,1),J(:,2),J(:,3),'Color',[0.5,0.3,0.3],'LineWidth',0.8);
    else
        error('Wrong: size of the vector field')
    end
end

set(t,'FaceColor','interp','FaceLighting','phong',...
    'FaceVertexCData',f);
set(t,'SpecularStrength',0.2,'DiffuseStrength',0.2,'AmbientStrength',0.8);


l = light('Position',param.LightPos);
bg_color = param.BackgroundColor;
set(gca,'Visible','off');
set(gcf,'Color',bg_color);

% add isolines if MeshVtxColor is a scalar function
if param.IfPlotIsolines
    p = add_isolines(t,'LineWidth',0.8,'LineStyle','--');
end

% add the shadows
s = add_shadow(t,l,'Color',bg_color*0.8,'BackgroundColor',bg_color,'Fade','infinite');

end