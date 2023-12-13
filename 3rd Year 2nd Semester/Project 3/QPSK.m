function [BER,TheoBER] = QPSK(E,Bits,SNR_dB)
%% Variables
M = 4;
dxs = zeros(1,M);
output_bits = zeros(1,length(Bits));
BER = zeros(1,length(SNR_dB));
TheoBER = zeros(1,length(SNR_dB));
Nerror = zeros(1,length(SNR_dB));
%% QPSK Symbols
s = zeros(1,M);
for k = 1:M
    s(k) = E*cos((2*k-1)*pi/M) - 1i*E*sin((2*k-1)*pi/M);
end
% Gray Coding
s = 2/sqrt(2)*[s(2) s(3) s(1) s(4)];
%% QPSK Mapper
STx = zeros(1,length(Bits)/log2(M));
for k = 1 : log2(M) : length(Bits)-mod(length(Bits),log2(M))
    bit = base2dec([Bits(k) Bits(k+1)]+'0',10);
    dec = bin2dec(num2str(bit));
    STx(floor(k/log2(M))+1) = s(dec+1);
end
%% QPSK Channel
Es = 4*(real(s(1))^2 + imag(s(1))^2) / M;
Eb = Es / log2(M);
for k = 1 : length(SNR_dB) 
    SNR_ABS = 10^(SNR_dB(k)/10);
    No = Eb/SNR_ABS;
    n1 = sqrt(No/2)*randn(1,length(STx));
    n2 = sqrt(No/2)*randn(1,length(STx));
    noise = n1 + 1i * n2;
    %------------------- Adding Noise at Rx -------------------%
    x = STx + noise;
%% DeMapper
ii = 1;
for j = 1:length(STx)
    for i = 1:length(s)
        dxs(i) = (real(x(j))-real(s(i))).^2 + (imag(x(j))-imag(s(i))).^2;
    end
    [~, decision] = min(dxs);
    %--------------- Estimate the Recieved Bits ---------------%
    bit = dec2bin(decision-1,log2(M));
    %every symbol is 2 bits
    count = 1;
    for ii = ii : ii+log2(M)-1
        output_bits(ii) = str2double(bit(count));
        count = count + 1;
    end
    ii = ii + 1;
end
%% Probability of Error
%------------ The Number of Bits Predicted Wrong --------------%
for jj = 1:length(Bits)
    if Bits(1,jj) ~= output_bits(1,jj)
        Nerror(1,k) = Nerror(1,k) + 1;
    end
end
BER(1,k) = Nerror(1,k)/length(Bits);
TheoBER(1,k) = 0.5*erfc(sqrt(Eb/No));
end