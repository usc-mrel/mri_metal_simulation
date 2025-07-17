function p = windowedSinc(Ns,TBW) 
% WINDOWEDSINC Generate a windowed sinc pulse
%
% Inputs:
%   N   - Number of points
%   TBW - Time-bandwidth product
%
% Outputs:
%   rf - Windowed sinc pulse
%
% (c) Kübra Keskin 2025

% Calculate sinc function
s = sinc([-1 : 2/(Ns-1) : 1] * TBW / 2);

% Apply Hamming window
w = hamming(Ns);

% Apply window to sinc pulse
p = (s(:).*w(:))';

% Normalize the pulse
p = p/sum(abs(p));
end
