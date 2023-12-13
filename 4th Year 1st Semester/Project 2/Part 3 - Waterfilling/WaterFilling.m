clear; clc;
%% Given Data
SNR_gap = 2;
noise = 1;
Power = 200;
nSubChannel = 16;
h=[0.4 0 0.26 0 0 0.4 0 0.6 0 0.5];
%% Operations on channel
N = 16;
channel = fft(h,N);
Hf = abs(channel);
%% Plot |H(f)| and snr_gab*noise/gain
gn = Hf.^2;
figure(1)
bar(gn) 
title("|H(f)|^2",'FontSize', 15)
Porginal = SNR_gap*noise ./gn;
figure(2)
bar(Porginal) 
title("\Gamma\sigma_n^2 / g_n^2",'FontSize', 15)
%% Solve the Problem
Pleft = Power;
Pmin = sort(Porginal);
i = 1;
while Pleft > 0
    Palloc = Pmin(i+1) - Pmin(i);
    if Pleft < i*Palloc
        Palloc = Pleft / i;
        Pmin(1:i) = Pmin(1) + Palloc;
    else
        Pmin(1:i) = Pmin(i) + Palloc;
    end
    Pleft = Pleft - i*Palloc;
    Pmin = sort(Pmin);
    i = i+1;
end
%% Reorder
Buffer = Porginal;
Pnew = zeros(1,nSubChannel);
for j = 1:nSubChannel
    [~,i]    = min(Buffer);
    Buffer(i) = Pmin(j);
    Pnew(i)   = Buffer(i);
    Buffer(i) = inf;
end
Pn = Pnew - Porginal;
%% Plot and Print allocated Power
for i = 1:nSubChannel
    Pgraph(:,i) = [Porginal(i) Pn(i)];
end
figure(3)
bar(Pgraph','stacked');
title("\Gamma\sigma_n^2 / g_n^2 after Allocation",'FontSize', 15)
for i = 1:nSubChannel
    fprintf('\n');
    fprintf('\t\tP(%d) = %f',i,Pn(i));
end
fprintf('\n\tTotal Power = %f\n', sum(Pn));