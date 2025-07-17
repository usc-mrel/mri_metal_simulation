function [images, params, kspace, noise_params] = runSimulation(phantom, params)
% Inputs:
%   phantom - Phantom (struct)
%   params  - Simulation parameters (struct)
%
% Outputs:
%   images       - Simulated noisy image data (size: changes based on the sequence, see individual functions below)
%   params       - Updated parameters structure (only simulation time added)
%   ks           - k-space data without noise added
%   noise_params - Noise parameters (struct)
%
% (c) Kübra Keskin 2025

fprintf('\nRunning %s simulation...\n', params.seqname);
tsim = tic;

switch params.seqname
    case 'SEMAC'
        [images, params, kspace, noise_params] = simulateSEMAC(phantom.t1map, phantom.t2map, ...
            phantom.pdmap, phantom.dfmap, params);
        
    case 'MAVRIC'
        [images, params, kspace, noise_params] = simulateMAVRIC(phantom.t1map, phantom.t2map, ...
            phantom.pdmap, phantom.dfmap, params);
        
    case 'MAVRIC-SL'
        [images, params, kspace, noise_params] = simulateMAVRICSL(phantom.t1map, phantom.t2map, ...
            phantom.pdmap, phantom.dfmap, params);
        
    case 'TSE'
        [images, params, kspace, noise_params] = simulateTSE(phantom.t1map, phantom.t2map, ...
            phantom.pdmap, phantom.dfmap, params);
        
    case 'VAT'
        [images, params, kspace, noise_params] = simulateVAT(phantom.t1map, phantom.t2map, ...
            phantom.pdmap, phantom.dfmap, params);
        
    otherwise
        error('Unknown sequence type: %s', params.seqname);
end

simulation_time = toc(tsim);
fprintf('Simulation completed in %.2f minutes\n', simulation_time/60);

end