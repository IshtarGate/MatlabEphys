%jahder calculates the derivative of a set area based on time or index
%[DerSheet]=jahderivative(Sweep,indexstart,indexend,derivativewidth,time,sec,data)
function[DerSheet]=jahderivative(Sweep,indexstart,indexend,derivativewidth,time,sec,data)
% Sweep=17;
% indexstart=1;
% indexend=1000;
% derivativewidth=5;
derivativewidth=sec*derivativewidth;
indexstart=indexstart+derivativewidth;
indexend=indexend-derivativewidth;
DerSheet=zeros(indexend-indexstart+1,3);
DerSheet(:,1)=[indexstart:1:indexend]';
DerSheet(:,2)=time(DerSheet(:,1));
for i=indexstart:indexend
    DerSheet(i-indexstart+1,3)=(data(i+.5*derivativewidth,Sweep)...
        -data(i-.5*derivativewidth,Sweep))/(time(i+.5*derivativewidth)...
        -time(i-.5*derivativewidth));
end