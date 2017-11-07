function inspectTracks(pept_seg, varargin)

    nImg = pept_seg.n;

    if ~isempty(varargin)
        nImg = varargin{1};
    end

    nRows = ceil(sqrt(nImg));
    nCols = ceil(sqrt(nImg));

    if nImg > 100
        mrkSz = 1;
    else
        mrkSz = 5;
    end

    scrH = .9; scrW = .75;
    figPos = [[1-scrW, 1-scrH]/2, [scrW, scrH]];
    fHandle = figure('units', 'normalized', 'outerposition', figPos);

    for fii = 1:nImg
        subplot(nRows, nCols, fii); 
        hold on; 
        box on;
        axis off;

        xtmp = pept_seg.x{fii};
        ytmp = pept_seg.y{fii};
        ztmp = pept_seg.z{fii};
        plot3(xtmp, ytmp, ztmp, '.', ...
            'MarkerSize', mrkSz);
        text(.1, .1, 0, num2str(fii), 'Color', 'w');
        view([-30, 25]);
        
    end
end