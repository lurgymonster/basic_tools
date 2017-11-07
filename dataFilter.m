function [xout] = dataFilter(xin, tin, varargin)

    if ~isempty(varargin)
        fnSw = parseArgs(varargin{1});
    else
        fnSw = parseArgs();
    end

    availableMethods = {...
        'moving', 'lowess', 'loess', 'rloess', ...
        'sgolay', 'gauss', 'fft_rect'};

    switch fnSw.smoothingType
        case{'moving'}
            if fnSw.do_print2screen
                fprintf('Smoothing using Moving Average.\n');
            end
            span = fnSw.smoothingFilterArgs(1);
            xout = smooth(xin, span, fnSw.smoothingType);

        case{'lowess', 'loess', 'rloess'} % non-constant time correction!
            if fnSw.do_print2screen
                fprintf('Smoothing using Savitzky-Golay polynomials.\n');
            end
            span = fnSw.smoothingFilterArgs(1);
            xout = smooth(tin, xin, span, fnSw.smoothingType);

        case{'sgolay'} % non-constant time correction!
            if fnSw.do_print2screen
                fprintf('Smoothing using Savitzky-Golay polynomials.\n');
            end
            span = fnSw.smoothingFilterArgs(1);
            degree = fnSw.smoothingFilterArgs(2);
            xout = smooth(xin, span, fnSw.smoothingType, degree);

        case{'gauss'}
            if fnSw.do_print2screen
                fprintf('Smoothing using Gaussian filter.\n');
            end
            span = fnSw.smoothingFilterArgs(1);
            gaussFilter = gausswin(span);
            gaussFilter = gaussFilter / sum(gaussFilter); 
            xout = conv(xin, gaussFilter, 'same');

        case{'fft_rect'}
            if fnSw.do_print2screen
                fprintf('Smoothing using FFT low pass rectangular filter.\n');
            end
            r = fnSw.smoothingFilterArgs(1);
            if numel(fnSw.smoothingFilterArgs)>1
                N = fnSw.smoothingFilterArgs(2);
            else
                N = max([length(tin), r]);
            end
            %
            X = fft(xin,N);
    %         rectangular filter
            rectangle = zeros(size(X));
    %         whos X rectangle
            if r > length(X)-1
                r = length(X)-1;
            end
            rectangle(1:r+1) = 1;               % preserve low +ve frequencies
            rectangle(end-r+1:end) = 1;         % preserve low -ve frequencies
    %         whos X rectangle
            xout = ifft(X.*rectangle,N);      % full low-pass filtered signal
        otherwise
            fprintf('Unknown filter method %s.\n', fnSw.smoothingType);
            fprintf('Available methods: ');
            for ii = 1:numel(availableMethods)
                fprint('%s, ', availableMethods{ii});
            end
            fprintf('.\n');
    end
end

function fnSw = parseArgs(varargin)

    if ~isempty(varargin)
        fnSw = varargin{1};
    else
        fnSw = struct();
    end

    %% program switches
    if ~isfield(fnSw, 'do_slidingWindow')
        fnSw.do_slidingWindow = 1;
    end
    if ~isfield(fnSw, 'smoothingType')
        fnSw.smoothingType = 'sgolay';
        fnSw.smoothingFilterArgs = [5, 2];
    else
        if ~isfield(fnSw, 'smoothingFilterArgs')
            switch fnSw.smoothingType
                case{'fft_rect'}
                    fnSw.smoothingFilterArgs = [30, 1024];
                otherwise
                    fnSw.smoothingFilterArgs = [5, 2];
            end
        end
    end
    if ~isfield(fnSw, 'do_print2screen')
        fnSw.do_print2screen = 0;
    end
end
    