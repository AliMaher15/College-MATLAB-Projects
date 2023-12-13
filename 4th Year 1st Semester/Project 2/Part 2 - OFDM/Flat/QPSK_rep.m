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
Bitc = repelem(Bits,3);
%% Zero Padding
num_of_zeros = 2 * length(Bitc)/126;
Bitp = zeros(1,length(Bitc) + num_of_zeros);
n = 1;
for i=1:length(Bitc)
    if mod(i,126)==0
        Bitp(n:n+2) = [Bitc(i) 0 0];
        n = n + 3;
    else
        Bitp(n) = Bitc(i);
        n = n + 1;
    end
end
%% Interleaver
Bitc = zeros(128,length(Bitp)/128);
n = 1;
for i = 1:size(Bitc,2)
    Bitc(:,i) = matintrlv(Bitp(n:n+127),8,16);
    n = n + 128;
end
%% QPSK Mapper
STx = zeros(128/2,length(Bitc));
for col = 1 : size(STx,2)
for k = 1 : log2(M) : size(Bitc,1)-mod(size(Bitc,1),log2(M))
    bit = base2dec([Bitc(k,col) Bitc(k+1,col)]+'0',10);
    dec = bin2dec(num2str(bit));
    STx(floor(k/log2(M))+1,col) = s(dec+1);
end
end
%% IFFT
OFDM_mat = reshape(STx, 64, []);
Tx_IFFT = ifft(OFDM_mat, 64);
%% Add Cyclic Extension
Tx_cycpre = zeros(64+16,length(Tx_IFFT));
for i=1:length(Tx_IFFT)
    prefix = Tx_IFFT(49:end,i); % 16 samples
    Tx_cycpre(:,i)=vertcat(prefix,Tx_IFFT(:,i));
end
%% QPSK Channel
Es = 4*(real(s(1))^2 + imag(s(1))^2) / M;
Ebinfo = info*Es / log2(M);
Eb = Ebinfo;
for k = 1 : length(SNR_dB) 
%------------------- Flat Rayleigh Channel -------------------%
SNR_ABS = 10^(SNR_dB(k)/10);
No = (Eb/3)/SNR_ABS;
awgn_noise = sqrt(No/2).*randn(size(Tx_cycpre)) + ...
              1i.*sqrt(No/2).*randn(size(Tx_cycpre));
v1 = sqrt(No/2).*randn(1,length(Tx_cycpre));
v2 = 1i.*sqrt(No/2).*randn(1,length(Tx_cycpre));
Rayleigh = sqrt(pow2(v1) + pow2(v2)) / sqrt(2);
Tx_channel = zeros(size(Tx_cycpre));
for i = 1:length(Tx_channel)
Tx_channel(:,i)= conv((Tx_cycpre(:,i)+awgn_noise(:,i))...
                   ,Rayleigh(:,i));
end
%% Reciever
% equalization
Rx_eq = zeros(size(Tx_channel));
for i = 1:length(Tx_channel)
    Rx_eq(:,i)= deconv(Tx_channel(:,i),Rayleigh(:,i));
end
% remove cyclic prefix
Rx_nopre(1:64,1:length(Tx_channel))= Rx_eq(17:80,1:length(Tx_channel));
% FFT
Rx_FFT = fft(Rx_nopre,64);
%% DeMapper
output_bits_intr = zeros(128,size(Rx_FFT,2));
for col = 1 : size(Rx_FFT,2)
ii = 1;
for j = 1:size(Rx_FFT,1)
for i = 1:length(s)
dxs(i) = (real(Rx_FFT(j,col))-real(s(i))).^2 + (imag(Rx_FFT(j,col))-imag(s(i))).^2;
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
%% ---------------- DeInterleaver ---------------- %%
output_bits_rep = zeros(size(output_bits_intr));
for i = 1:size(output_bits_intr,2)
    output_bits_rep(:,i) = matdeintrlv(output_bits_intr(:,i),8,16);
end
output_bits_rep = reshape(output_bits_rep,1,[]);
%% ------------- Remove Zero Padding -------------- %%
Bitz = [];
for i = 1:length(output_bits_rep)
    if (mod(i,127)~=0) && (mod(i,128)~=0)
        Bitz=[Bitz output_bits_rep(i)];
    end
end
%% ------------ Hard decision of 3 bits -------------- %%
cnt = 1;
for i = 1 : length(output_bits)
    rep = cat(2,Bitz(cnt),Bitz(cnt+1),Bitz(cnt+2));
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