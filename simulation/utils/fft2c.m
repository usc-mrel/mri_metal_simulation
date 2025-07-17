function res = fft2c(x,N)
% taken from Xinwei Shi's ImplantInversion

if nargin<2
    N(1) = size(x,1);
    N(2) = size(x,2);
end
fctr = N(1)*N(2);

res = 1/sqrt(fctr)*fftshift(fftshift(fft2(ifftshift(ifftshift(x,1),2),N(1),N(2)),1),2);

