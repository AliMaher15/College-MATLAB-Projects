%% Noise Analysis
clear
%% Time Vectors and Other Variables
Ts = 1;                         % Sampling Time
t  = 0:Ts/5:9999.8;             % time vector for Ts/5, Dimension is 1x50000
ts = 0 : Ts : 9999;             % Time vector for Ts, Dimension is 1x10000
A = 1;                          % Value of Bit Pulse
p=[5 4 3 2 1]/sqrt(55);         % Pulse Shaping Function
hmatch = fliplr(p);             % Matched Filter
hrect = rectpuls(t,Ts*2)/2;     % UnMatched (RECT) Filter

SNR_DB = -2:5;                  % SNR vector measured in dB
Nerror_matched = zeros(1,length(SNR_DB));   % Number of Bits Predicted Wrong by Matched Filter
Nerror_rect = zeros(1,length(SNR_DB));      % Number of Bits Predicted Wrong by UnMatched (RECT) Filter
BER_matched = zeros(1,length(SNR_DB));      % BER result of Matched Filter
BER_rect = zeros(1,length(SNR_DB));         % BER result of UnMatched (RECT) Filter
Theoretical_BER = zeros(1,length(SNR_DB));  % Theoretical BER Caused by The Noise
%% Generation of an array consisting of 10000 bits
rng(0);                         % To Control The Rand Function in MATLAB
Bits = randi([0 1],1,10000);    % bits generation
Impulses=((2*Bits)-1)*A;        % Convert the bit stream to +1's, -1's
%% Generation of Impulse Train with sampling time Ts/5
Impulsetrain = upsample(Impulses, Ts*5);
%% Convolve the Pulses with the discrete pulse shaping function 
y = conv(Impulsetrain, p);      % y is y(t) transmitted signal
y = y(1,1:length(t));           % Fix The Matrix Dimension Based on Time Vector 
%% Calculate the Energy of The Transmitted Bits
Eb = 1;                         % Eb is Energy of The Transmitted Bits
%% Adding Noise to Channel while SNR varies From -2 dB to 5 dB
for i = 1:length(SNR_DB)
    rng(1);                                     % To Control The Rand Function in MATLAB
    noise = randn(size(y));                     % noise with Zero mean and unity variance
    SNR_ABS = 10^(SNR_DB(i)/10);                % Change SNR from dB to Magnitude
    No = Eb/SNR_ABS;                            % Calculate The Value of No
    noise = noise .* sqrt(No/2);                % Variance = No/2
    v = y + noise;                              % v is The Output of the Channel after adding Noise
    %% Filter The v(t) Transmitted Signal With Matched and UnMatched (RECT) Filter
    voutmatch = filter(hmatch,1,v);             % voutmatch is The Output of Matched Filter
    voutrect = filter(hrect,1,v);               % voutrect is The Output of UnMatched (RECT) Filter
    %% Sample The Output Every Ts = 1 sec
    vmatchdecision = zeros(1,length(voutmatch));        % vmatchdecision is The Output
    vmatchdecision = downsample(vmatchdecision, Ts*5);  % Bits By Matched Filter
    voutmatchsamples = zeros(1,length(vmatchdecision)); % Values of samples taken at Ts

    vrectdecision = zeros(1,length(voutrect));          % vrectdecision  is The Output 
    vrectdecision = downsample(vrectdecision, Ts*5);    % Bits By UnMatched (RECT) Filter
    voutrectsamples = zeros(1,length(vrectdecision));   % Values of samples taken at Ts
    
    % Calculate The Value of Final Bit Decision Every Symbol of The Output Signal
    for ii = 1:length(vmatchdecision)                   % for Matched Filter
        voutmatchsamples(1,ii) = voutmatch(1,ii*5);
        if voutmatchsamples(1,ii) > 0
            vmatchdecision(1,ii) = 1;
        else
            vmatchdecision(1,ii) = 0;
        end
    end
    for ii = 1:length(vrectdecision)                    % for UnMatched (RECT) Filter
        voutrectsamples(1,ii) = voutrect(1,ii*5);
        if voutrectsamples(1,ii) > 0
            vrectdecision(1,ii) = 1;
        else
            vrectdecision(1,ii) = 0;
        end
    end
    %% Calculate BER of Matched and UnMatched (RECT) Filter
    % Calculate The Number of Bits Predicted Wrong
    for jj = 1:length(Bits)
        if Bits(1,jj) ~= vmatchdecision(1,jj)
            Nerror_matched(1,i) = Nerror_matched(1,i) + 1;
        end
        if Bits(1,jj) ~= vrectdecision(1,jj)
            Nerror_rect(1,i) = Nerror_rect(1,i) + 1;
        end
    end
    %% Calculate BER of the filters and The Theoritical BER
    BER_matched(1,i) = Nerror_matched(1,i)/length(Bits);
    BER_rect(1,i) = Nerror_rect(1,i)/length(Bits);
    % erfc
    Theoretical_BER(1,i) = 0.5*erfc(sqrt(Eb/No));
end
%% All Outputs
% SNR VS BER
figure(11)
semilogy(SNR_DB,BER_matched,'m'); 
hold on;
semilogy(SNR_DB,BER_rect,'r'); 
hold on;
semilogy(SNR_DB,Theoretical_BER,'k');
xlabel('SNR (Eb/No)'); ylabel('BER');
title('SNR Vs BER');
hold off;
legend('BER of Matched Filter','BER of UnMatched (RECT) Filter ','Theoretical BER');
% Printing Values of BER
fprintf('\nBER Values\n');
fprintf(' SNR \t\t Matched Filter \t UnMatched (RECT) Filter \t   Theoretical \n');
fprintf('  %d \t\t\t %6.4f \t\t\t\t %6.4f \t\t\t\t %6.4f \n', [SNR_DB; BER_matched; BER_rect; Theoretical_BER]);
% Printing Number of Bits Predicted Wrong
fprintf('\nNumber of Mismatches\n');
fprintf(' SNR \t\t Matched Filter \t UnMatched (RECT) Filter \n');
fprintf('  %d \t\t\t %d \t\t\t\t\t %d \n', [SNR_DB; Nerror_matched; Nerror_rect]);