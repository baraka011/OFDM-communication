function [data_outI,data_outQ]=qpsk_demodulation(data_in)
data_outI = (1 - sign(real(data_in))) / 2;
data_outQ = (1 - sign(imag(data_in))) / 2;
end