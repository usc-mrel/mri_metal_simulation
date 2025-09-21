%% Spectral Bins Analysis Script
% Analyze signal percentage in ROI within a specific distance (cm)
% of implant boundary for all spectral bin images of a given slice
%
% Author: Kübra Keskin
% Date:   Sep 2025

%% Flags
% reload data flag
% (if true data will be reloaded each run, if false already loaded data will be used)
reload_data = false;

% save results flag
% (if true analysis results and figure will be saved)
save_results = true;

%% Analysis details
implant_type = 'CoCr'; % 'TiCer'    (string)
B0 = '3.00'; % '0.55', '1.50'       (string)

slice_to_analyze = 21; % slice to be analyzed (Note: central slice for CoCr: 21, TiCer: 19 in Nbins36 data)
boundary_distance_cm = 3; % distance (cm) from the implant boundary

%% Directories
sim_dir = '../results/parameter_sweep'; % simulation result directory
output_dir = '../results/analysis'; % analysis output directory
phantom_dir = '../data/'; % phantom used for the simulation directory

if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

%% Load results and phantom data
% load results data
sim_file = dir(fullfile(sim_dir, ['*SEMAC*implant*' implant_type '*' B0 'T*Nbins36*.mat']));
if ~exist('result_data', 'var') || reload_data
    result_data = load(fullfile(sim_file(1).folder, sim_file(1).name));
    disp('Results data loaded');
end

% load phantom data
phantom_name = ['hip_implant_phantom_' implant_type '_05mm.mat'];
phantom_path = fullfile(phantom_dir, phantom_name);
if ~exist('phantom_data', 'var') || reload_data
    phantom_data = load(phantom_path);
    disp('Phantom data loaded');
end

%% Extract data
bins_data = result_data.final_im.bins; % [Nread x Nype x Nslc x Nbins]
params = result_data.params;
phantom_mask = phantom_data.phantom.mask;
phantom_resolution = phantom_data.phantom.resolution;

%% Create boundary region mask
% Convert boundary distance to pixels
boundary_distance_mm = boundary_distance_cm * 10;
boundary_distance_pixels = round(boundary_distance_mm / params.imres(1));

% Calculate corresponding phantom slice
slice_ratio = params.slthick / phantom_resolution(3);
phantom_slice_id = slice_to_analyze * slice_ratio;

% mask == 0 represents implant
binary_mask = phantom_mask(:, :, phantom_slice_id) == 0;

% Resize to match image dimensions
[img_rows, img_cols] = size(bins_data, 1:2);
mask_resized = imresize(binary_mask, [img_rows, img_cols], 'nearest');

% Create object mask
object_mask = logical(mask_resized);

% Create boundary region (X cm outside object)
distances = bwdist(object_mask);
boundary_region = (distances > 0) & (distances <= boundary_distance_pixels);
boundary_region_with_object = (distances <= boundary_distance_pixels);

fprintf('Number of pixels inside the boundary region: %d\n', sum(boundary_region(:)));

%% Find signal threshold based on highest signal across all bins
Nbins = size(bins_data, 4);

% Find maximum signal across all bins for the chosen slice
temp_image = abs(squeeze(bins_data(:, :, slice_to_analyze, :)));
max_signal_all_bins = max(temp_image(:));

% Set threshold as percentage of maximum signal
threshold_percentage = 0.1; % X% of maximum signal
signal_threshold = threshold_percentage * max_signal_all_bins;

fprintf('Maximum signal across all bins: %.4f\n', max_signal_all_bins);
fprintf('Signal threshold (%.0f%% of max): %.4f\n', threshold_percentage * 100, signal_threshold);

%% Analyze each bin
results = zeros(Nbins,1);
for bin_idx = 1:Nbins
    % Get image data for this bin and slice
    bin_image = abs(squeeze(bins_data(:, :, slice_to_analyze, bin_idx)));

    % Get signals in boundary region
    boundary_signals = bin_image(boundary_region);

    % Calculate percentage above threshold
    above_threshold = boundary_signals > signal_threshold;
    percentage_above_threshold = (sum(above_threshold) / length(boundary_signals)) * 100;

    results(bin_idx) = percentage_above_threshold;

    fprintf('Bin %d: %.2f%% above threshold\n', bin_idx, percentage_above_threshold);
end

%% Plot percentages
fig = figure('Name', 'Signal Analysis', 'Position', [100 100 900 500]);

% Show sample image with boundary region
sample_image = result_data.final_im.final(:, :, slice_to_analyze);
subplot(1, 2, 1);
imshow(sample_image, []);
hold on;
[r, c] = find(boundary_region);
scatter(c, r, 1, 'y', 'filled', 'MarkerFaceAlpha', 0.5);
title(sprintf('ROI (within %.1f cm)', boundary_distance_cm));

% Show threshold bar plot
subplot(1, 2, 2);
y = [-Nbins/2+1:Nbins/2];
bar(y, results);
xlabel('Spectral Bin Frequency (kHz)');
ylabel('Signal Percentage (%)');
title(sprintf('%s Implant (slice: %d) - %s T', implant_type, slice_to_analyze, B0));
grid on;
ylim([0 30])

%% Save results
if save_results
    output_data = struct();
    output_data.sim_file = sim_file(1).name;
    output_data.slice_to_analyze = slice_to_analyze;
    output_data.phantom_slice_id = phantom_slice_id;
    output_data.boundary_distance_cm = boundary_distance_cm;
    output_data.signal_threshold = signal_threshold;
    output_data.threshold_percentage = threshold_percentage;
    output_data.max_signal_all_bins = max_signal_all_bins;
    output_data.results = results;

    save_name = sprintf('%s_slice%d_%dcm_spectral_bins_analysis',...
        sim_file(1).name(1:end-4), slice_to_analyze, boundary_distance_cm);

    % Save the results
    save_path = fullfile(output_dir, [save_name '.mat']);
    save(save_path, 'output_data');
    fprintf('\nResults saved to: %s\n', save_path);

    % Save the figure
    fig_path = fullfile(output_dir, [save_name '.fig']);
    savefig(fig, fig_path);
    fprintf('\nMatlab figure saved to: %s\n', fig_path);
end