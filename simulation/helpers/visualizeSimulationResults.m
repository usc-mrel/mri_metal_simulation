function visualizeSimulationResults(im, params)
% VISUALIZESIMULATIONRESULTS Displays representative simulation results

% Create figure
figure('Name', sprintf('%s Simulation Results', params.seqname));

% Number of slices
Ns = size(im.final, 3);

% If all slices are simulated
if length(params.slices) == params.Nslc
    % Pick a slice
    slice_id = 9;
    slice_id = min(slice_id, Ns);

    % Determine image limits
    temp = abs(im.final(:, :, slice_id));
    prct = prctile(temp(:), 97);

    % Display picked slice along with neighboring slices
    display_slices = [slice_id-2:min(slice_id+2, Ns)];
% If specific slices are simulated
else
    % Determine image limits
    temp = abs(im.final(:, :, params.slices(1)));
    prct = prctile(temp(:), 97); % 97 percentile
    
    display_slices = params.slices;
end

num_slices = length(display_slices);

% Display slices
for i = 1:num_slices
    subplot(1, num_slices, i);
    imagesc(abs(im.final(:, :, display_slices(i))), [0 prct]);
    title(sprintf('Slice %d', display_slices(i)));
    axis equal tight off;
    colormap(gca, 'gray');
end

% Title with sequence information
sgtitle(sprintf('%s - B0: %.2fT, Bins: %d, Read BW: %d Hz/px, RF BW: %d kHz, TR/TE: %d/%d ms', ...
    params.seqname, params.B0, params.Nbins, params.readBWpix, params.rfBW, params.TR, params.TE));
end