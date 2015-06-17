% Note: pick channel in "%%consolidate to a single channel" and 
% uncomment "%%to subtract last trace" if you want to do thatq
%
%% this script houses experimental functions and programs
set(0,'DefaultFigureWindowStyle','docked');
set(0,'DefaultFigureCreateFcn','zoom on');
clear all
clc
close all
tic
%% This loads the file

[filename,path] = uigetfile('*.abf','.abf File','MultiSelect','on');
cd(path)
path_filename = strcat(path,filename);
[data,si,header]=abfload(path_filename, 'sweeps','a');
%% consolidate to a single channel
% channel=input('pick your channel:   '); %pick the channel
channel=1;%this is just the first channel
d = zeros(size(data,1),size(data,3));
for loopNumber = 1:size(data,3);%condense the file
    d(:,loopNumber) = data(:,channel,loopNumber);
end;
numberOfMillisecondsInSweep=size(d,1)*(si/1000);...
    %calculate the number of milliseconds
time = [0:numberOfMillisecondsInSweep/(size(data,1)-1):...
    numberOfMillisecondsInSweep]';%create time column
%% to subtract last trace
% d2=d;
% clear d;
% for i=1:size(d2,2)
%     d(:,i)=d2(:,i)-d2(:,end);
% end

%% Plot and Analyze for Max Current
figure(1)
clf
plot(time,d);
fileType=2 %input('tail current=1, CaIV==2');
[tempTimes ~]=ginput(2);
plotStart=find(time>=tempTimes(1),1);
plotEnd=find(time>=tempTimes(2),1);
min_of_data=min(min(d));
max_of_data=max(max(d))+2;
plot(time(plotStart:plotEnd),d(plotStart:plotEnd,:));
axis manual;
axis([time(plotStart), time(plotEnd), min_of_data, max_of_data]);
hold on;
h = figure(1);
set(h,'name',filename,'numbertitle','off');
[tempTimes2 ~]=ginput(2);
plotStart2=find(time>=tempTimes2(1),1);
plotEnd2=find(time>=tempTimes2(2),1);
if fileType==1
    maxCurrent=min(min(d(plotStart2:plotEnd2,:)))
    output=[{filename} num2cell(maxCurrent) num2cell(NaN(1,28))]
elseif fileType==2
    maxCurrent=min(d(plotStart2:plotEnd2,:))% min of min for tail current
    output=[{filename} NaN NaN NaN NaN NaN num2cell(maxCurrent) num2cell(NaN(1,24-size(maxCurrent,2)))];
end
disp('Done!');
disp(['Please copy the variable ''' 'output''' ' to your excel sheet.']);

% beep on
% for i=1:3
%     beep
%     pause(.1)
% end

openvar('output');
%%
print('autoExample', '-dpng', '-r100');
%%
% usrchoice=input('0=no subtraction 1=subtract first 2 =subtract last')
% %%
% if usrchoice==0
%     data2=data
% elseif usrchoice==1
%     for i=1:siez
%     data2=data(:,1,i)-data(:,1,1)
% elseif usrchoice==0
%     data2=data(:,1,i)-data(:,1,end)
%     end
%     %%
%     plot
%     ginput
%     plot(time(idx1:idx2),data2(idx1:idx2))
%     disp('copy output to excel');
%     output=NaN
%     openvar('output')