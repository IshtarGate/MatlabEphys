% This function finds loads abf data
% Type "[time,data]=loadabf;" 
% to output a time column and the associated voltages
function [time,data] = loadabf()
clear all
clf
clc
[filename,path] = uigetfile('*.abf','Control Not Holding');
cd(path)
path_filename = strcat(path,filename);
d=abfload(path_filename);
data = zeros(size(d,1),size(d,3));
for i = 1:size(d,3);%condense the file
    data(:,i) = d(:,1,i);
end;

time2 = 0:1000/39999:1000;%create time column
time = [time2(:)];

for i = 1:size(data,2);%plot the sweeps
   subplot(10,5,i);
   plot(time,data(:,i));
   axis manual;
   axis([0, 1000, -80, 100]);
   hold on;
end;

%this is where load abf should end
spike_freq=zeros(50,1);
for i = 1:size(data,2);%find maxima above a value
   x = time;
   y = data(:,i);
   [ymax,imax,~,~] = extrema(y);
   a = [ymax imax];
   b = find(a(:,1)>20);
   c = a(b,2);
   spike_freq(i,1)=size(c,1);
   spike_freq(i,2)=spike_freq(i,1)*3.33;
   hold on
   subplot(10,5,i);
   plot(time(c),data(c,i),'g.');
   axis manual;
   axis([0, 1000, -80, 100]);
   hold on;
end;

save outputvar;
