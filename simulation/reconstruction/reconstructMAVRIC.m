function [final_images, params] = reconstructMAVRIC(im, params)
% RECONSTRUCTMAVRIC Reconstructs MAVRIC combined images from simulated image data
%
% Inputs:
%   im     - Simulated image data (size: Nread × Nype × Nslc × Nbins)
%   params - Simulation parameters (struct)
%
% Outputs:
%   final_images - Final sets of images (struct)
%                      .final: MAVRIC combined image
%                      .bins: Spectral bin images before combination
%   params       - Updated parameters structure
%
% (c) Kübra Keskin 2025

% Combine spectral bins using root sum of squares
im_comb = sqrt(sum(abs(im).^2,4));

% Package results
final_images = struct(...
    'final', im_comb, ...
    'bins', im);
end