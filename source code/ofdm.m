%========================================
% Task2 OFDM
%=======================================


%% simlutaion parameter 
B = 1e6;
N0_2 = 2.07e-14;
% dB
PL = 101; 
% m/s
speed = 15 ;
fc = 2e9;
% Hz
fd = speed*fc/3e8 ;
% us
DS = 5.4;
% number of simulation times
simu_num = 20;                               

%% OFDM parameters
% num of sub carriers
N = 128;
% length of cp
N_cp = 16;
% number of symbol per bit
M = 2;
% number of OFDM symbols
OFDMsymbol_len = 1000;
% number of QPSK symbols
QPSKsymbol_len = N*OFDMsymbol_len ;
bits_in = QPSKsymbol_len*M;

%% transmitter
% create QPSK symbols

%sourcebits = randi([0 1],1,bits_in);
%QPSK_symbol = qpsk_modulation(sourcebits);

QPSK_symbol = sqrt(1/2)*randi([0 1],1,QPSKsymbol_len) + sqrt(1/2)*1i*randi([0 1],1,QPSKsymbol_len);

% serial to parllel
OFDM_convert = reshape(QPSK_symbol,N,(length(QPSK_symbol)/N));
% ifft
OFDM_symbol = ifft(OFDM_convert,N)*sqrt(N);
% add cp
OFDM_addcp = add_CP(OFDM_symbol,N_cp);
% parllel to serial 
OFDM_beforechannel = reshape(OFDM_addcp,1,[])';

%% RayleighChannel
% s = OFDM_beforechannel;
% P = [0.5 0.5];
% tau = [0 4];
%M  = 300;
Ts = 1/B;
fdTs = fd*Ts;
Rs = 1/Ts;
% [r,h] = Fading_Channel(s,tau,fdTs,P);
rayleighchan = comm.RayleighChannel(...
    'SampleRate',Rs, ...
    'PathDelays',[0 1.5e-3],...
    'AveragePathGains',[0 -3], ...
    'MaximumDopplerShift',fd,...
    'PathGainsOutputPort',true);


[chanOut,pathGains] = rayleighchan(OFDM_beforechannel);


%% AWGN
i = 1;
for SNR  = 0:1:10
    ser = 0;    
    frm_n = 0;
   
    while (frm_n < simu_num)

        frm_n = frm_n + 1;
       
        add_noise_data = awgn(chanOut,SNR,'measured');

        %% reciver 
        % remove cp
        removecp_out = remove_CP(add_noise_data,N_cp,N);

        % fft
        OFDM_fft_out = fft(removecp_out)/sqrt(N);                   
        OFDM_sym_out = reshape(OFDM_fft_out,1,[]);

        % demodulation
        [demod_I,demod_Q] = qpsk_demodulation(OFDM_sym_out); 
        sym_out = sqrt(1/2)*(demod_I + 1i*demod_Q) ;


        % ser
        ser = ser + length(find(sym_out ~= QPSK_symbol));

        ser = ser / (QPSKsymbol_len*frm_n);


    end
    
    
    % SER
    OFDM_SER(i) = ser;                                                                   
    i = i + 1;

end


%%  plot
figure(1)  
SNR = 0:1:10;
semilogy(SNR, OFDM_SER,'b-+');
hold on
grid on
xlabel('SNR(dB)');
ylabel('BER');
%title('');


