function phantom = prepareParameterMaps(phantom, params)
% PREPAREPARAMETERMAPS Updates phantom parameter maps based on B0 field
% strength and defined specific parameter values
%
% This function adjusts the T1 relaxation times for different tissues based on
% an exponential model of the form T1 = A*(B0)^B, where the parameters A and B
% are tissue-specific.
% Custom constant values for T1, T2, and PD can be also defined directly.
% This function also scales the field map based on B0 field strength.
%
% Inputs:
%   phantom - phantom struct including phantom.{t1map,t2map,pdmap,dfmap}
%   params  - simulation parameters struct including params.B0
%
% Outputs:
%   phantom - Updated phantom struct
%
% (c) Kübra Keskin 2025

% Current B0 field strength
B0 = params.B0;

fprintf('Updating parameter maps based on B0 = %.2f T...\n', B0);

%% Define tissue-specific parameters for T1 = A*(B0)^B model
% MASK VALUES:
%   0: Implant
%   1: Air
%   2: Muscle
%   3: Fat
%   4: Bone
%   5: Bone Marrow
%   6: Blood
%   7: Cartilage
%   8: Bladder
%   9: Rectum
%  10: Other tissues

tissue_params = struct();

% Muscle (mask value: 2)
tissue_params(2).name = 'Muscle';
tissue_params(2).A_t1 = 800.4429;
tissue_params(2).B_t1 = 0.5533;

% Fat (mask value: 3)
tissue_params(3).name = 'Fat';
tissue_params(3).A_t1 = 221.3517;
tissue_params(3).B_t1 = 0.5082;

% Bone (mask value: 4)
tissue_params(4).name = 'Bone';
tissue_params(4).A_t1 = 181.7555;
tissue_params(4).B_t1 = 0.2605;

% Bone Marrow (mask value: 5)
tissue_params(5).name = 'Bone Marrow';
tissue_params(5).A_t1 = 197.6834;
tissue_params(5).B_t1 = 0.5446;

% Blood (mask value: 6)
tissue_params(6).name = 'Blood';
tissue_params(6).A_t1 = 1329.0010;
tissue_params(6).B_t1 = 0.3153;

% Cartilage (mask value: 7)
tissue_params(7).name = 'Cartilage';
tissue_params(7).A_t1 = 691.2790;
tissue_params(7).B_t1 = 0.6255;

%% ===== CUSTOMIZATION SECTION =====

% Custom constant values for specific tissues can be defined here
% Struct should be set to empty to use model fit or original phantom values
custom_tissue_values = struct();

% To add custom values:
% custom_tissue_values(TISSUE_ID).t1 = VALUE;  % Custom T1 (ms)
% custom_tissue_values(TISSUE_ID).t2 = VALUE;  % Custom T2 (ms)
% custom_tissue_values(TISSUE_ID).pd = VALUE;  % Custom PD (a.u.)

% Examples:
% custom_tissue_values(2).t1 = 700;    % Custom T1 for muscle (ms)
% custom_tissue_values(2).t2 = 50;     % Custom T2 for muscle (ms)
% custom_tissue_values(6).t1 = 1500;   % Custom T1 for blood (ms)
% custom_tissue_values(6).t2 = 100;    % Custom T2 for blood (ms)

% ===== END CUSTOMIZATION SECTION =====

%% Update tissue parameters based on model and/or custom values
all_tissue_ids = 0:10;
modeled_tissues = [2:7]; % Tissues with exponential models

% Original maps
original_t1map = phantom.t1map;
original_t2map = phantom.t2map;
original_pdmap = phantom.pdmap;

% Copies for modification
t1map = original_t1map;
t2map = original_t2map;
pdmap = original_pdmap;

% Update tissue parameters based on models or user-defined values
for tissue_id = all_tissue_ids
    
    % Skip if current tissue is not present in the phantom
    if ~any(phantom.mask(:) == tissue_id)
        continue;
    end
    
    % Assign params if model fit is used 
    if ismember(tissue_id, modeled_tissues)
        % Calculate T1 value for current B0 using exponential model
        A = tissue_params(tissue_id).A_t1;
        B = tissue_params(tissue_id).B_t1;
        t1_value = A * (B0 ^ B);
        
        % NOTE: This code utilizes exponential model for T1 B0 dependence 
        % However, any other model can be defined here
        
        % Update T1 map for this tissue
        t1map(phantom.mask == tissue_id) = t1_value;
    end
    
    % If there are custom values defined, override the params
    if isfield(custom_tissue_values, tissue_id)
        % Update T1 if defined
        if isfield(custom_tissue_values(tissue_id), 't1')
            t1map(phantom.mask == tissue_id) = custom_tissue_values(tissue_id).t1;
        end
        
        % Update T2 if defined
        if isfield(custom_tissue_values(tissue_id), 't2')
            t2map(phantom.mask == tissue_id) = custom_tissue_values(tissue_id).t2;
        end
        
        % Update PD if defined
        if isfield(custom_tissue_values(tissue_id), 'pd')
            pdmap(phantom.mask == tissue_id) = custom_tissue_values(tissue_id).pd;
        end
    end
    
end

% Update the phantom with modified maps
phantom.t1map = t1map;
phantom.t2map = t2map;
phantom.pdmap = pdmap;

% Scale the field map based on B0, and convert it to kHz
phantom.dfmap = phantom.dfmap*params.B0*1e-3; % (kHz)

fprintf('Parameter maps updated for B0 = %.2f T\n', B0);
end