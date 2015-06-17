%% clean house
set(0,'DefaultFigureWindowStyle','docked');%make figures dock
set(0,'DefaultFigureCreateFcn','zoom on');%make it so you can zoom by default
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
%Plot sweeps via 10x5 graphs
min_of_data=min(min(d));
max_of_data=max(max(d));
for loop_number = 1:size(d,2);%plot the sweeps
    subplot(6,5,loop_number);
    plot(time,d(:,loop_number));
    axis manual;
    axis([0, number_of_milliseconds_in_sweep, min_of_data, max_of_data]);
    hold on;
    
end
h = figure(1);
set(h,'name',filename,'numbertitle','off');
%% i hy stats
%allocate empty matricies
output=cell(1,105);
rmp=NaN(1,20);
variable_state=NaN(1,20);
adp=NaN(1,20);
delta_variable_state=NaN(1,20);
delta_adp=NaN(1,20);

mat_size=size(d,2);
if mat_size>20
    mat_size=20;
end
%mat_size=14
for i=1:mat_size
    rmp(i)=mean(d(1:2000,i));
end
for i=1:mat_size
    variable_state(i)=min(d(:,i));
end
for i=1:mat_size
    adp(i)=max(d(:,i));
end
for i=1:mat_size
    delta_variable_state(i)=abs(variable_state(i)-rmp(i));
end
for i=1:mat_size
    delta_adp(i)=abs(adp(i)-rmp(i));
end

blank=NaN(1,1);
output=[filename num2cell(rmp) num2cell(blank) num2cell(variable_state)...
    num2cell(blank) num2cell(adp) num2cell(blank)...
    num2cell(delta_variable_state) num2cell(blank) num2cell(delta_adp)];
clear blank;
