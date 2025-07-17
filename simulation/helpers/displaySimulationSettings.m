function displaySimulationSettings(params)
% DISPLAYSIMULATIONSETTINGS Prints simulation settings

fprintf('\n========== Simulation Settings ==========\n');
fprintf('Sequence:                 %s\n', params.seqname);
fprintf('B0 Field strength:        %.2f Tesla\n', params.B0);
fprintf('Number of bins/factor:    %d\n', params.Nbins);
fprintf('RF bandwidth:             %.2f kHz\n', params.rfBW);
fprintf('Readout bandwidth:        %d Hz/pixel\n', params.readBWpix);
fprintf('TR/TE:                    %d/%d ms\n', params.TR, params.TE);
fprintf('Slice thickness:          %.1f mm\n', params.slthick);
fprintf('Image resolution:         %.1f x %.1f mm\n', params.imres(1), params.imres(2));
fprintf('FOV:                      %.1f x %.1f x %.1f mm\n', params.FOVx, params.FOVy, params.FOVz);
fprintf('Matrix size:              %d x %d x %d\n', params.Nread, params.Nype, params.Nslc);
fprintf('Number of averages:       %d\n', params.NEX);
fprintf('Add noise:                %s\n', string(params.add_noise));
fprintf('=========================================\n\n');
end