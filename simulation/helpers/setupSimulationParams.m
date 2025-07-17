function params = setupSimulationParams(phantom, config)
% SETUPSIMULATIONPARAMS Sets up simulation parameters based on phantom and config
%
% Inputs:
%   phantom - Phantom (struct)
%   config  - Simulation configuration parameters (struct)
%
% Output:
%   params - Structure with parameters related to current simulation setup
%
% (c) Kübra Keskin 2025

% Create params structure
params = struct();

% System parameters
params.B0 = config.system.B0; % actual B0 (T)
params.gamma = config.system.gamma; % kHz/mT

% Phantom parameters
params.Nph = size(phantom.pdmap); % matrix size of the phantom
params.phres = phantom.resolution; % resolution of the phantom (mm)
params.FOV = params.Nph.*params.phres; % phantom FOV (x,y,z) (mm)

% Imaging parameters
params.FOVx = params.FOV(1);  % mm
params.FOVy = params.FOV(2);  % mm
params.FOVz = params.FOV(3);  % mm
params.slthick = config.imaging.slthick;  % mm
params.imres = config.imaging.imres;  % mm
params.voxelsize = params.slthick * prod(params.imres); % mm
params.NEX = config.imaging.NEX;

% Matrix sizes
params.Nread = ceil(params.FOVx / params.imres(1)); % readout
params.Nype = ceil(params.FOVy / params.imres(2)); % y-phase encode
params.Nslc = floor(params.FOVz / params.slthick); % number of slices

% Basic sequence parameters
params.TR = config.imaging.TR;  % ms
params.TE = config.imaging.TE;  % ms
params.readBWpix = config.imaging.readBWpix;  % readout BW per pixel (Hz/px)
params.rfBW = config.imaging.rfBW;  % kHz - (also bin width for MAVRIC, MAVRIC-SL)
params.seqname = config.sequence.name;
params.Nbins = config.sequence.Nbins;

% Slices to be simulated
if config.imaging.slices(1) == 0
    params.slices = [1:params.Nslc];
else
    params.slices = config.imaging.slices;
    % modify the range if provided slice numbers out of range
    params.slices = params.slices(params.slices <= params.Nslc);
end

% Derived parameters
params.readBW = params.readBWpix * params.Nread * 1e-3/2; % actual readout BW (+/- kHz)
params.Tsamp = 1/(2*params.readBW); % sampling interval (ms)
params.Gx = 10/(params.FOVx*params.Tsamp); % readout gradient (kHz/cm)

% Parameters changing based on sequence type
switch params.seqname
    case 'SEMAC'
        params.Nzpe = params.Nbins; % number of z-phase encodes
        params.Gz = params.rfBW/(params.slthick/10); % Slice select gradient (kHz/cm)
        params.FOVzpe = params.Nzpe*params.slthick; % z phase encode FOV (mm)
        params.dzpe = 10/params.FOVzpe; % seperation between z phase encodes (cycles/cm)
        params.rfTBW = config.sequence.SEMAC.rfTBW; % Sinc RF pulse Time-Bandwidth product
        
    case 'TSE'
        params.Gz = params.rfBW/(params.slthick/10); % Slice select gradient (kHz/cm)
        params.rfTBW = config.sequence.TSE.rfTBW; % Sinc RF pulse Time-Bandwidth product
        
    case 'VAT'
        params.Gz = params.rfBW/(params.slthick/10); % Slice select gradient (kHz/cm)
        params.rfTBW = config.sequence.VAT.rfTBW; % Sinc RF pulse Time-Bandwidth product
        
    case 'MAVRIC'
        params.Nzpe = params.Nslc; % total number of reconstructed z-locations
        params.Gz = 0; % No slice select gradient (kHz/cm)
        params.bindfreq = config.sequence.MAVRIC.bindfreq; % bin seperation frequency (kHz)
        
    case 'MAVRIC-SL'
        params.Nzpe = params.Nslc; % total number of reconstructed z-locations
        params.bindfreq = config.sequence.MAVRIC_SL.bindfreq; % bin seperation frequency (kHz)
        params.Gz = (params.Nbins*params.bindfreq)/(params.Nzpe*params.slthick/10); % Slice select gradient (kHz/cm)
end

% VAT gradient (used by multiple sequences)
params.Gvat = params.Gz;

% Copy noise parameters if available
if isfield(config, 'noise')
    noise_fields = fieldnames(config.noise);
    for i = 1:length(noise_fields)
        params.(noise_fields{i}) = config.noise.(noise_fields{i});
    end
end

end
