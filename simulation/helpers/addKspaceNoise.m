function [noisy_kspace, noise_params] = addKspaceNoise(kspace, params)
% ADDKSPACENOISE Adds realistic complex Gaussian noise to k-space data
%
% Inputs:
%   kspace - K-space data
%   params - Simulation parameters with noise settings
%
% Outputs:
%   noisy_kspace - K-space data with added noise
%   noise_params - Noise parameters
%
% Required params fields:
%   params.add_noise    - Flag for whether noise should be added, if this
%       variable not found in params or false, function will return
%       noiseless k-space and empty noise_params
%
%   params.refB0        - Reference field strength (T)
%   params.refreadBWpix - Reference readout bandwidth (Hz/pixel)
%   params.refvoxelsize - Reference imaging voxel size (size vector or scalar (mm^3))
%   params.refNEX       - Reference number of averages
%   params.refphres     - Reference phantom resolution [x,y,z] (mm)
%
%   params.refstd       - Noise standard deviation at reference scan
%
%   params.B0           - Current field strength (T)
%   params.readBWpix    - Current readout bandwidth (Hz/pixel)
%   params.voxelsize    - Current imaging voxel size (size vector or scalar (mm^3))
%   params.NEX          - Current number of averages
%   params.phres        - Current phantom resolution [x,y,z] (mm)
%
% (c) Kübra Keskin 2025

% Check if noise should be added
if ~isfield(params, 'add_noise') || ~params.add_noise
    noisy_kspace = kspace;
    noise_params = struct;
    return;
end

% Check for required parameters
required_fields = {'refB0', 'refreadBWpix', 'refvoxelsize', 'refNEX', 'refphres', ...
    'refstd', 'B0', 'readBWpix', 'voxelsize', 'NEX', 'phres'};
for i = 1:length(required_fields)
    if ~isfield(params, required_fields{i})
        error('Missing required parameter: %s', required_fields{i});
    end
end

% Calculate B0 ratio (used for both signal and noise scaling)
B0_ratio = params.B0 / params.refB0;

% Noise scaling based on field strength
B0_scaling = B0_ratio;

% Noise scaling based on bandwidth
BW_scaling = sqrt(params.readBWpix / params.refreadBWpix);

% Noise scaling based on voxel volume
refvol = prod(params.refvoxelsize);
curvol = prod(params.voxelsize);
vol_scaling = (refvol / curvol);

% Correction to signal scaling due to FFT normalization after cropping operation
phantom_scaling_FFT = sqrt(params.phres(2) / params.refphres(2));
% Correction to signal scaling due to different phantom voxel sizes
phantom_scaling_voxel = (params.phres(1)*params.phres(3)) / (params.refphres(1)*params.refphres(3));

% Number of averages scaling
NEX_scaling = sqrt(params.refNEX / params.NEX);

% Signal scaling based on field strength and correction
signal_scaling = B0_ratio^2 * phantom_scaling_FFT * phantom_scaling_voxel;

% Calculate total noise scaling
noise_scaling = params.refstd * B0_scaling * BW_scaling * vol_scaling * NEX_scaling;

% Generate independent complex Gaussian noise
noise_std = noise_scaling;
noise_real = noise_std * randn(size(kspace));
noise_imag = noise_std * randn(size(kspace));
noise = noise_real + 1i * noise_imag;

% Scale the signal and add noise to k-space data
noisy_kspace = signal_scaling * kspace + noise;

% Store noise parameters
noise_params.std = noise_std;
noise_params.signal_scaling = signal_scaling;
noise_params.B0_scaling = B0_scaling;
noise_params.BW_scaling = BW_scaling;
noise_params.vol_scaling = vol_scaling;
noise_params.NEX_scaling = NEX_scaling;
end