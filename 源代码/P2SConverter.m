function data_out=P2SConverter(data_inI,data_inQ)

L=length(data_inI);
data_out=zeros(1,2*L);
for k=1:L
    data_out(2*k-1:2*k)=[data_inI(k) data_inQ(k)];
    data_out(1,2*k-1)=data_inI(k);
    data_out(1,2*k)=data_inQ(k);
end
end
