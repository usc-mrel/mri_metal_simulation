function srf = scalePulse(rf, t, fa)
% SCALEPULSE Scale RF pulse to achieve desired flip angle
%
% Inputs:
%   rf - RF pulse waveform
%   t  - Duration of the pulse (ms)
%   fa - Desired flip angle (radians)
%
% Outputs:
%   srf - Scaled RF pulse (Gauss)
%
% (c) Kübra Keskin 2025

% Gyromagnetic ratio (kHz/G)
gamma = 4.258;

% Calculate time step (ms)
dt = t / length(rf);

% Scale the RF pulse to get the desired flip angle
srf = rf * fa / (2 * pi * gamma * dt);

end