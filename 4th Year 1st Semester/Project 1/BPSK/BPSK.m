function BER = BPSK(E,Bits,ebno)
%% Variables
dxs = zeros(1,2);
output_bits = zeros(1,length(Bits));
BER = zeros(1,length(ebno));
Nerror = zeros(1,length(ebno));
%% BPSK Symbols
s = zeros(1,2);
for k = 1:2
    s(k) = E*cos((k-1)*2*pi/2) - 1i*E*sin((k-1)*2*pi/2);
end
% Gray Coding
s = [s(2) s(1)];
%% BPSK Mapper
STx = zeros(1,length(Bits));
for k = 1 : length(Bits)
    if Bits(k) == 0
        STx(k) = s(1);
    else
        STx(k) = s(2);
    end
end
%% BPSK Channel
Es = 2*(real(s(1)))^2 / 2;
Eb = Es / log2(2);
for k = 1 : length(ebno) 
    SNR_ABS = 10^(ebno(k)/10);
    No = Eb/SNR_ABS;
    n1 = sqrt(No/2)*randn(1,length(STx));
    n2 = sqrt(No/2)*randn(1,length(STx));
    noise = n1 + 1i * n2;
    %------------------- Adding Noise at Rx -------------------%
    x = STx + noise;
%% DeMapper
for j = 1:length(STx)
    for i = 1:length(s)
        dxs(i) = (real(x(j))-real(s(i))).^2 + (imag(x(j))-imag(s(i))).^2;
    end
    [~, decision] = min(dxs);
    %--------------- Estimate the Recieved Bits ---------------%
    bit = dec2bin(decision-1,1);
    %every symbol is 1 bit
    output_bits(j) = str2double(bit);
end
%% Probability of Error
%------------ The Number of Bits Predicted Wrong --------------%
for jj = 1:length(Bits)
    if Bits(1,jj) ~= output_bits(1,jj)
        Nerror(1,k) = Nerror(1,k) + 1;
    end
end
BER(1,k) = Nerror(1,k)/length(Bits);
end