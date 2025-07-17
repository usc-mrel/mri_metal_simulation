function [final_images, params] = reconstructSEMAC(im, params)
% RECONSTRUCTSEMAC Reconstructs SEMAC combined images from simulated image data
%
% Inputs:
%   im     - Simulated image data (size: Nread × Nype × Nbins × Nslc)
%   params - Simulation parameters (struct)
%
% Outputs:
%   final_images - Final sets of images (struct)
%                      .final: SEMAC combined image
%                      .bins: Spectral bin images before combination
%   params       - Updated parameters structure
%
% (c) Kübra Keskin 2025

% Initialize shifted image array
im_shift = zeros(size(im));

% Apply z-direction shifts
shift_amount = ceil(params.Nslc/2)-1;
for ss = 1:params.Nslc
    im_shift(:,:,:,ss) = circshift(im(:,:,:,ss), shift_amount, 3);
    shift_amount = shift_amount - 1;
end

% Prepare padded image array
im_pad = zeros(params.Nread, params.Nype, params.Nzpe, params.Nslc+params.Nbins-1);
im_pad(:,:,:,params.Nbins/2:params.Nslc+params.Nbins/2-1) = im_shift;

% Initialize spectral bin images matrix with zeros
im_bins = zeros(params.Nread, params.Nype, params.Nslc, params.Nbins);

% Combine spectral bins
im_comb_final = zeros(size(im,1,2,4));
for ss = 1:params.Nslc
    im_temp = 0;
    for bb = 1:params.Nbins
        im_bins(:,:,ss,bb) = im_pad(:,:,bb,ss+params.Nbins-bb);
        im_temp = im_temp + abs(im_bins(:,:,ss,bb)).^2;
    end
    im_comb_final(:,:,ss) = sqrt(im_temp);
end

% Package results
final_images = struct(...
    'final', im_comb_final, ...
    'bins', im_bins);
end