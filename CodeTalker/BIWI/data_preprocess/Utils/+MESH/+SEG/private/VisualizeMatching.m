%%% VisualizeMatching(R, filename, method)
% Visualizes the matching between two shapes by displaying
% them side by side. Matching regions have the same color.
%
%%% If you use this code, please cite the following paper:
%  
%  Robust Structure-based Shape Correspondence
%  Yanir Kleiman and Maks Ovsjanikov
%  Computer Graphics Forum, 2018
%
%%% Copyright (c) 2017 Yanir Kleiman <yanirk@gmail.com>
function [ R ] = VisualizeMatching( R, filename, method )

% Color map: [Yellow, Purple, Turquoise, Green, Blue, Orange, Red, Dark Blue, Dark Green, Dark Red, Light Gray, Dark Gray, Pink, 
%              Dark Dark Green, Dark Dark Red, Dark Dark Blue, Dark Dark Cyan, Dark Dark Brown, Dark Dark Purple, Dark Dark Gray (Black)
%               Saturated Yellow, Saturated Green, Saturated Blue]
cmap = [0.2 0.2 0.2 % Very dark gray = no match
          0.55 0.33 0.7;
          0.80 0.70 0.45;   %0.88 0.86 0.45;
          0.5 0.8 0.45;
          0.35 0.45 1;
          1 0.55 0.3;
          1 0.3 0.5;
          0.2 0.6 0.8;
          0.2 0.8 0.5;
          0.65 0.2 0.2;
          0.47 0.78 0.7;
          0.5 0.5 0.5;
          0.95 0.65 0.8;
          0.1 0.5 0.1;
          0.5 0.2 0.3;
          0.1 0.1 0.5;
          0.1 0.4 0.4;
          0.4 0.4 0.1;
          0.4 0.1 0.4;
          0.75 0.75 0.75;
          0.9 0.9 0.1;
          0.1 0.9 0.1;
          0.1 0.1 0.9;
            1 0.6 0.6;   % light red
            0.6 1 0.6;   % light green
            0.6 0.6 1;   % light blue
            0.5 0.1 0.1; % dark red
            0.1 0.5 0.1; % dark green
            0.1 0.1 0.5; % dark blue
            1 0.8 0.5;   % orange?
            0.6 0.5 0;   % brown?
            0.7 0.3 1;   % purple?
            0.7 0.7 0.7; % light gray% % [x, ~] = eigs(Aff, 1);
            0.4 0.4 0.4; % dark gray
          0.9 0.1 0.1; % red
            0.1 0.9 0.1; % green% % [x, ~] = eigs(Aff, 1);
            0.1 0.1 0.9; % blue
            1.0 1.0 0.0;       % yellow
            0.0 1.0 1.0;       % cyan
            1.0 0.0 1.0;       % magenta
            0.24 0.53 0.66; % random 1
            0.04 0.69 0.3;  % random 2
            0.9 0.4 0.67;   % random 3
            0.4 0.5 0.6];     % random 4


n = size(R.matching, 1);
m = size(R.matching, 2);

f = figure;

if (nargin < 2)
    filename = [];
end

hold on;

sp_i = 1;
sp_j = 2;
sp_k = 1;

if (nargin < 3)
    method = 'default';
end

if (strcmp(method, 'fos'))
    %% First Order Spectral Eig
    title('First Order Spectral');
    B = R.Aff;
    B(eye(size(B)) == 0) = 0;
    x_fos = firstEig(B);
    x_fos = reshape(x_fos, n, m);
    matching = Discretize2(x_fos);


elseif (strcmp(method, 'fo'))

    %% First Order Maximum In Row
    title('First Order Max');
    x_fo = reshape(diag(R.Aff), n, m);
    matching = DiscretizeDense(x_fo);


elseif (strcmp(method, 'fog'))
    %% First Order Global Maximum
    title('First Order Global Maximum');
    x_fo = reshape(diag(R.Aff), n, m);
    matching = DiscretizeSimple(x_fo);

elseif (strcmp(method, 'so'))
    %% Second Order Spectral EIG
    title('Second Order Spectral');
    x_sos = firstEig(R.Aff);
    x_sos = reshape(x_sos, n, m);
    matching = DiscretizeDense(x_sos);

elseif (strcmp(method, 'our'))

    %% Diminished Second Order
    title('Our Method');
    B = FindSecondOrderScale(R.Aff);
    x_dso = firstEig(B);
    x_dso = reshape(x_dso, n, m);
    matching = Discretize2(x_dso);
    
elseif (strcmp(method, 'default'))
    matching = R.matching;
end

% %% My Method:
% 
% [ R.M1, R.M2 ] = OutputMatching( R.M1, R.M2, R.matching );
% subtosca([sp_i sp_j sp_k], R.M1);
% title('Our Method', 'HorizontalAlignment', 'left');
% subtosca([sp_i sp_j sp_k+1], R.M2);
% 
% sp_k = sp_k + 2;

% VisualizeMatching(R.M1, R.M2, 'Our Method');
if (strcmp(method, 'gt'))
    r1 = randperm(max(R.M1.GT));
    r2 = randperm(max(R.M2.GT));

    R.M1.output = r1(R.M1.GT);
    R.M2.output = r2(R.M2.GT);
elseif (~strcmp(method, 'output'))
    [ R.M1, R.M2 ] = OutputMatching( R.M1, R.M2, matching );
end

if (isfield(R.M1.shape, 'PCD'))
    subtosca_pcd([sp_i sp_j sp_k], R.M1);
else
    subtosca([sp_i sp_j sp_k], R.M1);
end
if (isfield(R.M2.shape, 'PCD'))
    subtosca_pcd([sp_i sp_j sp_k+1], R.M2);
else
    subtosca([sp_i sp_j sp_k+1], R.M2);
end

colormap(cmap);

if (nargin > 1 && ~isempty(filename))
    print(f, filename, '-r300', '-dpng');
    %save(filename, 'R');
end


    function [ e ] = firstEig(Aff)
        [V, ~] = eig(Aff);
        e = abs(V(:, end));
    end
    
    function [] = subtosca(sp, M)
%         if (size(M.GT, 1) == 52565)
%             ry = 30;
%             rx = 20;
%             rz = -20;
%         else
%             ry = 0;
%             rx = -50;
%             rz = 220;
%         end;
 
%%% FOR TOSCA:
%         ry = 30;
%         rx = 20;
%         rz = -20;
%%% FOR FAUST:
        ry = 0;
        rx = -80;
        rz = 60;
%%%

        subplot(sp(1), sp(2), sp(3));
        c = M.output + 1;
        
        % Set the color of each face according to the majority of its
        % vertices:
        S = M.shape.surface;
        nf = length(S.TRIV);
        cf = zeros(nf, 1); % color faces instead of vertices
        
        for i=1:nf
            face = S.TRIV(i, :);
            cf(i) = max(c(face));

        end
       
        
        % For Armadillos:
        s = M.shape.surface;
        xyz = [s.X s.Y s.Z];
         ang = ry/180*pi;
%        ang = -90/180*pi;
%        ang = 0;
        roty = [cos(ang) 0 -sin(ang); 0 1 0; sin(ang) 0 cos(ang)];
%         ang = -80/180*pi;
       ang = rx/180*pi;
%        ang = 0/180*pi;
        rotx = [1 0 0 ; 0 cos(ang) -sin(ang); 0 sin(ang) cos(ang)];
         ang = rz/180*pi;
%        ang = 80/180*pi;
%        ang = 170/180*pi;
        rotz = [cos(ang) -sin(ang) 0; sin(ang) cos(ang) 0; 0 0 1];
        xyz = xyz * roty * rotx * rotz;
        M.shape.surface.X = xyz(:, 1);
        M.shape.surface.Y = xyz(:, 2);
        M.shape.surface.Z = xyz(:, 3);
        
        
        plot_function(M.shape.surface, cf);
        caxis([1 length(cmap)]);
        MakeFigureNice();
    end



    function [ ] = MakeFigureNice( )

        % Set aspect ratio
        daspect([1 1 1]);

        material dull;

        % Set lightning
        lighting flat;

        %%% EIGHT point lighting !!!
        light('Position',[1 1 1],'Style','infinite', 'Color', [0.5 0.5 0.5]);
        light('Position',[1 1 -1],'Style','infinite', 'Color', [0.2 0.2 0.2]);
        light('Position',[1 -1 1],'Style','infinite', 'Color', [0.7 0.7 0.7]);
        light('Position',[1 -1 -1],'Style','infinite', 'Color', [0.5 0.5 0.5]);
        light('Position',[-1 1 1],'Style','infinite', 'Color', [0.2 0.2 0.2]);
        light('Position',[-1 1 -1],'Style','infinite', 'Color', [0.2 0.2 0.2]);
        light('Position',[-1 -1 1],'Style','infinite', 'Color', [0.9 0.9 0.9]);
        light('Position',[-1 -1 -1],'Style','infinite', 'Color', [0.2 0.2 0.2]);


    end

    function [] = subtosca_pcd(sp, M)

        subplot(sp(1), sp(2), sp(3));
        
        
%%% FOR TOSCA:
%         ry = 30;
%         rx = 20;
%         rz = -20;
%%% FOR FAUST:
        ry = 0;
        rx = -80;
        rz = 60;
%%%
        
        % For Armadillos:
         ang = ry/180*pi;
%        ang = -90/180*pi;
%        ang = 0;
        roty = [cos(ang) 0 -sin(ang); 0 1 0; sin(ang) 0 cos(ang)];
%         ang = -80/180*pi;
       ang = rx/180*pi;
%        ang = 0/180*pi;
        rotx = [1 0 0 ; 0 cos(ang) -sin(ang); 0 sin(ang) cos(ang)];
         ang = rz/180*pi;
%        ang = 80/180*pi;
%        ang = 170/180*pi;
        rotz = [cos(ang) -sin(ang) 0; sin(ang) cos(ang) 0; 0 0 1];

        xyz = M.shape.PCD;
        xyz = xyz * roty * rotx * rotz;
        
        
        % color of markers:
        c = M.output + 1;
        
        nv = length(c);
        
        
        plot_function_pcd(xyz, c);
        caxis([1 length(cmap)]);
    end

end


