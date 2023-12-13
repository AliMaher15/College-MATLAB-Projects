%% Variables Definitions
A=4 ;
%Ensemble Autocorrelation%
sacfNRZ=zeros(700,1);
sacfRZ=zeros(700,1) ;
sacfunipolar=zeros(700,1) ;
%One waveform Autocorrelation%
tacfNRZ=zeros(700,1) ;
tacfRZ=zeros(700,1) ;
tacfunipolar=zeros(700,1) ;
%Statistical mean%
smNRZ=zeros(100,1) ;
smRZ=zeros(100,1) ;
smunipolar=zeros(100,1) ;
%Time mean%
tmNRZ=zeros(500,1) ;
tmRZ=zeros(500,1) ;
tmunipolar=zeros(500,1) ;
%% Initial Data and Delay of 1 waveform
rng(0);
Data=randi([0 1],500,100) ;%every row is a waveform%
datanewpolar=zeros(500,100) ;
datanewunipolar=zeros(500,100) ;
%% 500 waveforms Ensemble with each bit represented by 7 samples
rng('shuffle');
delay=randi([0 7],500,1) ;
DatarecNRZ=zeros(500,700) ;
DatarecRZ=zeros(500,700) ;
Datarecunipolar=zeros(500,700) ;
DatarecdelayNRZ=zeros(500,700) ;
Datarecdelayunipolar=zeros(500,700) ;
DatarecdelayRZ=zeros(500,700) ;
%% 
for k=1:500
    %% Convert Bits to +4/-4 for polar and +4/0 for unipolar
    datanewpolar(k,:)=((2*Data(k,:))-1)*A ;
    datanewunipolar(k,:)=Data(k,:)*A ;
end
for i=1:500
%% Time mean of Polar NRZ
Txpolar=datanewpolar(i,:) ;
Tx2NRZ=repmat(Txpolar,7,1) ;
Tx_out1NRZ=reshape(Tx2NRZ,size(Tx2NRZ,1)* size(Tx2NRZ,2),1);
Tx_outNRZ=[Tx_out1NRZ(end-delay(i,1)+1:end) ;Tx_out1NRZ(1:end-delay(i,1))];
tmNRZ(i,1)=sum(Tx_outNRZ(:,1))/700 ;
DatarecdelayNRZ(i,:)=transpose(Tx_outNRZ) ;
DatarecNRZ(i,:)=transpose(Tx_out1NRZ) ;
%% Time mean of Polar RZ
Tx2RZ=[repmat(Txpolar,3,1) ;zeros(4,100)] ;
Tx_out1RZ=reshape(Tx2RZ,size(Tx2RZ,1)* size(Tx2RZ,2),1);
Tx_outRZ=[Tx_out1RZ(end-delay(i,1)+1:end) ;Tx_out1RZ(1:end-delay(i,1))] ;
tmRZ(i,1)=sum(Tx_outRZ(:,1))/700 ;
DatarecdelayRZ(i,:)=transpose(Tx_outRZ) ;
DatarecRZ(i,:)=transpose(Tx_out1RZ) ;
%% Time mean of UniPolar
Txunipolar=datanewunipolar(i,:) ;
Tx2unipolar=repmat(Txunipolar,7,1) ;
Tx_out1unipolar=...
reshape(Tx2unipolar,size(Tx2unipolar,1)* size(Tx2unipolar,2),1);
Tx_outunipolar=...
[Tx_out1unipolar(end-delay(i,1)+1:end) ;Tx_out1unipolar(1:end-delay(i,1))];
tmunipolar(i,1)=sum(Tx_outunipolar(:,1))/700 ;
Datarecdelayunipolar(i,:)=transpose(Tx_outunipolar) ;
Datarecunipolar(i,:)=transpose(Tx_out1unipolar) ;
end
for j=1:700
%% Statistical Mean and Autocorrelation of Polar NRZ
   smNRZ(j,1)=sum(DatarecdelayNRZ(:,j))/500 ;
   sacfNRZ(j,1)=sum((1/500).*DatarecNRZ(:,1).*DatarecNRZ(:,j)) ;
%% Statistical Mean and Autocorrelation of Polar RZ
   smRZ(j,1)=sum(DatarecdelayRZ(:,j))/500 ;
   sacfRZ(j,1)=sum((1/500).*DatarecdelayRZ(:,1).*DatarecdelayRZ(:,j)) ;
%% Statistical Mean and Autocorrelation of UniPolar
   smunipolar(j,1)=sum(Datarecdelayunipolar(:,j))/500 ;
   sacfunipolar(j,1)=...
   sum((1/500).*Datarecunipolar(:,1).*Datarecunipolar(:,j)) ;
end
for taw=0:699
   for r=1:700-taw
%% Time Autocorrelation of Polar NRZ
tacfNRZ(taw+1)=...
tacfNRZ(taw+1)+...
(1/(700-taw)).*DatarecdelayNRZ(1,r).*DatarecdelayNRZ(1,r+taw) ; 
%% Time Autocorrelation of Polar RZ
tacfRZ(taw+1)=...
tacfRZ(taw+1)+...
(1/(700-taw)).*DatarecdelayRZ(1,r).*DatarecdelayRZ(1,r+taw) ;  
%% Time Autocorrelation of UniPolar
tacfunipolar(taw+1)=...
tacfunipolar(taw+1)+...
(1/(700-taw)).*Datarecdelayunipolar(1,r).*Datarecdelayunipolar(1,r+taw) ; 
   end
end
%% Plotting Transmitted Bits of 1 waveform 
t=0:1:699 ;
% Polar NRZ
bitsplot(t, Tx_outNRZ, "Time", "Bit value", "Polar NRZ Waveform",...
        [-0.5 250], [-5 5]);
% Polar RZ
bitsplot(t, Tx_outRZ, "Time", "Bit value", "Polar RZ Waveform",...
        [-0.5 250], [-5 5]);
% UniPolar
bitsplot(t, Tx_outunipolar, "Time", "Bit value", "UniPolar Waveform",...
        [-0.5 250], [-1 5]);
%% Plotting Variables of Polar NRZ
taw=0:1:699 ;
taw2=0:1:99 ;
sampleno=1:1:500;
% Time Autocorrelation
figure
tacfplot=tacfNRZ(1:1:700);
autoplot(taw, tacfplot, "taw", "Waveform Rx",...
        "Time ACF of Polar NRZ", [-700 700], 'auto');
hold on
autoplot(-taw, tacfplot, "taw", "Waveform Rx",...
        "Time ACF of Polar NRZ", [-700 700], 'auto');
% Power Spectral Density
figure
psd=fftshift(fft(sacfNRZ));
f=-44.75:0.12947:45.75;
psdplot=abs(psd);
autoplot(f, psdplot, "Frequency", "PSD",...
        "Power Spectral Density of Polar NRZ", 'auto', 'auto');
% Statistical Mean
figure
smplot=smNRZ(1:1:700);
autoplot(t, smplot, "Time", "Statistical Mean",...
        "Statistical Mean of Polar NRZ", 'auto', [-4 4]);
% Time Mean
figure
autoplot(sampleno, tmNRZ, "Waveform No.", "Time Mean",...
        "Time Mean of Polar NRZ", 'auto', [-4 4]);
% Statistical ACF
figure
sacfplot=sacfNRZ(1:7:700);
autoplot(taw2, sacfplot, "taw", "Ensemble Rx",...
        "Statistical ACF of Polar NRZ", 'auto', 'auto');
hold on
autoplot(-taw2, sacfplot, "taw", "Ensemble Rx",...
        "Statistical ACF of Polar NRZ", 'auto', 'auto');
%% Plotting Variables of Polar RZ
% Time Autocorrelation
figure
tacfplot=tacfRZ(1:1:700) ;
autoplot(taw, tacfplot, "taw", "Waveform Rx",...
        "Time ACF of Polar RZ", [-700 700], 'auto');
hold on
autoplot(-taw, tacfplot, "taw", "Waveform Rx",...
        "Time ACF of Polar RZ", [-700 700], 'auto');
% Power Spectral Density
figure
psd=fftshift(fft(sacfRZ)) ;
f=-44.75:0.12947:45.75 ;
psdplot=abs(psd) ;
autoplot(f, psdplot, "Frequency", "PSD",...
        "Power Spectral Density of Polar RZ", 'auto', 'auto');
% Statistical Mean
figure
smplot=smRZ(1:1:700) ;
autoplot(t, smplot, "Time", "Statistical Mean",...
        "Statistical Mean of Polar RZ", 'auto', [-4 4]);
% Time Mean
figure
autoplot(sampleno, tmRZ, "Waveform No.", "Time Mean",...
        "Time Mean of Polar RZ", 'auto', [-4 4]);
% Statistical ACF
figure
sacfplot=sacfRZ(1:7:700) ;
autoplot(taw2, sacfplot, "taw", "Ensemble Rx",...
        "Statistical ACF of Polar RZ", 'auto', 'auto');
hold on
autoplot(-taw2, sacfplot, "taw", "Ensemble Rx",...
        "Statistical ACF of Polar RZ", 'auto', 'auto');
%% Plotting Variables of UniPolar
% Time Autocorrelation
figure
tacfplot=tacfunipolar(1:1:700) ;
autoplot(taw, tacfplot, "taw", "Waveform Rx",...
        "Time ACF of UniPolar", [-700 700], 'auto');
hold on
autoplot(-taw, tacfplot, "taw", "Waveform Rx",...
        "Time ACF of UniPolar", [-700 700], 'auto');
% Power Spectral Density
figure
psd=fftshift(fft(sacfunipolar)) ;
f=-44.75:0.12947:45.75 ;
psdplot=abs(psd) ;
autoplot(f, psdplot, "Frequency", "PSD",...
        "Power Spectral Density of UniPolar", 'auto', 'auto');
% Statistical Mean
figure
smplot=smunipolar(1:1:700) ;
autoplot(t, smplot, "Time", "Statistical Mean",...
        "Statistical Mean of UniPolar", 'auto', [-4 4]);
% Time Mean
figure
autoplot(sampleno, tmunipolar, "Waveform No.", "Time Mean",...
        "Time Mean of UniPolar", 'auto', [-4 4]);
% Statistical ACF
figure
sacfplot=sacfunipolar(1:7:700) ;
autoplot(taw2, sacfplot, "taw", "Ensemble Rx",...
        "Statistical ACF of UniPolar", 'auto', 'auto');
hold on
autoplot(-taw2, sacfplot, "taw", "Ensemble Rx",...
        "Statistical ACF of UniPolar", 'auto', 'auto');
%% Plotting Functions
function bitsplot(xax, yax, xtitle, ytitle, ftitle, xrange, yrange)
figure 
stairs(xax,yax);
xlim(xrange);   
ylim(yrange);
xlabel(xtitle);
ylabel(ytitle);
title(ftitle);
end
function autoplot(xax, yax, xtitle, ytitle, ftitle, xrange, yrange)
plot(xax,yax, 'r');
xlim(xrange);   
ylim(yrange);
xlabel(xtitle);
ylabel(ytitle);
title(ftitle);
end