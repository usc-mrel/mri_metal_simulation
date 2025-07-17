function [final_images, params] = runReconstruction(images, params)
% Inputs:
%   images - Simulated noisy image data (size changes based on the sequence, see individual simulate functions)
%   params - Simulation parameters (struct)
%
% Outputs:
%   final_images - Final sets of images (struct) (content changes based on the sequence, see individual functions below)
%   params       - Updated parameters structure
%
% (c) Kübra Keskin 2025

fprintf('\nPerforming reconstruction...\n');
trecon = tic;

switch params.seqname
    case 'SEMAC'
        [final_images, params] = reconstructSEMAC(images, params);
        
    case 'MAVRIC'
        [final_images, params] = reconstructMAVRIC(images, params);
        
    case 'MAVRIC-SL'
        [final_images, params] = reconstructMAVRICSL(images, params);
        
    case 'TSE'
        [final_images, params] = reconstructTSE(images, params);
        
    case 'VAT'
        [final_images, params] = reconstructVAT(images, params);
        
    otherwise
        error('Unknown sequence type: %s', params.seqname);
end

recon_time = toc(trecon);
fprintf('Reconstruction completed in %.2f seconds\n', recon_time);

end