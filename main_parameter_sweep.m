%% Main Parameter Sweep Simulation Script
% Main parameter sweep simulation script for 
% "Open-Source Simulator of Imaging Near Metal at Arbitrary Magnetic Field Strengths"
% Supports sweeping one chosen simulation parameter across multiple values
% This file will call run_parameter_sweep.m
%
% Author: Kübra Keskin
% Date:   July 2025

%% Define the parameter to sweep and its values
% Parameter to sweep (choose one) 
% Examples of parameters that can be swept and some example values (these can be chosen anything physically reasonable)
% sweep_parameter = 'B0';           sweep_values = [0.55, 1.5, 3.0];
% sweep_parameter = 'readBWpix';    sweep_values = [120, 250, 500, 700];
% sweep_parameter = 'rfBW';         sweep_values = [0.5, 1.0, 1.5, 2.0];
% sweep_parameter = 'Nbins';        sweep_values = [8, 12, 16, 24];
% sweep_parameter = 'seqname';      sweep_values = {'SEMAC', 'TSE', 'VAT', 'MAVRIC', 'MAVRIC-SL'};
% sweep_parameter = 'TR';           sweep_values = [1500, 2100, 3000];
% sweep_parameter = 'TE';           sweep_values = [20, 30, 40];

%% Example Usage 1
clear;
clc;

% Sweep parameter
sweep_parameter = 'B0';
sweep_values = [0.55, 1.5, 3.0];

phantom_file = dir('./data/hip_combined_phantom*TiCer*05mm*.mat');
run run_parameter_sweep.m

%% Example Usage 2
clear;
clc;

% Sweep parameter
sweep_parameter = 'readBWpix';
sweep_values = [100, 200, 400];

phantom_file = dir('./data/hip_combined_phantom*CoCr*05mm*.mat');
run run_parameter_sweep.m
