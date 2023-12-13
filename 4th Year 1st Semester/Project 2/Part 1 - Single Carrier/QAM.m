function BER = QAM(E,Bits,SNR_dB,seed)
%% Variables
M = 16;
ai = [-3 -1 1 3];   % for consellation (real axis)
bi = [-3 -1 1 3];   % for consellation (imag axis)
rng(seed);
dxs = zeros(1,M);
BER = zeros(1,length(SNR_dB));
Nerror = zeros(1,length(SNR_dB));
%% QAM Symbols
s = zeros(1,M);
count = repmat([1 2 3 4],1,M);
for k = 1:4
    s(k) = E*ai(1) + 1i*E*bi(count(k));
end
for k = 5:8
    s(k) = E*ai(2) + 1i*E*bi(count(k));
end
for k = 9:12
    s(k) = E*ai(3) + 1i*E*bi(count(k));
end
for k = 13:16
    s(k) = E*ai(4) + 1i*E*bi(count(k));
end
% Gray Coding
s = [s(1)  s(2)  s(4)  s(3)...
     s(5)  s(6)  s(8)  s(7)...
     s(9)  s(10) s(12) s(11)...
     s(13) s(14) s(16) s(15)];
%% Interleaver
Bitc = zeros(16,length(Bits)/16);
n = 1;
for i = 1:size(Bitc,2)
    Bitc(:,i) = matintrlv(Bits(n:n+15),4,4);
    n = n + 16;
end
%% QAM Mapper
STx = zeros(16/4,length(Bitc));
for col = 1 : size(STx,2)
for k = 1 : log2(M) : size(Bitc,1)-mod(size(Bitc,1),log2(M))
bit = base2dec([Bitc(k,col) Bitc(k+1,col) Bitc(k+2,col) Bitc(k+3,col)]+'0',10);
dec = bin2dec(num2str(bit));
STx(floor(k/log2(M))+1,col) = s(dec+1);
end
end
%% QAM Channel
sm = 0;
for n = 1:length(s)
    sm = sm + real(s(n))^2 + imag(s(n))^2;
end
Es = sm / M;
Eb = Es / log2(M);
for k = 1 : length(SNR_dB) 
    SNR_ABS = 10^(SNR_dB(k)/10);
    No = Eb/SNR_ABS;
    awgn_noise = sqrt(No/2).*randn(size(STx)) + ...
                 1i.*sqrt(No/2).*randn(size(STx));
    v1 = sqrt(No/2).*randn(size(STx));
    v2 = 1i.*sqrt(No/2).*randn(size(STx));
    Rayleigh = sqrt(pow2(v1) + pow2(v2)) / sqrt(2);
    x = (Rayleigh.*STx) + awgn_noise;
%% Reciever
x = x ./ Rayleigh;
%% DeMapper
output_bits_intr = zeros(16,size(STx,2));
for col = 1 : size(STx,2)
ii = 1;
for j = 1:size(STx,1)
for i = 1:length(s)
    dxs(i) = (real(x(j,col))-real(s(i))).^2 + (imag(x(j,col))-imag(s(i))).^2;
end
[~, decision] = min(dxs);
%--------------- Estimate the Recieved Bits ---------------%
bit = dec2bin(decision-1,log2(M));
%every symbol is 4 bits
count = 1;
for ii = ii : ii+log2(M)-1
    output_bits_intr(ii,col) = str2double(bit(count));
    count = count + 1;
end
    ii = ii + 1;
end
end
%% DeInterleaver
output_bits = zeros(size(Bitc));
for i = 1:size(output_bits_intr,2)
    output_bits(:,i) = matdeintrlv(output_bits_intr(:,i),4,4);
end
output_bits = reshape(output_bits,1,[]);
%% Probability of Error
%------------ The Number of Bits Predicted Wrong --------------%
Nerror(1,k) = biterr(Bits,output_bits);
BER(1,k) = Nerror(1,k)/length(Bits);
end