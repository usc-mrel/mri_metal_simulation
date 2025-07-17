function res = ifftc(x,dim)
% taken from Xinwei Shi's ImplantInversion

res = sqrt(size(x,dim))*fftshift(ifft(ifftshift(x,dim),[],dim),dim);

