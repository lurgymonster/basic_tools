function [p, cg] = cubeHist2( x, y, Z, varargin )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%     varargin{1}

    if ~isempty(varargin)
        fnSw = parseArgs(varargin{1});
    else
        fnSw = parseArgs();
    end
    
%     fnSw
    
    figure(gcf); hold on;
    uz = unique(Z(:)); numel(uz);
    
    cg = eval([fnSw.colormap, '(numel(uz))']); %whos cg
%     col1 = [1, 0, 0];
%     col2 = [0, 0, 1];
%     cg = colorGradient(col1,col2,numel(uz));
    
    dx = mode(diff(x));
    dy = mode(diff(y));

    nx = numel(x);
    ny = numel(y);
    for xii = 1:nx
        for yii = 1:ny
            r0 = [x(xii), y(yii), 0];
%             sum(Z(xii, yii)==uz)
            if ~isnan(Z(yii, xii))
                col = cg(Z(yii, xii)==uz, :);
                p = cube_plot(r0, dx, dy, Z(yii, xii), col, fnSw);
                if fnSw.do_alphaBlending
                    alphaScaleVal = (Z(yii, xii)/max(max(Z)))^2;
                    alpha(p, alphaScaleVal);
                    alphamap('rampup');
                end            
            end           
        end
    end
    axis vis3d
    % Show grids on the plot
    grid on;
%     xlabel('X','FontSize',18);
%     ylabel('Y','FontSize',18)
%     zlabel('Z','FontSize',18)
    h = gca; % Get the handle of the figure
    material metal

    % Set the view point
    view(30,30);

end

function p = cube_plot(origin,X,Y,Z,color, fnSw)
    % CUBE_PLOT plots a cube with dimension of X, Y, Z.
    %
    % INPUTS:
    % origin = set origin point for the cube in the form of [x,y,z].
    % X      = cube length along x direction.
    % Y      = cube length along y direction.
    % Z      = cube length along z direction.
    % color  = STRING, the color patched for the cube.
    %         List of colors
    %         b blue
    %         g green
    %         r red
    %         c cyan
    %         m magenta
    %         y yellow
    %         k black
    %         w white
    % OUPUTS:
    % Plot a figure in the form of cubics.
    %
    % EXAMPLES
    % cube_plot(2,3,4,'red')
    %
    % ------------------------------Code Starts Here------------------------------ %
    % Define the vertexes of the unit cubic
    ver = [1 1 0;
        0 1 0;
        0 1 1;
        1 1 1;
        0 0 1;
        1 0 1;
        1 0 0;
        0 0 0];
    %  Define the faces of the unit cubic
    fac = [1 2 3 4;
        4 3 5 6;
        6 7 8 5;
        1 2 8 7;
        6 7 1 4;
        2 3 5 8];
    cube = [ver(:,1)*X+origin(1),ver(:,2)*Y+origin(2),ver(:,3)*Z+origin(3)];
    p = patch('Faces',fac,'Vertices',cube,'FaceColor',color);
    if fnSw.do_eliminateEdges
        set(p, 'EdgeColor', 'none');
    end
end

%%
function fnSw = parseArgs(varargin)
    if ~isempty(varargin)
        fnSw = varargin{1};
    else
        fnSw = struct();
    end
    
    if ~isfield(fnSw, 'colormap')
        fnSw.colormap = 'jet';
    end
    
    % default function switches
    if ~isfield(fnSw, 'do_alphaBlending')
        fnSw.do_alphaBlending = 0;
    end
    if ~isfield(fnSw, 'do_eliminateEdges')
        fnSw.do_eliminateEdges = 0;
    end
    
end

