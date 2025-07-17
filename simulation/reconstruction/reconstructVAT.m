function [final_images, params] = reconstructVAT(im, params)
% RECONSTRUCTVAT Reconstructs VAT from simulated image data
%
% Inputs:
%   im     - Simulated image data (size: Nread × Nype × Nslc)
%   params - Simulation parameters (struct)
%
% Outputs:
%   final_images - Final sets of images (struct)
%                      .final: magnitude VAT image
%   params       - Updated parameters structure
%
% (c) Kübra Keskin 2025

im_final = abs(im);

% Package results
final_images = struct(...
    'final', im_final);
end