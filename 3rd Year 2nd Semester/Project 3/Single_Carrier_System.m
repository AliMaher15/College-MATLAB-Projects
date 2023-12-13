clear
%% Variables
E = 1;              % Square Root of energy
SNR = {-2:10 -2:10 -2:12 -2:13}; 
%% Data Bits
rng('shuffle');                 % To Control The Rand Function rng
Bits = randi([0 1],1,120000);   % bits generation
%% Calling Different Modulation Techniques
[BER_BPSK,TheoBER_BPSK] = BPSK(E,Bits,SNR{1});
[BER_QPSK,TheoBER_QPSK] = QPSK(E,Bits,SNR{2});
[BER_8PSK,TheoBER_8PSK] = PSK8(E,Bits,SNR{3});
[BER_QAM,TheoBER_QAM] = QAM(E,Bits,SNR{4});
%% Graphs
figure(1)
semilogy(SNR{1},BER_BPSK,'r','LineWidth',2.5);
hold on;
semilogy(SNR{2},BER_QPSK,'y','LineWidth',2.5);
hold on;
semilogy(SNR{3},BER_8PSK,'g','LineWidth',2.5);
hold on;
semilogy(SNR{4},BER_QAM,'m','LineWidth',2.5);
hold on;
semilogy(SNR{1},TheoBER_BPSK,'ro','MarkerSize',9,'MarkerFaceColor','r');
hold on;
semilogy(SNR{3},TheoBER_8PSK,'go','MarkerSize',9,'MarkerFaceColor','g');
hold on;
semilogy(SNR{4},TheoBER_QAM,'mo','MarkerSize',9,'MarkerFaceColor','m');
hold off;
legend('BPSK', 'QPSK', '8PSK', '16-QAM');
xlabel('SNR (Eb/No)'); 
ylabel('BER');
ylim([1.28e-4,0.3]);
title('SNR Vs BER','FontSize', 15);
grid on;