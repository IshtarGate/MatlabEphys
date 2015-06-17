%% set defaults and clear old variables
set(0,'DefaultFigureWindowStyle','docked');
set(0,'DefaultFigureCreateFcn','zoom on');
clear all
clc
close all
tic

%% load the .abf file
%%

[filenames,path] = uigetfile('*.abf','.abf File','MultiSelect','on');
dirOfMatFiles=path;%[uigetdir('/home/james/Desktop','Directory of .abf files to analyze') '/'];
dirToSaveIn=dirOfMatFiles; %[uigetdir('/home/james/Desktop','Directory to save in') '/'];
cd(path)
%% Run through multiple files
if iscell(filenames)
   filesToRunThrough=1:size(filenames,2);
else
    filesToRunThrough=1;
end
for fileNumber=filesToRunThrough;
%% consolidate to a single channel
% channel=input('pick your channel:   '); %pick the channel
channel=1;%this is just the first channel
d = zeros(size(data,1),size(data,3));
for loopNumber = 1:size(data,3);%condense the file
    d(:,loopNumber) = data(:,channel,loopNumber);
end;
number_of_milliseconds_in_sweep=size(d,1)*(si/1000);...
    %calculate the number of milliseconds
time = (0:number_of_milliseconds_in_sweep/(size(data,1)-1):...
    number_of_milliseconds_in_sweep)';%create time column

%%
figure(1)
plot(time,d)
h = figure(1);
set(h,'name',filename,'numbertitle','off');
%%
end
%%
toc
