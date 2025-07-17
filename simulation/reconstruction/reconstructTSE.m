function [final_images, params] = reconstructTSE(im, params)
% RECONSTRUCTTSE Reconstructs TSE from simulated image data
%
% Inputs:
%   im     - Simulated image data (size: Nread × Nype × Nslc)
%   params - Simulation parameters (struct)
%
% Outputs:
%   final_images - Final sets of images (struct)
%                      .final: magnitude TSE image
%   params       - Updated parameters structure
%
% (c) Kübra Keskin 2025

im_final = abs(im);

% Package results
final_images = struct(...
    'final', im_final);
end