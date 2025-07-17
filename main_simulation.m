%% Main Simulation Script
% Main simulation script for 
% "Open-Source Simulator of Imaging Near Metal at Arbitrary Magnetic Field Strengths"
%
% Author: Kübra Keskin
% Date:   July 2025

%%
clear;
clc;

% Add all subdirectories to path
addpath(genpath('./config'));
addpath(genpath('./simulation'));
addpath(genpath('./data'));

try
    % Load phantom data
    fprintf('Loading phantom data...\n');
    phantom_file = dir('./data/hip_combined_phantom*CoCr*05mm*.mat');
    if isempty(phantom_file)
        error('No phantom file found in data directory\n');
    end
    load([phantom_file(end).folder '/' phantom_file(end).name], 'phantom', 'phantom_config');
    fprintf('%s phantom with %.1f mm resolution loaded\n', phantom_config.materials.head, phantom.resolution(1))
    
    % Load simulation configuration
    sim_config = getSimulationConfig();
    
    % Override default simulation parameters if needed
    sim_config.imaging.TR = 2000;         % Repetition time (ms)
    sim_config.imaging.TE = 34;           % Echo time (ms)
    sim_config.imaging.readBWpix = 400;   % Readout bandwidth per pixel (Hz/px)
    sim_config.imaging.rfBW = 1.0;        % RF bandwidth (kHz)
    sim_config.imaging.slthick = 3;       % Slice thickness (mm)
    sim_config.imaging.NEX = 2;           % Number of averages
    sim_config.sequence.name = 'TSE';     % Sequence name
    sim_config.sequence.Nbins = 1;        % Number of spectral bins (relevant for MSI)
    sim_config.system.B0 = 0.55;          % Field strength (T)
    sim_config.noise.add_noise = true;    % whether to add noise
    sim_config.imaging.slices = [8,9,10]; % slices list to be simulated (default:[0] for all slices) 
    
    % Setup simulation parameters
    params = setupSimulationParams(phantom, sim_config);
    
    % Print simulation settings to the command window
    displaySimulationSettings(params);
    
    % Prepare B0 field-dependent parameter maps based on current B0
    phantom = prepareParameterMaps(phantom, params);
    
    % Run simulation
    [im, params, kspace, noise_params] = runSimulation(phantom, params);
    
    % Reconstruction
    [final_im, params] = runReconstruction(im, params);
    
    fprintf('\nSimulation completed successfully!\n');
    
    % Create results directory
    results_dir = './results';
    if ~exist(results_dir, 'dir')
        mkdir(results_dir);
    end
    
    % Create a timestamp for the output filename
    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    
    % Create output filename
    out_filename = sprintf('%s/%s_%s_%.2fT_Nbins%d_readBW%d_rfBW%.1f_res%.1f_%s.mat', ...
        results_dir, params.seqname, ...
        phantom_config.materials.head, params.B0, params.Nbins, ...
        params.readBWpix, params.rfBW, phantom.resolution(1), timestamp);
    
    % Save results
    fprintf('\nSaving simulation results to: %s\n', out_filename);
    save(out_filename, 'final_im', 'im', 'params', ...
        'kspace', 'noise_params', 'phantom_config', 'sim_config', 'phantom_file', '-v7.3');
    
    fprintf('\nSimulation results saved successfully!\n');
    
    % Visualize results
    visualizeSimulationResults(final_im, params);
    
catch ME
    % Error handling
    fprintf('\nError during simulation:\n');
    fprintf('%s\n', ME.message);
    fprintf('Error in %s (line %d)\n', ME.stack(1).name, ME.stack(1).line);
    rethrow(ME);
end


