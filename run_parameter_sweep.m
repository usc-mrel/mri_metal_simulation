%% Script for Running Parameter Sweep Simulation
% Parameter sweep simulation file for 
% "Open-Source Simulator of Imaging Near Metal at Arbitrary Magnetic Field Strengths"
% Supports sweeping some simulation parameter across multiple values
% This file is called by main_parameter_sweep.m
%
% Author: Kübra Keskin
% Date:   July 2025

%%
% no clear here (on purpose)
clc;

% Add all subdirectories to path
addpath(genpath('./config'));
addpath(genpath('./simulation'));
addpath(genpath('./data'));

try
    % Load phantom data
    fprintf('Loading phantom data...\n');
    if isempty(phantom_file)
        error('No phantom file found in data directory');
    end
    load([phantom_file(end).folder '/' phantom_file(end).name], 'phantom', 'phantom_config');
    fprintf('%s phantom with %.1f mm resolution loaded\n', phantom_config.materials.head, phantom.resolution(1))
    
    % copy dfmap to not lose the original while running the sweeping loop
    dfmap = phantom.dfmap;
    
    % Load simulation configuration
    sim_config = getSimulationConfig();
    
    % Options for sweep parameters and its values
    % -------------------------------------------
    % Parameter to sweep (choose one) 
    % Examples of parameters that can be swept:
    % sweep_parameter = 'B0';           sweep_values = [0.55, 1.5, 3.0];
    % sweep_parameter = 'readBWpix';    sweep_values = [120, 250, 500, 700];
    % sweep_parameter = 'rfBW';         sweep_values = [0.5, 1.0, 1.5, 2.0];
    % sweep_parameter = 'Nbins';        sweep_values = [8, 12, 16, 24];
    % sweep_parameter = 'seqname';      sweep_values = {'SEMAC', 'TSE', 'VAT'};
    % sweep_parameter = 'TR';           sweep_values = [1500, 2100, 3000];
    % sweep_parameter = 'TE';           sweep_values = [20, 30, 40];
    % -------------------------------------------
    
    % Set default parameters (might be overwritten by sweep later if necessary)
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
    sim_config.imaging.slices = [9];      % slices list to be simulated (default:[0] for all slices) 
        
    % Create results directory
    results_dir = './results/parameter_sweep';
    if ~exist(results_dir, 'dir')
        mkdir(results_dir);
    end
    
    % Initialize arrays to store results
    num_values = length(sweep_values);
    results = cell(num_values, 1);
    
    % Create timestamp for this sweep
    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    
    % Run simulation for each parameter value
    fprintf('\n===============================================\n');
    fprintf('Starting parameter sweep for: %s\n', sweep_parameter);
    fprintf('Values: ');
    if isnumeric(sweep_values)
        fprintf('%.2f ', sweep_values);
    else
        fprintf('%s ', sweep_values{:});
    end
    fprintf('\n===============================================\n\n');
    
    % Loop through parameter values
    for i = 1:num_values
        sweep_value = sweep_values(i);
        
        % Display current parameter value
        if isnumeric(sweep_value)
            fprintf('\n----- %s = %.4g (%d of %d) -----\n\n', ...
                sweep_parameter, sweep_value, i, num_values);
        else
            fprintf('\n----- %s = %s (%d of %d) -----\n\n', ...
                sweep_parameter, sweep_value, i, num_values);
        end
        
        % Create a copy of sim_config to modify
        current_config = sim_config;
        
        % Set the current parameter value in the correct location
        % This handles different parameters in the configuration
        if strcmp(sweep_parameter, 'seqname')
            % Sequence name
            current_config.sequence.name = sweep_value{:};
            
        elseif strcmp(sweep_parameter, 'Nbins')
            % Number of spectral bins
            current_config.sequence.Nbins = sweep_value;
            
        elseif strcmp(sweep_parameter, 'readBWpix') || ...
                strcmp(sweep_parameter, 'rfBW') || ...
                strcmp(sweep_parameter, 'TR') || ...
                strcmp(sweep_parameter, 'TE')
            % Imaging parameters
            current_config.imaging.(sweep_parameter) = sweep_value;
            
        elseif strcmp(sweep_parameter, 'B0')
            % System parameters
            current_config.system.B0 = sweep_value;
            
        else
            error('Unknown parameter to sweep: %s', sweep_parameter);
        end
        
        % Setup simulation parameters
        params = setupSimulationParams(phantom, current_config);
        
        % Print simulation settings to the command window
        displaySimulationSettings(params);
        
        % Prepare B0 field-dependent parameter maps based on current B0
        phantom.dfmap = dfmap;
        phantom = prepareParameterMaps(phantom, params);
        
        % Run simulation
        [im, params, kspace, noise_params] = runSimulation(phantom, params);

        % Reconstruction
        [final_im, params] = runReconstruction(im, params);

        % Create output filename
        out_filename = sprintf('%s/%s_%s_%.2fT_Nbins%d_readBW%d_rfBW%.1f_res%.1f_%s.mat', ...
            results_dir, params.seqname, ...
            phantom_config.materials.head, params.B0, params.Nbins, ...
            params.readBWpix, params.rfBW, phantom.resolution(1), timestamp);
        
        % Save results
        fprintf('Saving simulation results to: %s\n', out_filename);
        save(out_filename, 'final_im', 'im', 'params', ...
            'kspace', 'noise_params', 'phantom_config', 'current_config', 'phantom_file', '-v7.3');

        fprintf('\nSimulation results saved successfully!\n');
        
        % Visualize results
        visualizeSimulationResults(final_im, params);
    end
    
    fprintf('\nParameter sweep completed successfully!\n');
    
catch ME
    % Error handling
    fprintf('\nError during parameter sweep:\n');
    fprintf('%s\n', ME.message);
    fprintf('Error in %s (line %d)\n', ME.stack(1).name, ME.stack(1).line);
    rethrow(ME);
end