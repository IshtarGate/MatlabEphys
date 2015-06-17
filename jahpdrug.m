%% graphing defaults, reset figures
set(0,'DefaultFigureWindowStyle','docked');
set(0,'DefaultFigureCreateFcn','zoom on');
clear all
clc
close all

%% sweeps of drugs, sweeps for the phase plots (edit them here)
%for timecourse plot
%sweeps_of_drugs=[22 62 86 96];
%drug_application_notes='30nM cpd B @22, 100nM cpd B @ 62, TTX @86, wash @ 96';
%for phase plot, control vs pdrug
%control_trace_number=16;
%pdrug_trace_number=43;

%for jah_rep=1:3 %uncomment this line and below to load multiple files as one ong trace
%% This loads the file
[filename,path] = uigetfile('*.abf','.abf File','MultiSelect','on');
cd(path)
path_filename = strcat(path,filename);
%% condense the file from x,y,z to x,z
[d,si,header]=abfload(path_filename);
data = zeros(size(d,1),size(d,3));
for sweep_number = 1:size(d,3);%condense the file
    data(:,sweep_number) = d(:,1,sweep_number);
end;
%rep_data{jah_rep}={data} %uncomment these three lines for multiple files
%end
%data=[cell2mat(rep_data{1}) cell2mat(rep_data{2}) cell2mat(rep_data{3})];
%% Create the time matrix (milliseconds)
time=1:size(data,1);
time=time*si/1000;
figure(1)
plot(time,data)
h = figure(1);
set(h,'name',filename,'numbertitle','off');
%% Get Positions
% Use the Plot to collect the position of the RMP,
% depolarization, and hyperpolarization
disp('select RMP region');
rmp_calc_end_time=ginput(1);
disp('select ap region');
timeofap=ginput(2);
disp('select point of resting and max hyperpolarization');
ir_times=ginput(2);
%% Create sweep number matrix
sweep=1:size(data,2);
sweep=sweep*10/60;

%% create empty output matrix
output=NaN(size(data,2),8);
%% RMP is output col 1
rmp_calc_end_index=find(time>=rmp_calc_end_time(1,1),1);
for sweep_number=1:size(data,2)
    output(sweep_number,1)=mean(data(1:rmp_calc_end_index,sweep_number));
end
%% IR ratio (output col 2) (change in voltage during hyperpolarization)
ir1=find(time>=ir_times(1,1),1);
ir2=find(time>=ir_times(2,1),1);
for sweep_number=1:size(data,2)%output col 2 is IR ratio
    output(sweep_number,2)=data(ir2)-data(ir1,sweep_number);
end
%% AP stats
% ap max is output 3
% ap sample number is output 4
% whether or not there is an ap is output 5 (0 or 1)
% threshold sample number and amp is output 6 and 7
% maximum upstroke velocity is output 8, it's sample number 
% is in variable uvindex

% define start and end of action potential region of interest
threshold_value=10; %set the value to gate threshold
ap1=find(time>=timeofap(1,1),1);
ap2=find(time>=timeofap(2,1),1);
uvindex=NaN(size(data,2),1);
%start running through trace looking for threshold
for sweep_number=1:size(data,2)
    [ap_amp,ap_amp_index]=max(data(ap1:ap2,sweep_number));
    %output col 3 is max height of ap
    output(sweep_number,3:4)=[ap_amp,ap_amp_index+ap1];
    if output(sweep_number,3)>0
        output(sweep_number,5)=1;%output(:,4)= is the whether ther is and ap
        %find thresh
        search_width=.1/(si/1000);
        for ind=ap1:ap2;%scan sweep for threshold
            ytwo=data(ind+search_width,sweep_number);
            yone=data(ind-search_width,sweep_number);
            xtwo=(time(ind+search_width));
            xone=(time(ind-search_width));
            V_per_s=(ytwo-yone)/(xtwo-xone);
            if V_per_s>=threshold_value % if velocity >
                output(sweep_number,6:7)=...
                    [ind data(ind,sweep_number)];%indicies and slope
                %find upstroke
                upstroke_index=find(data(:,sweep_number)>=...
                    (abs(data(output(sweep_number,4),sweep_number)...
                    -data(output(sweep_number,6),sweep_number))/2+...
                    data(output(sweep_number,6),sweep_number))...
                    ,1);
                break%used to end the search for threshold once it if found
            end
        end
        %old upstroke V calculation
        %upstroke_width=.1/(si/1000);
        %ytwo=data(upstroke_index+upstroke_width,sweep_number);
        %yone=data(upstroke_index-upstroke_width,sweep_number);
        %xtwo=(time(upstroke_index+upstroke_width));
        %xone=(time(upstroke_index-upstroke_width));
        %Upstroke_V=(ytwo-yone)/(xtwo-xone);
        
        %new upstroke calc that finds max of derivative plot
        [uvmax, uvindex_temp]=...
            max(diff(data(ap1:ap2,sweep_number))/(si/1000));
        output(sweep_number,8)=uvmax;
        uvindex(sweep_number,1)=uvindex_temp+ap1;
    else
        output(sweep_number,5)=0;
    end
end
%% plot timecourse
figure(2)
clf
%compounds timepoints for drawing vertical lines
sweeps_of_drugs=[];
drug_application_notes='ignore 20-46, 30nM cpd B @46, wash @ 144, ttx @ 217, wash at 229'
%which variables to plot
subplot_matrix=[1,2,3,7,8];
titles={'RMP (mV)' 'Hyperpolarizing Response (mV)' 'AP AMP (mV)'...
    'Threshold (mV)' 'Max Upstroke Velocity (V/s)'};
for subplot_index=1:5
    subplot(5,1,subplot_index);
    plot(output(:,subplot_matrix(subplot_index)));%add or remove "time," from plotting
    title(titles(subplot_index))
    %# vertical line
    hold on
    for vert_line_index=1:size(sweeps_of_drugs,2)
        hx = graph2d.constantline(sweeps_of_drugs(vert_line_index), 'LineStyle',':', 'Color',[1 .1 .1]);
        changedependvar(hx,'x');
    end
    hold off
end
h = figure(2);
set(h,'name',strcat(filename,'_timecourse'),'numbertitle','off');

jah_box = uicontrol('style','text');
set(jah_box,'String',drug_application_notes);
set(jah_box,'Position',[1,1,600,25]);

print -dmeta
%% plot output over any sweep
for cycle_index=1:size(data,2)
    hold off
    desired_sweep=cycle_index;
    figure(3)
    plot(time,data(:,desired_sweep))
    axis([time(1) time(end) min(min(data)) max(max(data))]);
    hold on
    try
        plot(time(output(desired_sweep,4)),data(output(desired_sweep,4),desired_sweep),'ro',...
            time(output(desired_sweep,6)),data(output(desired_sweep,6),desired_sweep),'ro',...
            time(uvindex(desired_sweep)),data(uvindex(desired_sweep),desired_sweep),'ro')
    catch
        %disp(cycle_index)
    end
    h = figure(3);
    set(h,'name',strcat(filename,'_Sweep_',num2str(desired_sweep)),'numbertitle','off');
    pause(.02)
end
%% phase plot
control_trace_number=7;
pdrug_trace_number=8;
figure(4);
clf;
dy=diff(data(ap1:ap2,control_trace_number))/(si/1000);
plot(data(ap1+1:ap2,control_trace_number),dy,'k');
hold on
dy=diff(data(ap1:ap2,pdrug_trace_number))/(si/1000);
plot(data(ap1+1:ap2,pdrug_trace_number),dy,'r');
hold off
title(['Phase Plot (V/s vs. V)',' Sweep ',num2str(control_trace_number),...
    ' vs ',num2str(pdrug_trace_number)])
h = figure(4);
set(h,'name',[filename,' Phase Plot'],'numbertitle','off');
print -dmeta
%% print filename
figure(2);
disp(filename);