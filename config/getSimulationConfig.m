function config = getSimulationConfig()
% GETSIMULATIONCONFIG Returns a configuration structure for MRI simulation
%
% Output:
%   config - Structure with configuration parameters for MRI simulation

% General configuration
config = struct();

% System parameters
config.system = struct();
config.system.B0 = 0.55;                      % Field strength (T)
config.system.gamma = 42.58;                  % Gyromagnetic ratio (kHz/mT)

% Imaging parameters
config.imaging = struct();
config.imaging.readBWpix = 400;               % Readout bandwidth per pixel (Hz/px)
config.imaging.slthick = 3.0;                 % Slice thickness (mm)
config.imaging.imres = [1.0, 1.0];            % Image resolution [x, y] (mm)
config.imaging.TR = 2000;                     % Repetition time (ms)
config.imaging.TE = 34;                       % Echo time (ms)
config.imaging.rfBW = 1.0;                    % RF bandwidth (kHz)
config.imaging.NEX = 1;                       % Number of averages

% Slices to be simulated
% Note: Change it only for TSE & VAT (for quick visualization, otherwise full simulation recommended)
%       Use [0] for SEMAC as it needs all slices to have a valid combination
config.imaging.slices = [0];                  % [0]: all slices, for specific slices: i.e. [8,9,10]   

% Noise parameters
config.noise = struct();
config.noise.add_noise = true;                % Whether to add noise to k-space data
config.noise.refB0 = 0.55;                    % Reference B0 (Tesla)
config.noise.refreadBWpix = 401;              % Reference readout bandwidth (Hz/pixel)
config.noise.refstd = 14.8;                   % Reference noise standard deviation
config.noise.refTR = 2000;                    % Reference TR (ms)
config.noise.refTE = 34;                      % Reference TE (ms)
config.noise.refvoxelsize = [1.0, 1.0, 4.0];  % Reference voxel size [x, y, z] (mm)
config.noise.refNEX = 2;                      % Reference number of averages
config.noise.refphres = [0.5, 0.5, 0.5];      % Reference phantom resolution [x, y, z] (mm)

% Sequence specific parameters
config.sequence = struct();

% Sequence name
config.sequence.name = 'SEMAC';               % Sequence name
config.sequence.Nbins = 12;                   % Number of spectral bins

% SEMAC parameters
config.sequence.SEMAC = struct();
config.sequence.SEMAC.rfTBW = 2.56;           % Sinc RF pulse Time-Bandwidth product

% MAVRIC parameters
config.sequence.MAVRIC = struct();
config.sequence.MAVRIC.bindfreq = 1.0;        % Bin separation frequency (kHz)

% MAVRIC-SL parameters
config.sequence.MAVRIC_SL = struct();
config.sequence.MAVRIC_SL.bindfreq = 1.0;     % Bin separation frequency (kHz)
config.sequence.MAVRIC_SL.rfTBW = 2.56;       % RF Time-Bandwidth product

% TSE parameters
config.sequence.TSE = struct();
config.sequence.TSE.rfTBW = 2.56;             % RF Time-Bandwidth product

% VAT parameters
config.sequence.VAT = struct();
config.sequence.VAT.rfTBW = 2.56;             % RF Time-Bandwidth product
end