function [data_outI,data_outQ]=qpsk_modulation(data_in)
Kmod=1/sqrt(2);
L = length(data_in)/2;
data_outI = zeros(1,L);
data_outQ = zeros(1,L);
for k=1:L
    data_outI(k)=Kmod * (1 - 2*data_in(2*k-1));
    data_outQ(k)=Kmod * (1 - 2*data_in(2*k));
end