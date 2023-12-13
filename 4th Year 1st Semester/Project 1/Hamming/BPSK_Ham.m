function BER = BPSK_Ham(A,Bits,ebno,n,k,info,seed)
%% Variables
rng(seed);
dxs = zeros(1,2);
BER = zeros(1,length(ebno));
Nerror = zeros(1,length(ebno));
%% BPSK Symbols
s = zeros(1,2);
for z = 1:2
    s(z) = A*cos((z-1)*2*pi/2) - 1i*A*sin((z-1)*2*pi/2);
end
% Gray Coding
s = [s(2) s(1)];
%% Hamming Coding
Bitc = encode(Bits,n,k,'hamming/binary');
%% BPSK Mapper
STx = zeros(1,length(Bitc));
for z = 1 : length(Bitc)
    if Bitc(z) == 0
        STx(z) = s(1);
    else
        STx(z) = s(2);
    end
end
%% BPSK Channel
Ebinfo = info*A^2;
Eb = Ebinfo;
for z = 1 : length(ebno) 
    segma = sqrt((Eb/2)./10^(ebno(z)/10));
    z1 = sqrt(segma/2)*randn(1,length(STx));
    z2 = sqrt(segma/2)*randn(1,length(STx));
    noise = z1 + 1i * z2;
    %------------------- Adding Noise at Rx -------------------%
    x = STx + noise;
%% DeMapper
output_bitc = zeros(1,length(Bits));
for j = 1:length(STx)
    for i = 1:length(s)
        dxs(i) = (real(x(j))-real(s(i))).^2 + (imag(x(j))-imag(s(i))).^2;
    end
    [~, decision] = min(dxs);
    %--------------- Estimate the Recieved Bits ---------------%
    bit = dec2bin(decision-1,1);
    %every symbol is 1 bit
    output_bitc(j) = str2double(bit);
end
output_bits = decode(output_bitc,n,k,'hamming/binary');
%% Probability of Error
%------------ The Number of Bits Predicted Wrong --------------%
Nerror(1,z) = biterr(Bits,output_bits);
BER(1,z) = Nerror(1,z)/length(Bits);
end