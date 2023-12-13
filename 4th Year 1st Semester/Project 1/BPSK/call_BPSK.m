clear
%% Variables
seed = 7543;
A = 0.5;             % Sqrt(Eb) for each bit
A2 = A/sqrt(3);      % Sqrt(Eb/3) for information bit
SNR = -3:10;         % SNR from -3dB to 10dB
%% Data Bits
rng(seed);                     % To Control The Rand Function rng
Bits = randi([0 1],1,110000);  % bits generation
%% Calling Modulation Techniques
BER = BPSK(A,Bits,SNR,seed);
%% Graphs
figure(1)
semilogy(SNR,BER,'r','LineWidth',2.5);
xlabel('SNR (Eb/No)');
ylabel('BER');
xlim([-3.5,10.5]);
title('SNR Vs BER','FontSize', 15);
grid on;