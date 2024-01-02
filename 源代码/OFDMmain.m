%========================================
% OFDM����ϵͳ���
% �ŵ����Ʋ���ZF��������⣩����С���Զ��˷�LS
% û���漰������������ز������15kHZ��
% �ڻ������䣬û�����±�Ƶ
% �ŵ�ΪAWGN+�ྶ
%=======================================
clear all
close all
clc 
disp(' ==== OFDM  SIMULATION  START ====');
disp(' ==== OFDM  SIMULATION  START ===='); 

%% ������Ʋ���
awgn_en = 1;                                %�ŵ�ģ��ѡ��
fd =100;                                   %����������չ
sta_num = 20;                               %����ͳ�ƴ���

%% OFDM�źŲ���������OFDM�źŲ���
f_delta = 15e3;                              %���ز����
num_carriers = 128;                          %���ز���
cp_length = 16;                              %ѭ��ǰ׺����
pilot_interval  = 5;                         %���뵼Ƶ���
M = 2;                                       %ÿ�������ű���������ӦQPSK����
ce_method = 1;                               %�ŵ����Ʒ�����1����2�ֱ��ӦLS��MMSE
symbol_len = 1000;                           %ofdm������

fft_n = num_carriers;                        %fft����=���ز���
num_bit = num_carriers * symbol_len *M ;     %��Ӧ�������ݸ�������128*1000*2
pilot_bit_1 = randi([0 1], 1, 256);          %1*256ά��������Ϊ��֪��Ƶ��bits
OFDM_SNR_BER= zeros(1,31);                   %�洢ֱ�ӽ��OFDM������
OFDM_LS_SNR_BER= zeros(1,31);                %�洢�����ŵ����ƺ��OFDM������
i=1;

%% �ྶ�ŵ�
%�ŵ�����Ϊ36.101Э��ָ��
fs = (num_carriers) * f_delta;
ts = 1/ fs;
tau = [0,50,120,200,230,500,1600,2300,5000]/(10^9);
pdb = [-1.0 ,-1.0 , -1.0 , 0, 0 , 0, -3.0,-5.0,-7.0];
%chan = Rayleighchannel(ts,fd,tau,pdb);
%chan.ResetBeforeFiltering=0;

Rs = 1/ts;                 
chan = comm.RayleighChannel(...
    'SampleRate',Rs, ...
    'PathDelays',[0 1.5e-3],...
    'AveragePathGains',[0 -3], ...
    'MaximumDopplerShift',fd,...
    'PathGainsOutputPort',true);

OFDM_sigbits = sourcebits(num_bit);          %1*256000�����͵�OFDM����
[OFDMmoddata_in_temp]=qpsk_modulation(OFDM_sigbits);
%OFDMmoddata_in_temp = moddata_outI+1i*moddata_outQ;       %1*128000 �ϳɸ��ź�
OFDMmoddata_in = reshape(OFDMmoddata_in_temp,num_carriers,(length(OFDMmoddata_in_temp))/num_carriers);

%% �ӵ�Ƶ
[Insertpilot_out,count,pilot_seq] = insert_pilot_f(OFDMmoddata_in,pilot_bit_1,pilot_interval);

%% IFFT
OFDMmoddata_out = ifft(Insertpilot_out,fft_n)*sqrt(fft_n);             %OFDM����

%% ��CP
InsertCPdata_out=Insert_CP(OFDMmoddata_out,cp_length);             %144*1200

%% ����ת�������д���
Channel_data = reshape(InsertCPdata_out,1, 172800)';
%% �ϱ�Ƶ

%% �����ྶ�ŵ�
Add_Multipath_data = chan(Channel_data);
% Add_Multipath_data = filter(chan, Channel_data);

%% ����AWGN�ŵ���SNR���Ա仯
for SNR  = 0:1:30
    be1 = 0;
    be2 = 0;
    
    frm_cnt = 0;
    while (frm_cnt<sta_num)
        frm_cnt = frm_cnt + 1;
        %% �����ྶ�ŵ�
        if (awgn_en==1)
            Add_Multipath_data = Channel_data;
        elseif (fd~=0)
            Add_Multipath_data = filter(chan, Channel_data);
        end

        %Add_noise_data = awgn(Add_Multipath_data,SNR,'measured');%SNR���Ա仯
        Add_noise_data = awgn(Add_Multipath_data,SNR,'measured');%
        %% �±�Ƶ����û����ź�

        %% ȥCP
        DeleteCPdata_out=Delete_CP(Add_noise_data,cp_length);
        %% ȡ����Ƶ����H
        [Deletepilot_Data,H] = Get_pilot(DeleteCPdata_out,pilot_interval);       %HΪ��Ƶ����128*200
        %% OFDM�ź�ֱ�ӽ����û���ŵ����ƺ�Ĳ���
        OFDM_Demodulationdata_out_iter1= fft(Deletepilot_Data)/sqrt(fft_n);                   %OFDM���
        OFDMdemodulationdata_out_1 = reshape(OFDM_Demodulationdata_out_iter1,1,128000);
        [demodulationdata_outI_1,demodulationdata_outQ_1]=qpsk_demodulation(OFDMdemodulationdata_out_1);% ������ӳ��
        P2Sdata_out_1=P2SConverter(demodulationdata_outI_1,demodulationdata_outQ_1);% OFDM�źŵ�һ��ֱ�ӽ���õ���bits 

        %% �ŵ����ƣ�����LS����MMSE����
        estimation_output = Channel_estimation(ce_method,Deletepilot_Data,pilot_seq,H)  ;%
        OFDMdemodulationdata_out_2 = reshape(estimation_output,1,128000);
        [demodulationdata_outI_2,demodulationdata_outQ_2]=qpsk_demodulation(OFDMdemodulationdata_out_2);% ������ӳ��
        P2Sdata_out_2=P2SConverter(demodulationdata_outI_2,demodulationdata_outQ_2);% OFDM�źŵ�һ��ֱ�ӽ���õ���bits

        %% ������������
        be1 = be1 + length(find(P2Sdata_out_1~=OFDM_sigbits));
        be2 = be2 + length(find(P2Sdata_out_2~=OFDM_sigbits));
        ber1 = be1 / (num_bit*frm_cnt);
        ber2 = be2 / (num_bit*frm_cnt);
        if (mod(frm_cnt, 10)==0)
            fprintf('SNR=%.1f, frm_cnt=%d, ber_de=%.8f, ber_ls=%.8f\n', SNR, frm_cnt, ber1, ber2);
        end
    end
    fprintf('SNR=%.1f, frm_cnt=%d, ber_de=%.8f, ber_ls=%.8f\n', SNR, frm_cnt, ber1, ber2);
    
    %% ����������
    OFDM_SNR_BER(i) = ber1;                                    %�洢OFDM������
    OFDM_LS_SNR_BER(i) = ber2;                                 %�洢OFDM������,LS
    i=i+1;
end
%% ��ͼ
figure(1)  
SNR_1 = 0:1:30;%����ȴ�0��30dB
semilogy(SNR_1, OFDM_SNR_BER,'b-+');%
hold on
semilogy(SNR_1, OFDM_LS_SNR_BER,'r-*');%
grid on
legend('OFDMֱ�ӽ��������','����LS������������')
xlabel('SNR(dB)');
ylabel('BER');
title('��ͬ�����ʽ��������');

aa = 0;

%% ����ͼ
scatterplot(OFDMmoddata_in_temp); 
% x=-1.5:0.5:1.5;
% y=-1.5:0.5:1.5;
axis([-2 2 -2 2]);% ������ͼ
xlabel('I');
ylabel('Q');
title('�����ź�����ͼ');

scatterplot(OFDMdemodulationdata_out_1); 
% x=-1.5:0.5:1.5;
% y=-1.5:0.5:1.5;
axis([-2 2 -2 2]);% ������ͼ
xlabel('I');
ylabel('Q');
title('�����ź�����ͼ���޾��⣩');

scatterplot(OFDMdemodulationdata_out_2); 
% x=-1.5:0.5:1.5;
% y=-1.5:0.5:1.5;
axis([-2 2 -2 2]);% ������ͼ
xlabel('I');
ylabel('Q');
title('�����ź�����ͼ�������');







