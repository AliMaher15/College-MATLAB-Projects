clear
%% Variables
seed = 7842;
A = 0.7;             % Same Energy per Transmitted bit
Ai = A * sqrt(1/3);  % Same Energy per information bit
SNR = -3:10;         % SNR from -3dB to 10dB
%% Data Bits
rng(seed);                     % To Control The Rand Function rng
Bits = randi([0 1],1,110000);  % bits generation
%% BPSK No Coding
BER = BPSK(A,Bits,SNR,seed);
%% Hard Decision
BER_BPSK_rep_Hard1 = BPSK_rep_Hard(A,Bits,SNR,1,seed);
BER_BPSK_rep_Hard2 = BPSK_rep_Hard(Ai,Bits,SNR,3,seed);
%% Soft Decision
BER_BPSK_rep_Soft1 = BPSK_rep_Soft(A,Bits,SNR,1,seed);
BER_BPSK_rep_Soft2 = BPSK_rep_Soft(Ai,Bits,SNR,3,seed);
%% Graphs
figure(1)
semilogy(SNR,BER,'r','LineWidth',2.5);
hold on;
semilogy(SNR,BER_BPSK_rep_Hard1,'b','LineWidth',2.5);
hold on;
semilogy(SNR,BER_BPSK_rep_Hard2,'m','LineWidth',2.5);
hold off;
xlabel('SNR (Eb/No)');
ylabel('BER');
xlim([-3.5,10.5]);
title('Hard Decision','FontSize', 15);
legend('No coding','Same energy per transmitted bit',...
      'Same energy per information bit');
grid on;
figure(2)
semilogy(SNR,BER,'r','LineWidth',2.5);
hold on;
semilogy(SNR,BER_BPSK_rep_Soft1,'b','LineWidth',2.5);
hold on;
semilogy(SNR,BER_BPSK_rep_Soft2,'m','LineWidth',2.5);
hold off;
xlabel('SNR (Eb/No)');
ylabel('BER');
xlim([-3.5,10.5]);
title('Soft Decision','FontSize', 15);
legend('No coding','Same energy per transmitted bit',...
       'Same energy per information bit');
grid on;