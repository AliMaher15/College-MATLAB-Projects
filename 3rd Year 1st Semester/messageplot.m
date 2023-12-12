function messageplot(m, fs, txt, x, y, n)
subplot(x,y,n)
m = fft(m);
N = size(m,2);
k=-N/2:N/2-1;
plot(k*fs/N,fftshift(abs(m)))
title(txt, 'Interpreter', 'none');