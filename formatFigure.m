function formatFigure(fHandle , varargin)
% reformats figure fHandle to custom settings

    if ~isempty(varargin)
        fnSw = parseArgs(varargin{1});
    else
        fnSw = parseArgs;
    end

    figPos = [[1-fnSw.figDim(1), 1-fnSw.figDim(2)]/2, fnSw.figDim];
    set(fHandle, 'units', 'normalized', 'outerposition', figPos);

    %% find all the axes in the figure
    hax = findall(fHandle, 'type', 'axes');

    for hii = 1:numel(hax)
        grid(hax(hii), 'on');
        box(hax(hii), 'on');
        set(hax(hii), ...
            'FontName', fnSw.fontName, ...
            'FontSize', fnSw.fontSizeAxes, ...
            'FontWeight', fnSw.fontWeight);
        if fnSw.do_tight
            axis(hax(hii),'tight');
        end
    end

    %%
    fax = findall(fHandle, 'type', 'text');

    for hii = 1:numel(fax)
        set(fax(hii), ...
            'FontName', fnSw.fontName, ...
            'FontSize', fnSw.fontSizeText, ...
            'Interpreter', fnSw.interpreter);
    end
end

function fnSw = parseArgs(varargin)
    if ~isempty(varargin)
        fnSw = varargin{1};
    else
        fnSw = struct();
    end
    
    % default function switches
    if ~isfield(fnSw, 'figDim')
        fnSw.figDim = [0.75, 0.5];
    end
    if ~isfield(fnSw, 'fontSizeText')
        fnSw.fontSizeText = 20;
    end
    if ~isfield(fnSw, 'fontSizeAxes')
        fnSw.fontSizeAxes = 12;
    end
    if ~isfield(fnSw, 'fontWeight')
        fnSw.fontWeight = 'bold';
    end
    if ~isfield(fnSw, 'fontName')
        fnSw.fontName = 'Times New Roman';
    end
    if ~isfield(fnSw, 'interpreter')
        fnSw.interpreter = 'latex';
    end
    if ~isfield(fnSw, 'do_tight')
        fnSw.do_tight = 1;
    end
end

