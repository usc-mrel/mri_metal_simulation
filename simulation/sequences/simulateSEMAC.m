function [im, params, ks, noise_params] = simulateSEMAC(t1map, t2map, pdmap, dfmap, params)
% SIMULATESEMAC Simulates SEMAC MRI sequence for metal implants
%
% Inputs:
%   t1map  - T1 relaxation time map (ms), size [X,Y,Z]
%   t2map  - T2 relaxation time map (ms), size [X,Y,Z]
%   pdmap  - Proton density map, size [X,Y,Z]
%   dfmap  - Off-resonance map (kHz), size [X,Y,Z]
%   params - Simulation parameters (struct)
%
% Outputs:
%   im           - Simulated image data (size: Nread × Nype × Nbins × Nslc)
%   params       - Updated parameters structure
%   ks           - k-space data without noise added
%   noise_params - Noise parameters (struct)
%
% (c) Kübra Keskin 2025

% Start timer for overall simulation
tstart = tic;

% Initialize image matrix with zeros
im = zeros(params.Nread, params.Nype, params.Nzpe, params.Nslc, 'single');

% Initialize k-space without noise
ks = zeros(params.Nread, params.Nype, params.Nzpe, params.Nslc, 'single');

% Create a grid for the simulation (in mm)
x_vec = single(([1:params.Nph(1)] - params.Nph(1)/2 - 0.5) * params.phres(1));
y_vec = single(([1:params.Nph(2)] - params.Nph(2)/2 - 0.5) * params.phres(2));
z_vec = single(([1:params.Nph(3)] - params.Nph(3)/2 - 0.5) * params.phres(3));
[y, x, z] = meshgrid(y_vec, x_vec, z_vec);

% Size of zero-pad k-space
Nzpad = params.FOVzpe / params.slthick;
Nypad = params.FOVy / params.phres(2);

% frequency map with excitation gradient
df_exc = single(dfmap + params.Gz * z * 0.1); % kHz
% frequency map for readout gradient
df_Gx = single(params.Gx * x * 0.1); % kHz
% frequency map total
df_all = df_exc + df_Gx;

% Base spin echo signal
sig_base = single(pdmap .* (1 - exp(-params.TR ./ t1map)) .* exp(-params.TE ./ t2map));

% Loop over slices
for slc = params.slices
    
    % Start timer for each slice
    tic;
    fprintf('Simulating SEMAC slices: %d of %d\n', slc, params.Nslc);
    
    % Calculate central frequency of the slice
    cfreq = (slc - (params.Nslc + 1) / 2) * params.rfBW;  % kHz
    
    % RF excitation and excited spin location indices
    sig_prof = single(sincPulse(df_exc - cfreq, params));
    
    % Calculate excited signal
    sig_exc = sig_base .* sig_prof;
    
    % Phase change due to df, Gx, and Gvat 
    % demodulated by the slice central freq due to VAT
    df_bin = df_all - cfreq;  % kHz
    expdphase = exp(-1i * 2 * pi * df_bin * params.Tsamp);  % Phase change per readout sample
    
    % Initialize k-space for readout
    ks_read = zeros(params.Nread, params.Nph(2), params.Nzpe, 'single');
    
    % Loop over z phase encodes
    for zpe = 1:params.Nzpe
        
        % Calculate phase at readout center due to z phase encode
        zphase = (zpe - (params.Nzpe) / 2) * params.dzpe * z * 0.1;  % cycles
        expzphase = exp(-1i * 2 * pi * zphase);
        
        % Start acquisition from the first point in readout
        sig = sig_exc .* expzphase .* expdphase.^(-0.5 * params.Nread + 0.5);
        
        % Readout acquisition
        for kx = 1:params.Nread
            sig = sig .* expdphase;
            ks_read(kx, :, zpe) = sum(sig, [1, 3]);
        end
        
    end
    
    % ifft across readout and z phase encode
    im_temp = ifftc(ifftc(ks_read, 1), 3);
    
    % zeropad image to FOVy and FOVz
    im_temp2 = zpad(im_temp, [params.Nread, Nypad, Nzpad]);
    
    % crop to image dimensions
    ks_pe = fftc(fftc(im_temp2, 2), 3);
    ks_pe = crop(ks_pe, [params.Nread, params.Nype, params.Nzpe]);
    
    % return to k-space
    ksp = fftc(ks_pe,1);
    
    % k-space without noise
    ks(:,:,:,slc) = ksp;
    
    % Add noise to k-space if enabled
    [ksp, noise_params] = addKspaceNoise(ksp, params);
    
    % image
    im(:,:,:,slc) = ifftc(ifftc(ifftc(ksp, 1), 2), 3);
    
    % Display time for this slice
    toc;
    fprintf('\n');
end

% Total simulation time
total_time = toc(tstart);
fprintf('Total SEMAC simulation time: %.2f seconds\n', total_time);

% Store timing information in parameters
params.simulation_time = total_time;
end