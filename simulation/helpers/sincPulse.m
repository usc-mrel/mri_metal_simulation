function [prof, inds] = sincPulse(df, params)
% SINCPULSE Calculates sinc RF pulse excitation profile
%
% Inputs:
%   df     - Frequency offset (kHz)
%   params - Structure with fields 'rfTBW' and 'rfBW'
%
% Outputs:
%   prof - Excitation profile
%   inds - Indices of excited spins
%
% (c) Kübra Keskin 2025

% Get parameters from params structure
TBW = params.rfTBW;
rfBW = params.rfBW;

% parameters
Ns = 100;     % Number of samples
Npad = 100;   % Padding amount
Tdur = TBW/rfBW; % Duration of the pulse (ms)

% Generate windowed sinc RF pulse waveform
rf = windowedSinc(Ns, TBW);

% Scale pulse to flip angle
rf = scalePulse(rf, TBW/rfBW, pi/2);

% Zero pad
rf_pad = zeros(1, Ns*Npad);
rf_pad(Ns*Npad/2-Ns/2+1:Ns*Npad/2+Ns/2) = rf;

% Calculate pulse profile in frequency domain
RF = fftc(rf_pad, 2);

% Eliminate mostly zero parts
RF = RF(Ns*Npad/2-10*Npad/2+1:Ns*Npad/2+10*Npad/2);

% Normalize amplitude to 1
RF = RF/max(abs(RF));

% Calculate frequency resolution and interval
dfreq = 1/(Npad*Tdur); % Frequency resolution
fintv = (-10*Npad/2:10*Npad/2-1)*dfreq; % Frequency interval range (kHz)

% Initialize profile with zeros
prof = zeros(size(df));

% Find indices inside the frequency interval
inds = (df >= min(fintv)) & (df <= max(fintv));

% Assign corresponding amplitude to each frequency
prof(inds) = RF(round((df(inds)-min(fintv))/dfreq+1));
end