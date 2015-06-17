% Optimization
% set up the variable that will contain the conductance, fit and error
% calculations
set(0,'DefaultFigureWindowStyle','docked');
close all
clc
mega=zeros(13,4);
mega(:,1)=-100:10:20;
mega(:,2)=...
    [0;
    -0.001757744;
    -0.002156989;
    -0.019252062;
    0.008406596;
    0.075149017;
    0.18218224;
    0.442478981;
    0.775598415;
    0.939357211;
    1.21099885;
    0.594722079;
    2.388324063];
%% begin vhalf and kd matricies
vhalf_lower=-100;
vhalf_upper=20;
vhalf_step=(vhalf_lower-vhalf_upper)/9;
vhalf_matrix=vhalf_lower:abs(vhalf_step):vhalf_upper;

kd_lower=-100;
kd_upper=20;
kd_step=(kd_lower-kd_upper)/9;
kd_matrix=kd_lower:abs(kd_step):kd_upper;
%% run error calculations and store to error matrix
sum_error=zeros(10,10);
for kd_i=1:size(kd_matrix,2)
    kd_value_now=kd_matrix(1,kd_i);
for vhalf_i=1:size(vhalf_matrix,2)
    vhalf_value_now=(vhalf_matrix(1,vhalf_i));
for i=1:size(mega,1)
    mega(i,3)=(1/(1+exp((mega(i,1)-vhalf_value_now)/kd_value_now)));
    mega(i,4)=(mega(i,2)-mega(i,3))^2;
end
sum_error(kd_i,vhalf_i)=sum(mega(:,4));% refer to kd as rows and vhalf as the columns
end
end
[r,c]=find(sum_error==min(min(sum_error)));
%% now the iterations start
variable_range=.5;%the percentage that kd or vhalf is increased or decreased each iteration
iterations=10;
fit_over_time=zeros(2,iterations);
for iteration=1:iterations

vhalf_lower=vhalf_matrix(1,c-1);
vhalf_upper=vhalf_matrix(1,c+1);
vhalf_step=(vhalf_lower-vhalf_upper)/9;
vhalf_matrix=vhalf_lower:abs(vhalf_step):vhalf_upper;

kd_lower=kd_matrix(1,r-1);
kd_upper=kd_matrix(1,r+1);
kd_step=(kd_lower-kd_upper)/9;
kd_matrix=kd_lower:abs(kd_step):kd_upper;

sum_error=zeros(10,10);
for kd_i=1:size(kd_matrix,2)
    kd_value_now=kd_matrix(1,kd_i);
for vhalf_i=1:size(vhalf_matrix,2)
    vhalf_value_now=(vhalf_matrix(1,vhalf_i));
for i=1:size(mega,1)
    mega(i,3)=(1/(1+exp((mega(i,1)-vhalf_value_now)/kd_value_now)));
    mega(i,4)=(mega(i,2)-mega(i,3))^2;
end
sum_error(kd_i,vhalf_i)=sum(mega(:,4));% refer to kd as rows and vhalf as the columns
end
end
[r,c]=find(sum_error==min(min(sum_error)));
Boltzman=[vhalf_matrix(1,c);kd_matrix(1,r)];
fit_over_time(:,iteration)=Boltzman;
end

disp('Final vhalf=');
disp(vhalf_matrix(1,c));
disp('Final Kd=');
disp(kd_matrix(1,r));

%%
figure(1)
h = figure(1);
set(h,'name',char('Fit over time'),'numbertitle','off');
plot(1:iterations,fit_over_time(1,:),1:iterations,fit_over_time(2,:))
%%
figure(2)
h = figure(2);
set(h,'name',char('Conductance'),'numbertitle','off');
for i=1:size(mega,1)
    mega(i,3)=(1/(1+exp((mega(i,1)-vhalf_matrix(1,c))/kd_matrix(1,r))));
    mega(i,4)=(mega(i,2)-mega(i,3))^2;
end
plot(mega(:,1),mega(:,3),mega(:,1),mega(:,2),'ro')

