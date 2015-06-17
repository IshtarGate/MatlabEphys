%% this script houses experimental functions and programs
set(0,'DefaultFigureWindowStyle','docked');
set(0,'DefaultFigureCreateFcn','zoom on');
clear all
clc
close all

%% This loads the file

[filename,path] = uigetfile('*.abf','.abf File','MultiSelect','on');
cd(path)
path_filename = strcat(path,filename);
[data,si,header]=abfload(path_filename, 'sweeps','a');
d = zeros(size(data,1),size(data,3));
for loop_number = 1:size(data,3);%condense the file
    d(:,loop_number) = data(:,1,loop_number);
end;
number_of_milliseconds_in_sweep=size(d,1)*(si/1000);...
    %calculate the number of milliseconds
time = [0:number_of_milliseconds_in_sweep/(size(data,1)-1):...
    number_of_milliseconds_in_sweep]';%create time column
%%
clc
clear x
%%
x.a1=zeros(5)
x.a2=zeros(5)
x.a3=zeros(5)
%%
for i=1:3
    ['x.a' i]
end