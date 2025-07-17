function res = fftc(x,dim)
% taken from Xinwei Shi's ImplantInversion

res = 1/sqrt(size(x,dim))*fftshift(fft(ifftshift(x,dim),[],dim),dim);

