function []=plotchannel(data,channelNumber)
% []=plotchannel(data,channelNumber)
% expidited plotting of all sweeps of one channel from and .abf file

clf
hold on
for i=1:size(data,3)
    plot(data(:,channelNumber,i))
end