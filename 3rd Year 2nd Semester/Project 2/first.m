% team info
%(sec:3)(BN:1)
%(sec:3)(BN:3)
%(sec:3)(BN:7)
%(sec:2)(BN:52)
%% Requirement ((1))
clc;
clear
Ts = 1;     %pulse period
%%%%%%%%%%%%%%%%%%%%%%%%% Generating the random bits %%%%%%%%%%%%%%%%%%%%%%
rng(0);
Bits = randi([0 1],1,10);     % x will represent the random bits
Bits_mapped = (2*Bits)-1;     % maping the zeros to -1's and the ones to 1's
x = upsample(Bits_mapped,5);  % Generate a signal consisting of impulses every Ts
    
%%%%%%%%%%%%%%%%%%%%%%%%%% Pulse shaping Signal %%%%%%%%%%%%%%%%%%%%%%%%%%%
p = [5 4 3 2 1]/sqrt(55);

%%%%%%%%%%%%%%%%%%%%%%  Convolving with pulse shapint to get  Y %%%%%%%%%%%
y = conv(x,p);

%%%%%%%%%%%%%%%%%%%%%%%%%%% Filter Part %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% i- Matched filter
Matched_Filter = fliplr(p);
% ii- Rect filter
Rect_Filter = [1 1 1 1 1]/sqrt(5);

%%%%%%%%%%%%%%%%%%%%%%%%%% Convolving with Filters %%%%%%%%%%%%%%%%%%%%%%%%

Matched_Filter_Out = conv(y,Matched_Filter);

Rect_Filter_Out = conv(y,Rect_Filter);

figure;
subplot(2,1,1);
plot(Matched_Filter_Out,'g');
ylabel('Matched_filetr_output');
xlabel('time');
subplot(2,1,2);
plot(Rect_Filter_Out,'r');
ylabel('Rect_filetr_output');
xlabel('time');

% sampling filetrs output every Ts %
for i=1:10
    Matched_Out_sampled(i) = Matched_Filter_Out(i*5);
    Rect_Out_sampled(i)    = Rect_Filter_Out(i*5);
end

figure;
subplot(2,1,1);
stem(Matched_Out_sampled,'g');
ylabel('Matched_filetr_output_samples');
xlabel('time');
subplot(2,1,2)
stem(Rect_Out_sampled,'r');
ylabel('Rect_filetr_output_samples');
xlabel('time');

% End of Req 1-a


%% correlator part
%%%%%%%%%%%% Correlator filter multiplies y[n] by p[2] and then integrate
y_p_product = horzcat(y,0).*repmat(p,1,11);

Tb=1;
for i=1:50
    Correlator_Out(i)=sum(y_p_product(Tb:i));
    if mod(i,5)==0 %starting a new bit (dumping)
        Tb=Tb+5;
    end
end

figure;
plot(Matched_Filter_Out,'g'); hold on;
plot(Correlator_Out,'r');
xlabel('time'); ylabel('filter Out');

for i=1:10
    Correlator_Out_Sampled(i) = Correlator_Out(i*5);
end

figure;
subplot(2,1,1);
stem(Matched_Out_sampled,'g');
ylabel('Matched_filetr_output_samples');
xlabel('time');
subplot(2,1,2)
stem(Correlator_Out_Sampled,'r');
ylabel('Correlator_output_samples');
xlabel('time');

%End of Req 1-b
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Requirement ((2))

rng(0);
Bits2 = randi([0 1],1,10000);     % x will represent the random bits
Bits2_mapped = (2*Bits2)-1;       % maping the zeros to -1's and the ones to 1's
x2 = upsample(Bits2_mapped,5);    % Generate a signal consisting of impulses every Ts
y_noisy = conv(x2,p);             % pulse shaping convolution
    
p = [5 4 3 2 1]/sqrt(55);         % pulse shaping signal
Matched_Filter = fliplr(p);       % matched filter
Rect_Filter = [1 1 1 1 1]/sqrt(5);% rect filter

for j=-2:5
    N0 = 1/db2pow(j);
    rng(1);
    n = randn(size(y_noisy))*sqrt(N0/2);
    v = y_noisy + n;
    
    v_matched_filter_out = conv(v,Matched_Filter);
    v_rect_filter_out    = conv(v,Rect_Filter);
    
    for i=1:10000
        if(v_matched_filter_out(i*5) > 0)
            v_matched_filter_out_sampled(i) = 1;
        else
            v_matched_filter_out_sampled(i) = 0;
        end
        if(v_rect_filter_out(i*5) > 0)
            v_rect_filter_out_sampled(i) = 1;
        else
            v_rect_filter_out_sampled(i) = 0;
        end
    end
 
    [num_err_matched_filter(j+3),p_err_matched_filter(j+3)] = biterr(Bits2,v_matched_filter_out_sampled);
    [num_err_rect_filter(j+3),p_err_rect_filter(j+3)]       = biterr(Bits2,v_rect_filter_out_sampled);
    
    p_err_theoritical(j+3)=0.5*erfc(sqrt(1/N0));  
end

figure('name','BER vs Eb/N0');
semilogy(-2:5,smooth(p_err_matched_filter),'g'); hold on;
semilogy(-2:5,smooth(p_err_rect_filter),'r'); hold on;
semilogy(-2:5,smooth(p_err_theoritical),'black');
xlabel('Eb/N0'); ylabel('BER');
legend('Matched Filter BER','Unmatched Filter BER','Theoritical BER');

% End of Req 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Reqirement ((3))

d = [2 8];
r = [0 1];
n=1;
for i=1:2
    for m=1:2
        [num,den] = rcosine(1,5,'sqrt',r(i),d(m));
        Tx_filtered = filter(num,den,x2(1:500));
        Rx_filtered = filter(num,den,Tx_filtered);
        eyediagram(Tx_filtered,10);
        eyediagram(Rx_filtered,10);
    end
end
