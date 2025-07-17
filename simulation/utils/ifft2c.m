function res = ifft2c(x,N)
% taken from Xinwei Shi's ImplantInversion

if nargin<2
    N(1) = size(x,1);
    N(2) = size(x,2);
end
fctr = N(1)*N(2);

res = sqrt(fctr)*fftshift(fftshift(ifft2(ifftshift(ifftshift(x,1),2),N(1),N(2)),1),2);