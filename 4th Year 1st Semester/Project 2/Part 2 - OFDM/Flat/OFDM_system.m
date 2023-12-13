clear
%% Variables
seed = 7864;
E  = 1;              % Energy per bit
Ei = E * sqrt(1/3);  % Same enrgy per inf
SNR = {-4:2:18 -4:2:18}; 
%% Data Bits
rng(seed);                     % To Control The Rand Function rng
Bits = randi([0 1],1,128000);  % bits generation
%% QPSK Modulation Technique
BER_QPSK_nocode = QPSK(E,Bits,SNR{1},seed);
BER_QPSK_rep    = QPSK_rep(E,Bits(1:84000),SNR{1},1,seed);
BER_QPSK_rep_i  = QPSK_rep(Ei,Bits(1:84000),SNR{1},3,seed);
%% QAM Modulation Technique
BER_QAM_nocode = QAM(E,Bits,SNR{2},seed);
BER_QAM_rep    = QAM_rep(E,Bits(1:85000),SNR{2},1,seed);
BER_QAM_rep_i  = QAM_rep(Ei,Bits(1:85000),SNR{2},3,seed);
%% Graphs
figure(1)
semilogy(SNR{1},BER_QPSK_nocode,'r','LineWidth',2.5);
hold on;
semilogy(SNR{1},BER_QPSK_rep,'b','LineWidth',2.5);
hold on;
semilogy(SNR{1},BER_QPSK_rep_i,'m','LineWidth',2.5);
legend('No Code', 'Repetition - Same energy per bit',...
       'Repetition - Same energy per info',...
       'Location','southwest');
xlabel('SNR (Eb/No)'); 
ylabel('BER');
xlim([SNR{1}(1)-0.2 SNR{1}(12)+0.2]);
title('QPSK - Flat Channel','FontSize', 15);
grid on;
hold off;
figure(2)
semilogy(SNR{2},BER_QAM_nocode,'r','LineWidth',2.5);
hold on;
semilogy(SNR{2},BER_QAM_rep,'b','LineWidth',2.5);
hold on;
semilogy(SNR{2},BER_QAM_rep_i,'m','LineWidth',2.5);
legend('No Code', 'Repetition - Same energy per bit',...
       'Repetition - Same energy per info',...
       'Location','southwest');
xlabel('SNR (Eb/No)'); 
ylabel('BER');
xlim([SNR{2}(1)-0.2 SNR{2}(12)+0.2]);
title('QAM - Flat Channel','FontSize', 15);
grid on;
hold off;