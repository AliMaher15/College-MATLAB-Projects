clear
%% Variables
seed = 7864;
A = 0.7;                   % Energy per transmitted bit
Ai = A * sqrt(11/15);      % same energy for information bit
SNR = -3:10;               % SNR from -3dB to 10dB
%% Data Bits
rng(seed);                % To Control The Rand Function rng
Bits = randi([0 1],1,110000);  % bits generation
%% BPSK No Coding
BER = BPSK(A,Bits,SNR,seed);
%% Hamming code (15,11)
BER_Ham1511   = QPSK_Ham(A ,Bits,SNR,15,11,1,seed);
BER_Ham1511_i = QPSK_Ham(Ai,Bits,SNR,15,11,15/11,seed);
%% Graphs
figure(1)
semilogy(SNR,BER,'r','LineWidth',2.5);
hold on;
semilogy(SNR,BER_Ham1511,'b','LineWidth',2.5);
hold on;
semilogy(SNR,BER_Ham1511_i,'m','LineWidth',2.5);
hold off;
xlabel('SNR (Eb/No)');
ylabel('BER');
xlim([-3.5,10.5]);
title('Hamming(15,11) - QPSK','FontSize', 15);
legend('BPSK - No coding','QPSK - Same energy per transmitted bit',...
      'QPSK - Same energy per information bit');
grid on;