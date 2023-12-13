clear
%% Variables
seed = 7864;
A = 0.7;                   % Energy per transmitted bit
A74 = A * sqrt(4/7);       % same energy for information bit
A1511 = A * sqrt(11/15);   % same energy for information bit
SNR = -3:10;               % SNR from -3dB to 10dB
%% Data Bits
rng(seed);                % To Control The Rand Function rng
Bits = randi([0 1],1,110000);  % bits generation
%% BPSK No Coding
BER = BPSK(A,Bits,SNR,seed);
%% Hamming code (7,4)
BER_Ham74   = BPSK_Ham(A ,Bits,SNR,7,4,1,seed);
BER_Ham74_i = BPSK_Ham(A74,Bits,SNR,7,4,7/4,seed);
%% Hamming code (15,11)
BER_Ham1511   = BPSK_Ham(A ,Bits,SNR,15,11,1,seed);
BER_Ham1511_i = BPSK_Ham(A1511,Bits,SNR,15,11,15/11,seed);
%% Graphs
figure(1)
semilogy(SNR,BER,'r','LineWidth',2.5);
hold on;
semilogy(SNR,BER_Ham74,'b','LineWidth',2.5);
hold on;
semilogy(SNR,BER_Ham74_i,'m','LineWidth',2.5);
hold off;
xlabel('SNR (Eb/No)');
ylabel('BER');
xlim([-3.5,10.5]);
title('Hamming(7,4)','FontSize', 15);
legend('No coding','Same energy per transmitted bit',...
      'Same energy per information bit');
grid on;
figure(2)
semilogy(SNR,BER,'r','LineWidth',2.5);
hold on;
semilogy(SNR,BER_Ham1511,'b','LineWidth',2.5);
hold on;
semilogy(SNR,BER_Ham1511_i,'m','LineWidth',2.5);
hold off;
xlabel('SNR (Eb/No)');
ylabel('BER');
xlim([-3.5,10.5]);
title('Hamming(15,11)','FontSize', 15);
legend('No coding','Same energy per transmitted bit',...
      'Same energy per information bit');
grid on;