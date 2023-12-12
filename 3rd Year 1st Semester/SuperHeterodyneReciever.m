clear
%% Reading the audio files
file(1) = "Short_BBCArabic2.wav";       file(2) = "Short_FM9090.wav"; 
file(3) = "Short_QuranPalestine.wav";   file(4) = "Short_RussianVoice.wav"; 
file(5) = "Short_SkyNewsArabia.wav";    file(6) = "Short_WRNArabic.wav"; 
% sampling frequency is the same for all, fs = 44100
m = zeros(6,1);
for j = 1:6
    [temp, fs] = audioread(file(j));
    %combining the 2 channels
    temp = temp(:,1) + temp(:,2);
    temp = reshape(temp, 1, size(temp,1));
    if size(m,2) > size(temp,2)
        temp(size(m,2)) = 0;
    else
        m(:,size(temp,2)) = 0;
    end
    m(j,:) = temp;
end
% plot the 6 messages in frequency domain
figure(1)
row = 3; col = 2; n = 1;
for j = 1:6
    messageplot(m(j,:),fs,file(j), row, col, n);
    n = n + 1;
end
Bw = fs/2; % bandwidth of the messages
%% AM Modulator
fc = zeros(6,1);
for j = 0:5
    % carrier frequency
    fc(j+1) = 100000 + j * 50000; %max is w = 350 kHz
end
% making sure to achieve the Nyquist criteria
% least needed fs = 700 khz
factor = 18;
fs = fs*factor; %fs = 793.8 khz
m1 = interp( m(1,:), factor);     m2 = interp( m(2,:), factor); 
m3 = interp( m(3,:), factor);     m4 = interp( m(4,:), factor); 
m5 = interp( m(5,:), factor);     m6 = interp( m(6,:), factor);
m = [m1; m2; m3; m4; m5; m6];
clear m1 m2 m3 m4 m5 m6
% carrier formation
ts = 1/fs;
t = 0 : ts : factor;
length = size(t,2); %length = 14,288,401
% making the signals having the same dimensions with the carrier
m(:,length) = 0;
carrier = zeros(6,length);
for j = 1:6
    carrier(j,:) = cos(2*pi*fc(j)*t);
    % mutliplying the signals
    m(j,:) = m(j,:).*carrier(j,:);
end
% multiplexing the 6 signals
mt = m(1,:) + m(2,:) + m(3,:) + m(4,:) + m(5,:) + m(6,:);
% plot the final transmitted message in frequency domain
figure(2)
messageplot(mt,fs, 'Transmitted messages after AM', 1, 2, 1);
%% RF Stage
% since the reciever is tunable, I ask the user to pick only one message
prompt1 = "\nWhat is the Frequency of the station you want to hear?\n";
prompt2 = "(100kHz - 150kHz - 200kHz - 250kHz - 300kHz - 350kHz): ";
k = input(prompt1 + prompt2);
for j = 1 : 6
    if k*power(10,3) == fc(j)
        i = j;
        message = file(j);
    end
end
% filter design for the wanted message
F_pass1 = fc(i) - Bw;           % Edge of the passband
F_pass2 = fc(i) + Bw;           % Closing edge of the passband
RF = fdesign.bandpass('N,Fc1,Fc2',90,F_pass1,F_pass2,fs);
RF = design(RF, 'window');
mt = filter(RF, mt);
messageplot(mt,fs, 'desired message after RF stage', 1, 2, 2);
%% Mixer
wif = 25000; %wIF = 25kHZ
carrier = cos(2*pi*(fc(i) + wif)*t);
mt = mt.*carrier;
figure(3)
messageplot(mt,fs, 'after mixing with wIF', 1, 2, 1);
%% IF Stage
xIF = 2000;
%filter design for the wanted message
F_pass1 = wif - Bw;         % Edge of the passband
F_pass2 = wif + Bw;         % Closing edge of the passband
IF = fdesign.bandpass('N,Fc1,Fc2',100,F_pass1,F_pass2,fs);
IF = design(IF, 'window');
mt = filter(IF, mt);
messageplot(mt,fs, 'IF Stage', 1, 2, 2);
%% Baseband Detection
carrier = cos(2*pi*wif*t);
mt = mt.*carrier;
figure(4)
messageplot(mt,fs, 'Bb Detector Mixer', 1, 2, 1);
% design of low-pass filter
F_stop = Bw;        % Edge of the passband
LPF = fdesign.lowpass('N,Fc',100,F_stop,fs);
LPF = design(LPF,'window');
mt = filter(LPF, mt);
messageplot(mt,fs, 'LPF Stage', 1, 2, 2);
%% Output Message
% reversing the matrix of the message back to original
mt = downsample(mt,factor);
fs = fs/factor;
figure(5)
messageplot(mt, fs, message, 1, 1, 1);
audiowrite("Output "+ message, mt, fs);
%% Filter plots
% fvtool(RF)      % drawing the RF filter
% fvtool(IF)      % drawing the IF filter
% fvtool(LPF)     % drawing the LPF filter