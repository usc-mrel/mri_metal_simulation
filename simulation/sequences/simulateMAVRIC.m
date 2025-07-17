function [im, params, ks, noise_params] = simulateMAVRIC(t1map, t2map, pdmap, dfmap, params)
% SIMULATEMAVRIC Simulates MAVRIC MRI sequence for metal implants
%
% Inputs:
%   t1map  - T1 relaxation time map (ms), size [X,Y,Z]
%   t2map  - T2 relaxation time map (ms), size [X,Y,Z]
%   pdmap  - Proton density map, size [X,Y,Z]
%   dfmap  - Off-resonance map (kHz), size [X,Y,Z]
%   params - Simulation parameters (struct)
%
% Outputs:
%   im           - Simulated image data (size: Nread × Nype × Nslc × Nbins)
%   params       - Updated parameters structure
%   ks           - k-space data without noise added
%   noise_params - Noise parameters (struct)
%
% (c) Kübra Keskin 2025

% Start timer for overall simulation
tstart = tic;

% Initialize image matrix with zeros
im = zeros(params.Nread, params.Nype, params.Nslc, params.Nbins, 'single');

% Initialize k-space without noise
ks = zeros(params.Nread, params.Nype, params.Nslc, params.Nbins, 'single');

% Create a grid for the simulation (in mm)
x_vec = single(([1:params.Nph(1)] - params.Nph(1)/2 - 0.5) * params.phres(1));
y_vec = single(([1:params.Nph(2)] - params.Nph(2)/2 - 0.5) * params.phres(2));
z_vec = single(([1:params.Nph(3)] - params.Nph(3)/2 - 0.5) * params.phres(3));
[y, x, z] = meshgrid(y_vec, x_vec, z_vec);

% Size of zero-pad k-space
Nypad = params.FOVy / params.phres(2);
Nzpad = params.FOVz / params.phres(3);

% frequency map for readout gradient
df_Gx = single(params.Gx * x * 0.1); % kHz
% frequency map total
df_all = single(dfmap + df_Gx); % kHz

% Base spin echo signal
sig_base = single(pdmap .* (1 - exp(-params.TR ./ t1map)) .* exp(-params.TE ./ t2map));

% Loop over bins
for bin = 1:params.Nbins
    
    % Start timer for each bin
    tic;
    fprintf('Simulating MAVRIC bins: %d of %d\n', bin, params.Nbins);
    
    % Calculate central frequency of the bin
    cfreq = (bin - (params.Nbins + 1) / 2) * params.bindfreq;  % kHz
    
    % RF excitation and excited spin location indices
    sig_prof = single(gaussianPulse(dfmap - cfreq, params));
    
    % Calculate excited signal
    sig_exc = sig_base .* sig_prof;
    
    % Phase change due to df and Gx and bin central freq
    df_bin = df_all - cfreq;  % kHz
    expdphase = exp(-1i * 2 * pi * df_bin * params.Tsamp);  % Phase change per readout sample
    
    % Initialize k-space for readout
    ks_read = zeros(params.Nread, params.Nph(2), params.Nph(3), 'single');
    
    % Start acquisition from the first point in readout
    sig = sig_exc.* expdphase.^(-0.5 * params.Nread + 0.5);
    
    % Readout acquisition
    for kx = 1:params.Nread
        sig = sig .* expdphase;
        ks_read(kx, :, :) = sum(sig, 1);
    end
    
    % ifft across readout
    im_temp = ifftc(ks_read, 1);
    
    % zeropad image to FOVy and FOVz
    im_temp2 = zpad(im_temp, [params.Nread, Nypad, Nzpad]);
    
    % crop to image dimensions
    ks_pe = fftc(fftc(im_temp2, 2), 3);
    ks_pe = crop(ks_pe, [params.Nread, params.Nype, params.Nslc]);
    
    % return to k-space
    ksp = fftc(ks_pe,1);
    
    % k-space without noise
    ks(:,:,:,bin) = ksp;
    
    % Add noise to k-space if enabled
    [ksp, noise_params] = addKspaceNoise(ksp, params);
    
    % image
    im(:,:,:,bin) = ifftc(ifftc(ifftc(ksp, 1), 2), 3);
    
    % Display time for this bin
    toc;
    fprintf('\n');
end

% Total simulation time
total_time = toc(tstart);
fprintf('Total MAVRIC simulation time: %.2f seconds\n', total_time);

% Store timing information in parameters
params.simulation_time = total_time;
end