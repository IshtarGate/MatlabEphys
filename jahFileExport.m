%% set defaults and clear old variables
set(0,'DefaultFigureWindowStyle','docked');
set(0,'DefaultFigureCreateFcn','zoom on');
clear all
clc
close all
tic
%% load the .abf file

[filename,path] = uigetfile('*.abf','.abf File','MultiSelect','on');
cd(path)
for tempidx=1:size(filename,2);
%     tempfilename=char(filename(tempidx));
    path_filename = strcat(path,filename{tempidx});
    [data,si,header]=abfload(path_filename, 'sweeps','a');
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
    clf
    plot(d);
    %%
    commandwindow
    ansToQuestion=input('would you like to save this data? 1==yes 0==no')
    
    %% export IR's
    if ansToQuestion==1
        filenameOfExportData=['/home/james/Desktop/matFiles/Divina/' tempfilename '.mat'];
        save(filenameOfExportData,'time','d','path','si','header','filename');
        disp('did it');
    else
    end
end