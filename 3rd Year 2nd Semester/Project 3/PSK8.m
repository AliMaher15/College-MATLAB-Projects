function [BER,TheoBER] = PSK8(E,Bits,SNR_dB)
%% Variables
M = 8;
dxs = zeros(1,M);
output_bits = zeros(1,length(Bits));
BER = zeros(1,length(SNR_dB));
TheoBER = zeros(1,length(SNR_dB));
Nerror = zeros(1,length(SNR_dB));
%% 8PSK Symbols
s = zeros(1,M);
for k = 1:M
    s(k) = E*cos((k-1)*2*pi/M) - 1i*E*sin((k-1)*2*pi/M);
end
% Gray Coding
s = [s(1) s(8) s(6) s(7)...
     s(2) s(3) s(5) s(4)];
%% 8PSK Mapper
STx = zeros(1,length(Bits)/log2(M));
for k = 1 : log2(M) : length(Bits)-mod(length(Bits),log2(M))
    bit = base2dec([Bits(k) Bits(k+1) Bits(k+2)]+'0',10);
    dec = bin2dec(num2str(bit));
    STx(floor(k/log2(M))+1) = s(dec+1);
end
%% 8PSK Channel
sm = 0;
for n = 1:length(s)
    sm = sm + real(s(n))^2 + imag(s(n))^2;
end
Es = sm / M;
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
    %every symbol is 3 bits
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
TheoBER(1,k) = (1/log2(M))*erfc(sqrt((log2(M)*Eb)/No)*sin(pi/M));
end