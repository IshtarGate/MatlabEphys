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
%% Plot sweeps 
min_of_data=min(min(d));
max_of_data=max(max(d));
subsetSize=ceil(sqrt(size(d,2)));
% if size(d,2)>30
%     end_of_loop=30;
% else
%     end_of_loop=size(d,2);
% end
for loop_number = 1:size(d,2);%plot the sweeps
    subplot(subsetSize,subsetSize,loop_number);
    plot(time,d(:,loop_number));
    axis manual;
    axis([0, number_of_milliseconds_in_sweep, min_of_data, max_of_data]);
    hold on;
    
end
h = figure(1);
set(h,'name',filename,'numbertitle','off');
pause(.5)
%% ap freq calculator


%for by hand counting
figure(2)
clf
number_of_aps=NaN(1,30);
commandwindow
for loop_number = 1:size(d,2);%plot the sweeps
    count=0;
    plot(time,d(:,loop_number));
    axis manual;
    axis([0, number_of_milliseconds_in_sweep, min_of_data, max_of_data]);
    number_of_aps(1,loop_number)=input('number of aps=');
end
shg

% for automatic counting
% figure(2)
% clf
% number_of_aps=NaN(1,50);
% commandwindow
% for loop_number = 1:size(d,2);%plot the sweeps
%     plot(time,d(:,loop_number));
%     axis manual;
%     axis([0, number_of_milliseconds_in_sweep, min_of_data, max_of_data]);
%     temp_max=find(d(:,loop_number)>20);
%     if max(d(:,loop_number))>=0
%         temp_ap_number=1;
%     else
%         temp_ap_number=0;
%     end
%     for temp_i=1:size(temp_max)-1
%         if temp_max(temp_i+1)-temp_max(temp_i)>5
%             temp_ap_number=temp_ap_number+1;
%         end
%     end
%     number_of_aps(1,loop_number)=temp_ap_number;
% end
% shg
%% ap stats
sweep_of_first_ap=find(number_of_aps>=1,1);
% for inc=1:size(d,2)
%     if max(d(:,inc))>-5
%         break
%     end
% end
% sweep_of_first_ap=15;
%%
%ap of interest
figure(2);
h = figure(2);
plotname=['sweep ' num2str(sweep_of_first_ap)];
set(h,'name',plotname,'numbertitle','off');
pause(.5)
clf
plot(time,d(:,sweep_of_first_ap));
hold on
plot(time,smooth(d(:,sweep_of_first_ap)),'r');
if max(time)<=600
    axis manual;
    axis([0, 100, min_of_data, max_of_data])
end
%choose ap to analyze
disp('****Click on either side of the AP you would like to analyze****');
[ap_idx,~]=ginput(2);
%find the indexes of the ginput clicks
for inc2=1:2
    ap_idx(inc2)=find(time>=ap_idx(inc2),1);
end
%make the first derivative matrix
delta_volt=diff(d(ap_idx(1):ap_idx(2),sweep_of_first_ap)/(si/1000));
delta_volt_mat=[(ap_idx(1)+1:ap_idx(2))' ...
    delta_volt d(ap_idx(1)+1:ap_idx(2),sweep_of_first_ap)];%the matrix set up [idx dvolt volt]
%the phase plot
figure(3)
h = figure(3);
set(h,'name','phase plot','numbertitle','off');
clf
hold on
plot(d(ap_idx(1):ap_idx(2)-1,sweep_of_first_ap),(delta_volt));
plot(d(ap_idx(1):ap_idx(2)-1,sweep_of_first_ap),smooth(delta_volt),'r');
pause(1.5)

%do the actual ap stats
slopeOfThreshold=10;
sweep_of_first_ap;
rmp=mean(d(1:2000,sweep_of_first_ap));
ap_threshold_ind=delta_volt_mat(find(smooth(delta_volt_mat(:,2))>slopeOfThreshold,1),1);
ap_threshold=(delta_volt_mat(find(smooth(delta_volt_mat(:,2))>slopeOfThreshold,1),3));
figure(2)
plot(time(ap_threshold_ind),ap_threshold,'go') %plot the threshold on fig2
delta_thresholt=ap_threshold-rmp;
ap_amp=max(smooth(d(:,sweep_of_first_ap)));
delta_amp=ap_amp-ap_threshold;
delta_amp_vs_rmp=ap_amp-rmp;
ap_half_max=delta_amp/2+ap_threshold;
ap_half_max_ind=find(d(:,sweep_of_first_ap)>=ap_half_max,1);
ap_half_max_ind2=find(d(ap_half_max_ind:ap_half_max_ind+400,sweep_of_first_ap)<=ap_half_max,1)...
    +ap_half_max_ind;
ap_width=time(ap_half_max_ind2)-time(ap_half_max_ind);
max_uv=max(delta_volt);%take not smooth max
plot(time(ap_half_max_ind),d(ap_half_max_ind,sweep_of_first_ap),'bo')%plot the ap 1/2 max on fig2
plot(time(ap_half_max_ind2),d(ap_half_max_ind2,sweep_of_first_ap),'bo')

% Create variable to copy to excel
% output_phase_plot=[{NaN} filename; num2cell(d(ap_idx(1):ap_idx(2)-1,inc))...
%     num2cell(smooth(delta_volt))];
% output_plot=[{NaN} filename ; num2cell(time) num2cell(d(:,50))];

output=[filename num2cell(rmp) num2cell(sweep_of_first_ap*10-20)...
    num2cell(ap_threshold) num2cell(delta_thresholt) ...
    num2cell(ap_amp) num2cell(delta_amp) num2cell(delta_amp_vs_rmp) ...
    num2cell(ap_width) num2cell(max_uv) {NaN} {NaN} num2cell(number_of_aps)];
%%

disp('***copy the variables number_of_aps and output****');