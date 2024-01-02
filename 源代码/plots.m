close all;
j=sqrt(-1);

B=1e6;
N=64;
T=(N+1)/B;
f=1/T;
fs=4*B;
Ts=1/fs;
sample=T/Ts;
t=linspace(-T/2,T/2,sample);
st=zeros(1,length(t));
for ii=-N/2-1:N/2
    st=st+(1/sqrt(N))*exp(j*2*pi*f*ii*t);
end
figure(1)
freq=linspace(-fs/2,fs/2,length(st));
fft_y=abs(fft(st));
plot(freq*1e-6,20*log(fftshift(fft_y/max(fft_y))));
xlabel('Frequency (MHz)');
ylabel('PSD (dB)');
title('OFDM信号频谱');
grid on;axis tight;

figure(2)
st_11 = awgn(st,20,'measured');
freq=linspace(-fs/2,fs/2,length(st));
fft_y=abs(fft(st_11));
plot(freq*1e-6,20*log(fftshift(fft_y/max(fft_y))));
xlabel('Frequency (MHz)');
ylabel('PSD (dB)');
title('OFDM信号过AWGN信道后频谱');
grid on;axis tight;

figure(3)
st_11 = filter(chan,st);
freq=linspace(-fs/2,fs/2,length(st));
fft_y=abs(fft(st_11));
plot(freq*1e-6,20*log(fftshift(fft_y/max(fft_y))));
%plot(freq*1e-6,fftshift(fft_y/max(fft_y)))
xlabel('Frequency (MHz)');
ylabel('PSD (dB)');
title('OFDM信号过多径信道后频谱');
grid on;axis tight;

figure(4)
st_11 = awgn(st,20,'measured');
freq=linspace(-fs/2,fs/2,length(st));
fft_y=abs(fft(st_11));
plot(freq*1e-6,20*log(fftshift(fft_y/max(fft_y))));
%plot(freq*1e-6,fftshift(fft_y/max(fft_y)));
xlabel('Frequency (MHz)（SNR=15dB）');
ylabel('PSD (dB)');
title('均衡后OFDM信号频谱');
grid on;axis tight;
