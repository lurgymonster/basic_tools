function pept_si = evaluateFit(pept_fit, pept_seg, varargin)
%% function pept_si = evaluateFit(pept_fit, pept_seg, )
% arguments PEPT_FIT structure (generated by f_dmc_smoothInterpolateData02.m)
% and PEPT_SEG structure (generated by f_dmc_bii_genOpt_batch.m)
% and an interpolation factor INTFACT and returns the interpolated tracks 
% in structure PEPT_SI

    if ~isempty(varargin)
        interpolationFactor = varargin{1};
    else
        interpolationFactor = pept_fit.intFact;
    end
    
    numSegments = numel(pept_fit);

    t = cell(1, numSegments);
    x = cell(1, numSegments);
    y = cell(1, numSegments);
    z = cell(1, numSegments);
    r = cell(1, numSegments);
    theta = cell(1, numSegments);

    vx = cell(1, numSegments);
    vy = cell(1, numSegments);
    vz = cell(1, numSegments);
    v = cell(1, numSegments);
    vr = cell(1, numSegments);
    vt = cell(1, numSegments);
    v_rms = cell(1, numSegments);
    v_rms2 = cell(1, numSegments);
    v_rms3 = cell(1, numSegments);
    v_rms_fft1 = cell(1, numSegments);
    v_rms_fft2 = cell(1, numSegments);
    v_rms_fft3 = cell(1, numSegments);

    ax = cell(1, numSegments);
    ay = cell(1, numSegments);
    az = cell(1, numSegments);
    a = cell(1, numSegments);
    ar = cell(1, numSegments);
    at = cell(1, numSegments);

    for saii = 1:numSegments
        structTmp = pept_fit(saii);

        t0 = pept_seg.tSegStart(saii);
        t1 = pept_seg.tSegEnd(saii);
        numPoints = numel(pept_seg.t{saii});

        tseg = linspace(t0, t1, numPoints*interpolationFactor); 
        t{saii} = tseg';

        % cartesian coordinate position
        x{saii} = structTmp.x(t{saii});
        y{saii} = structTmp.y(t{saii});
        z{saii} = structTmp.z(t{saii});

    %     % polar coordinates
    %     r{saii} = sqrt(x{saii}.^2+y{saii}.^2);
    %     theta{saii} = mod(atan2(y{saii},x{saii}), 2*pi);

        %% velocities
        vx{saii} = structTmp.vx(t{saii});
        vy{saii} = structTmp.vy(t{saii});
        vz{saii} = structTmp.vz(t{saii});
        v{saii} = sqrt(vx{saii}.^2 + vy{saii}.^2 + vz{saii}.^2);

        % rms velocity
        vx_rms = rms_custom(vx{saii});
        vy_rms = rms_custom(vy{saii});
        vz_rms = rms_custom(vz{saii});
        v_rms{saii} = rms_custom(v{saii});
        v_rms2{saii} = sqrt(vx_rms.^2 + vy_rms.^2 + vz_rms.^2);
        v_rms3{saii} = errorPropagation3(...
            [vx_rms, vx{saii}], ...
            [vy_rms, vy{saii}], ...
            [vz_rms, vz{saii}]);
        v_rms_fft1{saii} = rms_fft(t{saii}, v{saii}, [30, numel(t{saii})]);
        v_rms_fft2{saii} = rms_fft(t{saii}, v{saii}, [50, numel(t{saii})]);
        v_rms_fft3{saii} = rms_fft(t{saii}, v{saii}, [100, numel(t{saii})]);

        %% accelerations
        ax{saii} = structTmp.ax(t{saii});
        ay{saii} = structTmp.ay(t{saii});
        az{saii} = structTmp.az(t{saii});
        a{saii} = sqrt(ax{saii}.^2 + ay{saii}.^2 + az{saii}.^2);

        [r{saii}, theta{saii}, vr{saii}, vt{saii}, ar{saii}, at{saii}] = ...
            polarCoord_conversion(...
            x{saii}, y{saii}, vx{saii}, vy{saii}, ax{saii}, ay{saii});

    end

    % pept_si = struct();

    pept_si = struct(...
        't', {t}, 'x', {x}, 'y', {y}, 'z', {z}, ...
        'r', {r}, 'theta', {theta}, ...
        'Vmag', {v}, ...
        'Vx', {vx}, 'Vy', {vy}, 'Vz', {vz}, ...
        'Vrad', {vr}, 'Vtan', {vt}, 'Vax', {vz},...
        'vrms', {v_rms}, 'vrms2', {v_rms2}, 'vrms3', {v_rms3},...
        'vrms_fft1', {v_rms_fft1}, 'vrms_fft2', {v_rms_fft2}, ...
        'vrms_fft3', {v_rms_fft3}, ...
        'Ax', {ax}, 'Ay', {ay}, 'Az', {ax}, ...
        'Amag', {a}, ...
        'Arad', {ar}, 'Atan', {at}, 'Aax', {az}, ...
        'n', numSegments, 'intFact', interpolationFactor, ...
        'expID', pept_seg.expID, 'fopt', pept_seg.fopt, ...
        'numLines', pept_seg.numLines ...
        );
end

function var_rms = rms_custom(var)
    vp = var-mean(var);
    var_rms = sqrt(vp.^2);
end

function var_rms = rms_fft(t, var, varargin)
    if isempty(varargin)
        derivFA = [100, length(t)];
    else
        derivFA = varargin{1};
    end
    fnSw_fft = struct('do_smoothType', 'fft_rect', ...
        'filterArgs', derivFA);
    var_fft = dataFilter(var, t, fnSw_fft);
    vp = var-var_fft;
    var_rms = sqrt(vp.^2);
end

function [r, dr] = errorPropagation3(X, Y, Z)
    r = sqrt(X(:,1).^2 +Y(:,1).^2+Z(:,1).^2);
     wx = X(:,1)./r;
     wy = Y(:,1)./r;
     wz = Z(:,1)./r;
     dr = sqrt(wx.^2.*X(:,2).^2 + ...
        wy.^2.*Y(:,2).^2 + ...
        wz.^2.*Z(:,2).^2);
end