function [prof, inds] = gaussianPulse(df, params)
% GAUSSIANPULSE Calculates Gaussian RF pulse excitation profile
%
% Inputs:
%   df     - Frequency offset (kHz)
%   params - Structure with params
%
% Outputs:
%   prof - Excitation profile
%   inds - Indices of excited spins
%
% (c) Kübra Keskin 2025

% Get FWHM from params
FWHM = params.rfBW;

% Convert FWHM to sigma (standard deviation)
sigma = FWHM / (2 * sqrt(2 * log(2)));

% Calculate Gaussian profile
prof = exp(-(df.^2) / (2 * sigma^2));

% Find indices where profile is significant
threshold = 0.01; % 1% of maximum
inds = prof > threshold;
end