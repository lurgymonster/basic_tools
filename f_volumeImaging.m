function nOcc3 = f_volumeImaging(pept_si_col, varargin)
%% Generate 3D occupancy distribution of PEPT tracer within volume 
% supply PEPT_SI_COL structure
% and function switch structure FNSW with possible fields [default]
%   - smoothing method: 
%       fnSw.do_smoothing = ['none'], 'box', 'gaussian'
%   - show distribution plots
%       fnSw.do_densityDistrPlots = [0], 1
%   - do dynamic rotation of output plot
%       fnSw.do_rotate3Dplot = [0], 1
%   - choose colour map
%       fnSw.cMap = ['default'], any matlab color maps
%   - transparency gradiation parameter (higher is more transparency)
%       fnSw.alphaN = [0.5] 
%   - number of isosurfaces to plot
%       fnSw.numIso = [20]
%   - number of bins in distribution histograms
%       fnSw.nDistBins = [20]
%   - fraction of occupancy distribution to discard at the high end
%       fnSw.eSat = [1e-3]
%   - split dimension
%       fnSw.splitDim = ['x'] can be 0, 'x', 'y' and will determine the
%       dimension along which to split the volume distribution open for
%       internal visualisation, or zero to show external view of volume

    if ~isempty(varargin)
        fnSw = parseArgs(varargin{1});
    else
        fnSw = parseArgs();
    end
    fnSw
    varargout = {};
    
    sum3 = @(x) sum(sum(sum(x)));
    
    %% add to path
%     addpath('..\general_code\');
%     addpath('..\analysisRoutines\');
%     addpath('..\');

    %%
    structTmp = pept_si_col;
   
    xbins = fnSw.bins(1);
    ybins = fnSw.bins(2);
    zbins = fnSw.bins(3);

    x = structTmp.x - mean(structTmp.x);
    y = structTmp.y - mean(structTmp.y);
    z = structTmp.z - mean(structTmp.z);
    r = sqrt(structTmp.x.^2+structTmp.y.^2);

    if ~isfield(fnSw, 'rSel')
        fnSw.rSel = 1:numel(x);
    end
    rSel = fnSw.rSel;
    x = x(rSel); y = y(rSel); z = z(rSel);

    % xi = linspace(min(x), max(x), xbins); dx = mode(diff(xi));
    % yi = linspace(min(y), max(y), ybins); dy = mode(diff(yi));
    xi = linspace(min(x), max(x), xbins);
    yi = linspace(min(y), max(y), ybins);
    zi = linspace(min(z), max(z), zbins);

    dx = mode(diff(xi));
    dr = mode(diff(yi));
    dz = mode(diff(zi));

    % define regular interpolated grid for binning
    xr = interp1(xi, 0.5:numel(xi)-0.5, x, 'nearest');
    yr = interp1(yi, 0.5:numel(yi)-0.5, y, 'nearest');
    zr = interp1(zi, 0.5:numel(zi)-0.5, z, 'nearest');

    % bin in 3D using accumarray to populate the xbins*ybins*zbins matrix
    nOcc3 = accumarray([xr, yr, zr]+0.5, 1, [xbins ybins zbins]);

    smoothSize = 7;
    % optional smoothing of occupancy matrix
    switch fnSw.do_smoothing
        case{'box'}
            nOcc3 = smooth3(nOcc3, 'box', smoothSize);
        case{'gaussian'}
            nOcc3 = smooth3(nOcc3, 'gaussian', smoothSize);
        case{'default'}
            nOcc3 = smooth3(nOcc3);
    end

    %% density calculations
    if fnSw.do_densityDistrPlots
        close all;
        
        rho_tr = 1.5 * 1000;            % kg/m^3, tracer density
        rho_med = 1.4 * 1000;           % kg/m^3, medium density 
        tracerSize = 2/1000;            % mm
        Vol_tr = 1/6*pi*(tracerSize)^3; % m^3, volume of tracer
        Vol_vox = dx*dr*dz;             % m^3, volume of voxel
        Vol_ratio = Vol_tr/Vol_vox;     % ratio of tracer to voxel volume
        
        % cumulative tracer mass matrix
        M_tr = rho_tr * Vol_tr * nOcc3;
        % associated medium mass matrix
        m_med = rho_med * (Vol_vox - nOcc3 * Vol_tr);
        % density per voxel matrix
        rho_vox = (M_tr + m_med)/Vol_vox / 1000; % g/cm^3

        
        figure;
        [nOcc3_fr, nOcc3_bins] = plotDistr(nOcc3(:), fnSw.nDistBins);
        title('Distribution: Occupancy numbers per voxel');
        
        figure; 
        plotDistr(M_tr(:), fnSw.nDistBins);
        title('Distribution: Mass of tracer instances within voxel volume');

        figure; 
        plotDistr(m_med(:), fnSw.nDistBins);
        title('Distribution: Mass of medium within voxel volume');

        %
        figure; 
        plotDistr(rho_vox(:), fnSw.nDistBins);
        title('Distribution: average density within voxel volume');
        
        % determine maximum value for occupancy isosurface
        
    else
        [nOcc3_fr, nOcc3_bins] = hist(nOcc3(:), fnSw.nDistBins);    
        figure; bar(nOcc3_bins, nOcc3_fr, 1);
    end
    sat = cumsum(nOcc3_fr)/sum(nOcc3_fr);
    nOcc3_max = [];
    while isempty(nOcc3_max)
        nOcc3_max = nOcc3_bins(find(sat<(1-fnSw.eSat), 1, 'last'));
        fnSw.eSat = fnSw.eSat/10;
    end
    
    %% debug
%     nOcc3_max
%     fnSw.eSat
%     whos nOcc3* sat

    %%
    sampleVal_range = linspace(1, nOcc3_max, fnSw.numIso);
    fig1 = figure('Backingstore','off'); % , ...
    %   'Backingstore','off', 'renderer','zbuffer');
    % set(fig1, 'renderer', 'opengl');
    formatFigure(gcf);
    splitDim = fnSw.splitDim;
    for sii = 1:numel(sampleVal_range)
        if ~fnSw.splitDim
            visualise3D(xi, yi, zi, nOcc3, ...
                sampleVal_range, sii, fnSw.alphaN);
        else            
            % --==--
            [xtmp, ytmp, ztmp] = deal(xi, yi, zi);
            splitVar = eval([fnSw.splitDim, 'tmp']);
    %         selInd = 1:numel(xi);
            selInd = 1:round(numel(splitVar)/2);
            switch splitDim
                case{'x'}
                    xtmp = xtmp(selInd);
                    Vtmp = nOcc3(:, selInd, :);
                case{'y'}
                    ytmp = ytmp(selInd);
                    Vtmp = nOcc3(selInd, :, :);
                case{'z'}
                    ztmp = ztmp(selInd);
                    Vtmp = nOcc3(:, :, selInd);
            end
    %         whos *tmp
            visualise3D(xtmp, ytmp, ztmp, Vtmp, ...
                sampleVal_range, sii, fnSw.alphaN);

            % --==--
            [xtmp, ytmp, ztmp] = deal(xi, yi, zi);

            selInd = round((numel(splitVar)/2+1)):numel(splitVar);
            dr = abs(max(splitVar))*2.1;
            switch splitDim
                case{'x'}
                    xtmp = -xtmp(selInd);
                    ytmp = -ytmp + dr;
                    Vtmp = nOcc3(:, selInd, :);
                case{'y'}
                    ytmp = -ytmp(selInd);
                    xtmp = -xtmp + dr;
                    Vtmp = nOcc3(selInd, :, :);
                case{'z'}
                    ztmp = -ztmp(selInd);
                    ytmp = -ytmp + dr;
                    Vtmp = nOcc3(:, :, selInd);
            end
    %         whos *tmp
            visualise3D(xtmp, ytmp, ztmp, Vtmp, ...
                sampleVal_range, sii, fnSw.alphaN);
        end
    end
    % camup([1 0 0 ]); campos([25 -55 5]) 
    % camlight; lighting phong
    colormap(fnSw.cMap);
    colorbar;
%     daspect([1 1 1]); 
    view([135, 45]);
    shading interp
    axis equal tight off vis3d 
%     axis square tight off %vis3d 
    set(gcf,'color','black');

    if fnSw.do_rotate3Dplot
%         camup([1 0 0 ]); campos([25 -55 5]) 
%         camlight; lighting phong        
        n_angle = 100;
        dangle = 360/n_angle;
        vidObj = VideoWriter(['dmc_',pept_si_col.expID,'_volume.avi']);
        open(vidObj);
        
        for i = 1:n_angle
            camorbit(dangle, 0); %drawnow;
            camzoom(gca, 1)
%             set(gca, 'Clipping', 'off')
%             setAxes3DPanAndZoomStyle(zoom(gca),gca,'camera');
            currFrame = getframe;
            writeVideo(vidObj, currFrame);
        end
        close(vidObj);
    end
end

%%
function fnSw = parseArgs(varargin)
    if ~isempty(varargin)
        fnSw = varargin{1};
    else
        fnSw = struct();
    end
    
    % default function switches
    if ~isfield(fnSw, 'do_smoothing')
        fnSw.do_smoothing = 'none';
    end
    if ~isfield(fnSw, 'do_densityDistrPlots')
        fnSw.do_densityDistrPlots = 0;
    end
    if ~isfield(fnSw, 'do_rotate3Dplot')
        fnSw.do_rotate3Dplot = 0;
    end
    if ~isfield(fnSw, 'cMap')
        fnSw.cMap = 'default';
    end
    if ~isfield(fnSw, 'alphaN')
        fnSw.alphaN = 0.5;
    end
    if ~isfield(fnSw, 'numIso')
        fnSw.numIso = 20;
    end
    if ~isfield(fnSw, 'nDistBins')
        fnSw.nDistBins = 20;
    end
    if ~isfield(fnSw, 'eSat')
        fnSw.eSat = 1e-3;
    end
    if ~isfield(fnSw, 'bins')
        fnSw.bins = [30, 30, 150];
    end
    if ~isfield(fnSw, 'splitDim')
        fnSw.splitDim = 'x';
    end
end

%% distribution plotting function
function [fr, bn] = plotDistr(v2bin, varargin)

    if ~isempty(varargin)
        N = varargin{1};
    else
        N = 10;
    end

    fn = @(x) log10(x);
    ifn = @(x) 10.^(x);
    
    [fr, bn] = hist(v2bin, N);
    frs = fn(fr);
    bar(bn, frs, 'stacked', 'BarWidth', 1);
    yticks = 0:fix(max(frs));
    set(gca, ...
        'YTick', yticks, ...
        'YTickLabel', {ifn(yticks)});
    grid on;
end

%% compute isosurfaces and plot resultant patches
function visualise3D(xtmp, ytmp, ztmp, Vtmp, sampleVal_range, sii, alphaN)
    sampleVal = sampleVal_range(sii);
    numIso = numel(sampleVal_range);
    coltmp = Vtmp;
    colormap('jet');
    whos *tmp sampleVal
    [faces,verts,colors] = isosurface(xtmp, ytmp, ztmp, ...
        Vtmp, sampleVal, coltmp);
    p = patch('Vertices',verts,'Faces',faces,'FaceVertexCData',colors, ...
        'FaceColor','interp','EdgeColor','interp');
    isonormals(xtmp,ytmp,ztmp,Vtmp, p);
%     alpha(p, sampleVal/max(sampleVal_range));
%     alphaScaleVal = sampleVal^(fnSw.numIso/10)/max(sampleVal_range.^(fnSw.numIso/10));
%     alphaScaleVal = sampleVal^sqrt(fnSw.numIso)/max(sampleVal_range.^sqrt(fnSw.numIso));
    alphaScaleVal = sampleVal^(alphaN*log(numIso)) / ...
        max(sampleVal_range.^(alphaN*log(numIso)));
    alpha(p, alphaScaleVal);
end