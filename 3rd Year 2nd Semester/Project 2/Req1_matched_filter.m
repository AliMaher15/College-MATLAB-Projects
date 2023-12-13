%% Matched filters and correlators in noise free environment
clear
%% Time Vectors and Other Variables
Ts = 1;                         % Sampling Time
t  = 0:Ts/5:9.8;                % time vector for Ts/5, Dimension is 1x50
ts = 0:Ts:9;                    % Time vector for Ts, Dimension is 1x10
A = 1;                          % Value of Bit Pulse
p=[5 4 3 2 1]/sqrt(55);         % Pulse Shaping Function
hmatch = fliplr(p);             % Matched Filter
hrect = rectpuls(t,Ts*2)/2;     % UnMatched (RECT) Filter
%% Generation of an array consisting of 10 bits
rng(0);                         % To Control The Rand Function in MATLAB
Bits = randi([0 1],1,10);       % bits generation
Impulses=((2*Bits)-1)*A;        % Convert the bit stream to +1's, -1's
%% Generation of Impulse Train with sampling time Ts/5
Impulsetrain = upsample(Impulses, Ts*5);
%% Convolve the Pulses with the discrete pulse shaping function 
y = conv(Impulsetrain, p);      % y is y(t) transmitted signal
y = y(1,1:length(t));           % Fix The Matrix Dimension Based on Time Vector 
%% Filter The Y(t) Transmitted Signal With Matched and UnMatched (RECT) Filter
youtmatch = filter(hmatch,1,y); % youtmatch is The Output of Matched Filter
youtrect = filter(hrect,1,y);   % youtrect is The Output of UnMatched (RECT) Filter
%% Sample The Output Every Ts = 1 sec
ymatchdecision = zeros(1,length(youtmatch));        % ymatchdecision is The Output
ymatchdecision = downsample(ymatchdecision, Ts*5);  % Bits By Matched Filter
youtmatchsamples = zeros(1,length(ymatchdecision)); % Values of samples taken at Ts

yrectdecision = zeros(1,length(youtrect));          % yrectdecision  is The Output 
yrectdecision = downsample(yrectdecision, Ts*5);    % Bits By UnMatched (RECT) Filter
youtrectsamples = zeros(1,length(yrectdecision));   % Values of samples taken at Ts

% Calculate The Value of Final Bit Decision Every Symbol of The Output Signal
for i = 1:length(ymatchdecision)    % for Matched Filter
    youtmatchsamples(1,i) = youtmatch(1,i*5);
    if youtmatchsamples(1,i) > 0
        ymatchdecision(1,i) = 1;
    else
        ymatchdecision(1,i) = 0;
    end
end
for i = 1:length(yrectdecision)     % for UnMatched (RECT) Filter
    youtrectsamples(1,i) = youtrect(1,i*5);
    if youtrectsamples(1,i) > 0
        yrectdecision(1,i) = 1;
    else
        yrectdecision(1,i) = 0;
    end
end
%% Use The Correlator Filter
pextend = repmat(p,1,10);                   % Repeat Copies of The Pulse Shaping Function
youtcorr1 = y .* pextend;                   % youtcorr1 = Y(t) * P(t)
youtcorr = zeros(1,length(youtcorr1));      % youtcorr is the output after Integrate and dump
% Integrate and Dump
b = 1;
for i=1:length(youtcorr1)
    youtcorr(i)=sum(youtcorr1(b:i));
    if mod(i,5)==0
        b=b+5;
    end
end
% Sample at Ts = 1 s
ycorrdecision = zeros(1,length(youtcorr));          % ycorrdecision is The Output 
ycorrdecision = downsample(ycorrdecision, Ts*5);    % Bits By Correlator Filter
youtcorrsamples = zeros(1,length(ymatchdecision));  % Values of samples taken at Ts
for i = 1:length(ycorrdecision)
    youtcorrsamples(1,i) = youtcorr(1,i*5);
    if youtcorrsamples(1,i) > 0
        ycorrdecision(1,i) = 1;
    else
        ycorrdecision(1,i) = 0;
    end
end
%% Plotting All Outputs
% Plot the input Bits before Transforming to Polar form
figure(1)
autostairs(ts,Bits,"Bits","Time (s)","Value",[-0.5 10.5 -0.5 1.5],'k');
% Plot the Impulse Train After Sampling with Ts/5
figure(2)
autostairs(t, Impulsetrain, "Impulse train", "Time (s)", "Value", [-0.5 10.5 -1.5 1.5], 'k');
% Plot The Y(t) Transmitted Signal Vs Matched Filter
figure(3)
subplot(2,1,1)
autoplot(t,y,"Y(t) Transmitted Signal","Time (s)","Value",[-0.5 10.5 -1.5 1.5],'m');
subplot(2,1,2)
autoplot(t(:,1:length(hmatch)),hmatch,"Matched Filter","Time (s)","Value",[-0.2 1.2 -0.2 1],'m');
suptitle('Sampling at t = 0.2 s');
% Plot The Y(t) Transmitted Signal Vs unMatched (RECT) Filter
figure(4)
subplot(2,1,1)
autoplot(t,y,"Y(t) Transmitted Signal","Time (s)","Value",[-0.5 10.5 -1.5 1.5],'r');
subplot(2,1,2)
autostairs(t, hrect,"UnMatched (RECT) Filter Output","Time (s)","Value",[-0.5 1.5 -0.5 1],'r');
suptitle('Sampling at t = 0.2 s');
% Plot The Output of Matched Filter Vs unMatched (RECT) Filter at sampling = 0.2 s
figure(5)
subplot(2,1,1)
autoplot(t, youtmatch, "Matched Filter Output","Time (s)","Value",[-0.5 10.5 -1.5 1.5],'m');
subplot(2,1,2)
autoplot(t, youtrect, "UnMatched (RECT) Filter Output","Time (s)","Value",[-0.5 10.5 -1.5 1.5],'r');
suptitle('Sampling at t = 0.2 s');
% Plot The Output Bits of Matched Filter Vs unMatched (RECT) Filter at sampling = Ts
figure(6)
subplot(2,1,1)
autostairs(ts, ymatchdecision, "Matched Filter Output Bits","Time (s)","Value",[-0.5 10.5 -0.5 1.5],'m');
subplot(2,1,2)
autostairs(ts, yrectdecision, "UnMatched (RECT) Filter Output Bits","Time (s)","Value",[-0.5 10.5 -0.5 1.5],'r');
suptitle('Sampling at Ts = 1 s');
% Stem The Output Bits of Matched Filter Vs unMatched (RECT) Filter at sampling = Ts
figure(7)
subplot(2,1,1)
autostem(ts, ymatchdecision, "Matched Filter Output Bits","Time (s)","Value",[-0.5 10.5 -0.5 1.5],'m');
subplot(2,1,2)
autostem(ts, yrectdecision, "UnMatched (RECT) Filter Output Bits","Time (s)","Value",[-0.5 10.5 -0.5 1.5],'r');
suptitle('Sampling at Ts = 1 s');
% Plot The Output Signal of Matched Filter Vs unMatched (RECT) Filter at sampling = Ts
figure(8)
subplot(2,1,1)
autoplot(ts, youtmatchsamples, "Matched Filter Output Signal","Time (s)","Value",[-0.5 10.5 -1.5 1.5],'m');
subplot(2,1,2)
autoplot(ts, youtrectsamples, "UnMatched (RECT) Filter Output Signal","Time (s)","Value",[-0.5 10.5 -1.5 1.5],'r');
suptitle('Sampling at Ts = 1 s');
% Plot The Output of Matched Filter Vs Correlator Filter
figure(10)
plot(ts, youtmatchsamples,'m');
hold on;
plot(ts,youtcorrsamples,'c');
legend('Matched Filter','Correlator');
axis([-0.5 10.5 -1.5 1.5]);
title('Output of Matched Filter Vs Correlator while sampling at Ts');
xlabel('time (s)');
hold off;
% Stem The Output of Matched Filter Vs unMatched (RECT) Filter at sampling = 0.2 s
figure(11)
subplot(2,1,1)
autostem(t, youtmatch, "Matched Filter Output","Time (s)","Value",[-0.5 10.5 -1.5 1.5],'m');
subplot(2,1,2)
autostem(t, youtrect, "UnMatched (RECT) Filter Output","Time (s)","Value",[-0.5 10.5 -1.5 1.5],'r');
suptitle('Sampling at t = 0.2 s');
% Stem The Output Signal of Matched Filter Vs unMatched (RECT) Filter at sampling = Ts
figure(12)
subplot(2,1,1)
autostem(ts, youtmatchsamples, "Matched Filter Output Signal","Time (s)","Value",[-0.5 10.5 -1.5 1.5],'m');
subplot(2,1,2)
autostem(ts, youtrectsamples, "UnMatched (RECT) Filter Output Signal","Time (s)","Value",[-0.5 10.5 -1.5 1.5],'r');
suptitle('Sampling at Ts = 1 s');
% Stem The Output of Matched Filter Vs Correlator Filter
figure(13)
stem(ts, youtmatchsamples,'m');
hold on;
stem(ts,youtcorrsamples,'c');
legend('Matched Filter','Correlator');
axis([-0.5 10.5 -1.5 1.5]);
title('Output of Matched Filter Vs Correlator while sampling at Ts');
xlabel('time (s)');
hold off;
% Plot The Output of Matched Filter Vs Correlator Filter at 0.2 s
figure(14)
plot(t, youtmatch,'m');
hold on;
plot(t,youtcorr,'c');
legend('Matched Filter','Correlator');
axis([-0.5 10.5 -1.5 1.5]);
title('Output of Matched Filter Vs Correlator while sampling at 0.2 s');
xlabel('time (s)');
hold off;
% Stem The Output of Matched Filter Vs Correlator Filter at 0.2 s
figure(15)
stem(t, youtmatch,'m');
hold on;
stem(t,youtcorr,'c');
legend('Matched Filter','Correlator');
axis([-0.5 10.5 -1.5 1.5]);
title('Output of Matched Filter Vs Correlator while sampling at 0.2 s');
xlabel('time (s)');
hold off;
%% plotting functions
function autostairs(xax, yax, ftitle, xaxl, yaxl, ax, color)
stairs(xax,yax, color);
axis(ax);
ylabel(yaxl);
xlabel(xaxl);
title(ftitle);
end
function autoplot(xax, yax, ftitle, xaxl, yaxl, ax, color)
plot(xax,yax, color);
axis(ax);
ylabel(yaxl);
xlabel(xaxl);
title(ftitle);
end
function autostem(xax, yax, ftitle, xaxl, yaxl, ax, color)
stem(xax,yax, color);
axis(ax);
ylabel(yaxl);
xlabel(xaxl);
title(ftitle);
end