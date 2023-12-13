function BER = QPSK_rep(E,Bits,SNR_dB,info,seed)
%% Variables
M = 4;
rng(seed);
dxs = zeros(1,M);
output_bits = zeros(1,length(Bits));
BER = zeros(1,length(SNR_dB));
Nerror = zeros(1,length(SNR_dB));
%% QPSK Symbols
s = zeros(1,M);
for k = 1:M
    s(k) = E*cos((2*k-1)*pi/M) - 1i*E*sin((2*k-1)*pi/M);
end
s = 2/sqrt(2)*[s(2) s(3) s(1) s(4)];
%% Repetition Coding
Bitr = repelem(Bits,3);
%% Interleaver
Bitc = zeros(16,length(Bitr)/16);
n = 1;
for i = 1:size(Bitc,2)
    Bitc(:,i) = matintrlv(Bitr(n:n+15),4,4);
    n = n + 16;
end
%% QPSK Mapper
STx = zeros(16/2,length(Bitc));
for col = 1 : size(STx,2)
for k = 1 : log2(M) : size(Bitc,1)-mod(size(Bitc,1),log2(M))
    bit = base2dec([Bitc(k,col) Bitc(k+1,col)]+'0',10);
    dec = bin2dec(num2str(bit));
    STx(floor(k/log2(M))+1,col) = s(dec+1);
end
end
%% QPSK Channel
Es = 4*(real(s(1))^2 + imag(s(1))^2) / M;
Ebinfo = info*Es / log2(M);
Eb = Ebinfo;
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
%every symbol is 2 bits
count = 1;
    for ii = ii : ii+log2(M)-1
        output_bits_intr(ii,col) = str2double(bit(count));
        count = count + 1;
    end
    ii = ii + 1;
end
end
%% ------------ DeInterleaver -------------- %%
output_bits_rep = zeros(size(output_bits_intr));
for i = 1:size(output_bits_intr,2)
    output_bits_rep(:,i) = matdeintrlv(output_bits_intr(:,i),4,4);
end
output_bits_rep = reshape(output_bits_rep,1,[]);
% Hard decision of 3 bits
cnt = 1;
for i = 1 : length(output_bits)
    rep = cat(2,output_bits_rep(cnt),output_bits_rep(cnt+1),output_bits_rep(cnt+2));
    switch num2str(rep,'%d')
        case {'000', '001', '010', '100'}
            output_bits(i) = 0;
        case {'011', '101', '110', '111'}
            output_bits(i) = 1;
    end
    cnt = cnt + 3;
end
%% Probability of Error
%------------ The Number of Bits Predicted Wrong --------------%
Nerror(1,k) = biterr(Bits,output_bits);
BER(1,k) = Nerror(1,k)/length(Bits);
end