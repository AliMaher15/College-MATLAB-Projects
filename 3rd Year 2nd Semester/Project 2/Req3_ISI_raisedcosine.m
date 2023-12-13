%% ISI and raised cosine
clear
%% Generation of an array consisting of 100 bits
rng(0);                         % To Control The Rand Function in MATLAB
Bits = randi([0 1],1,100);     % bits generation
V = 1;
Ts = 1;
Impulses=((2*Bits)-1)*V;        % Convert the bit stream to +1's, -1's
%% Generation of Impulse Train with sampling time Ts/5
Impulsetrain = upsample(Impulses, Ts*5);
%% filter design
fd =1;
fs =5;
R = [0 0 1 1];          % Roll-off Factor
delay = [2 8 2 8];      % Delay
for i = 1:4
   [NUM, DEN] = rcosine(fd, fs, 'sqrt', R(i), delay(i));
    Tx_Filter = filter(NUM,DEN,Impulsetrain);
    Rx_Filter = filter(NUM,DEN,Tx_Filter);
    A = eyediagram(Tx_Filter, 10);
    B = eyediagram(Rx_Filter, 10);
end