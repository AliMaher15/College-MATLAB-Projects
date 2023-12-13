function BER = BPSK_rep_Soft(A,Bits,ebno,info,seed)
%% Variables
rng(seed);
dxs = zeros(1,2);
output_bits = zeros(1,length(Bits));
soft = zeros(1,length(Bits));
BER = zeros(1,length(ebno));
Nerror = zeros(1,length(ebno));
%% Repetition Coding
Bits_rep = repelem(Bits,3);
%% BPSK Symbols
s = zeros(1,2);
for k = 1:2
    s(k) = A*cos((k-1)*2*pi/2) - 1i*A*sin((k-1)*2*pi/2);
end
% Gray Coding
s = [s(2) s(1)];
%% BPSK Mapper
STx = zeros(1,length(Bits_rep));
for k = 1 : length(Bits_rep)
    if Bits_rep(k) == 0
        STx(k) = s(1);
    else
        STx(k) = s(2);
    end
end
%% BPSK Channel
Ebinfo = info*A^2;
Eb = Ebinfo;
for k = 1 : length(ebno) 
    segma = sqrt((Eb/2)./10^(ebno(k)/10));
    z1 = sqrt(segma/2)*randn(1,length(STx));
    z2 = sqrt(segma/2)*randn(1,length(STx));
    noise = z1 + 1i * z2;
    %------------------- Adding Noise at Rx -------------------%
    x = STx + noise;
%% DeMapper
cnt = 1;
for j = 1:length(Bits)
    % Soft decision
    soft(j) = x(cnt) + x(cnt+1) + x(cnt+2);
    for i = 1:length(s)
        dxs(i) = (real(soft(j))-real(s(i))).^2 + (imag(soft(j))-imag(s(i))).^2;
    end
    [~, decision] = min(dxs);
    cnt = cnt + 3;
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