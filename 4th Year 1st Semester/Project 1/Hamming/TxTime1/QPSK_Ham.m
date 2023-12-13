function BER = QPSK_Ham(A,Bits,ebno,n,k,info,seed)
%% Variables
rng(seed);
M = 4;
dxs = zeros(1,M);
BER = zeros(1,length(ebno));
Nerror = zeros(1,length(ebno));
%% QPSK Symbols
s = zeros(1,M);
for z = 1:M
    s(z) = A*cos((2*z-1)*pi/M) - 1i*A*sin((2*z-1)*pi/M);
end
% Gray Coding
s = 2/sqrt(2)*[s(2) s(3) s(1) s(4)];
%% Hamming Coding
Bitc = encode(Bits,n,k,'hamming/binary');
%% QPSK Mapper
STx = zeros(1,length(Bitc)/log2(M));
for z = 1 : log2(M) : length(Bitc)-mod(length(Bitc),log2(M))
    bit = base2dec([Bitc(z) Bitc(z+1)]+'0',10);
    dec = bin2dec(num2str(bit));
    STx(floor(z/log2(M))+1) = s(dec+1);
end
%% QPSK Channel
Es = 4*(real(s(1))^2 + imag(s(1))^2) / M;
Ebinfo = info*Es / log2(M);
Eb = Ebinfo;
for z = 1 : length(ebno)
    segma = sqrt((Eb/2)./10^(ebno(z)/10));
    z1 = sqrt(segma/2)*randn(1,length(STx));
    z2 = sqrt(segma/2)*randn(1,length(STx));
    noise = z1 + 1i * z2;
    %------------------- Adding Noise at Rx -------------------%
    x = STx + noise;
%% DeMapper
ii = 1;
output_bitc = zeros(1,length(Bitc));
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
        output_bitc(ii) = str2double(bit(count));
        count = count + 1;
    end
    ii = ii + 1;
end
%% Hamming Decoder
output_bits = decode(output_bitc,n,k,'hamming/binary');
%% Probability of Error
%------------ The Number of Bits Predicted Wrong --------------%
Nerror(1,z) = biterr(Bits,output_bits);
BER(1,z) = Nerror(1,z)/length(Bits);
end