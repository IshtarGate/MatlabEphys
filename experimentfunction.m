%% this script houses experimental functions and programs
function [output]=experimentfunction
set(0,'DefaultFigureWindowStyle','docked');
set(0,'DefaultFigureCreateFcn','zoom on');
clear all
clc
close all
%% This loads the file

[filename,path] = uigetfile('*.abf','.abf File','MultiSelect','on');
cd(path)
path_filename = strcat(path,filename);

%% prompt to choose protocol
prompt = {'CCIV = 0, Hyper C =1, Hyper T =2 Evoked=3'};
dlg_title = 'File type';
num_lines = 1;
def = {''};
type = inputdlg(prompt,dlg_title,num_lines,def);
type=cell2mat(type);
type=str2num(type);
if type==1;
    ms=2000;
    graphend=1000;
elseif type==2
    ms=2000;
    graphend=1000;
elseif type==3;
    ms=500;
    graphend=100;
else type==0;
    ms=1000;
    graphend=1000;
end;
%%
[d,si,header]=abfload(path_filename);
data = zeros(size(d,1),size(d,3));
for i = 1:size(d,3);%condense the file
    data(:,i) = d(:,1,i);
end;
tic
%% set graphing settings
graphmin=min(min(data(:,:)))-5;
graphmax=max(max(data(:,:)))+5;
time = [0:ms/(size(data,1)-1):ms]';%create time column
sec=size(data,1)/ms;
%% display the type of analysis
disp(type)
%% Plot sweeps via a square set of graphs
figure(1)
jah_perfectsquares =[     2     2     1
    6     3     2
    12     4     3
    20     5     4
    30     6     5
    42     7     6
    56     8     7
    72     9     8
    90    10     9];

graphsize=jah_perfectsquares((find(jah_perfectsquares(:,1)>=size(data,2),1)),2:3);
for i = 1:size(data,2);%plot the sweeps
    %    subplot(graphrows,5,i);
    subplot(graphsize(1),graphsize(2),i);
    plot(time,data(:,i));
    axis manual;
    axis([0, graphend, graphmin, graphmax]);
    hold on;
end
if type==3
    prompt = {'Choose Sweep'};
    dlg_title = 'Which sweep would you like to analyze?';
    num_lines = 1;
    def = {''};
    selectedsweep = inputdlg(prompt,dlg_title,num_lines,def);
    selectedsweep=cell2mat(selectedsweep);
    selectedsweep=str2num(selectedsweep);
    data=data(:,selectedsweep);
end
h = figure(1);
set(h,'name',filename,'numbertitle','off');
%% This portion finds thresholds and spike freqency
Spike_first=0;
for s=1:size(data,2);
    clear V_per_s;
    clear V_per_s_crit;
    clear Threshold;
    if max(data(:,s))>0;%check for spike, else Spike_Freq=0
        t=1;
        Spike_RMP=mean(data(1:6*sec,s));
        for i=find(time>=5,1):find(time>=(ms-5),1);%scan sweep for threshold
            ytwo=data(i+.5*sec,s);
            yone=data(i-.5*sec,s);
            xtwo=(time(i+.5*sec));
            xone=(time(i-.5*sec));
            V_per_s=(ytwo-yone)/(xtwo-xone);
            % if velocity>20 V/s and have spike after .75 ms with voltage > 10
            if V_per_s>=20 && max(data(i:i+1.5*sec,s))>=0 && data(i,s)>Spike_RMP
                V_per_s_crit(t,1:2)=[i V_per_s];%indicies and slope
                t=t+1;
            end
        end
        %set first threshold value to first V_per_s_crit
        Threshold(1,1)=V_per_s_crit(1,1);
        t=2;
        %remove all but the first threshold per cluster on spike
        for i=2:size(V_per_s_crit,1);%if time between table entries>2
            if (time(V_per_s_crit(i,1))...
                    -time(V_per_s_crit(i-1,1)))>2
                Threshold(t,1)=V_per_s_crit(i,1);
                t=t+1;
            end
        end
        
        Spike_Freq(s,:)=size(Threshold,1);
        %check for the first spike
        if Spike_Freq(s,1)>=1
            Spike_first=Spike_first+1;
        end
        %if it is the first spike then do Membrane Properties on first spike
        if Spike_first==1
            Spike_RMP=mean(data(1:6*sec,s));
            Spike_thresh=Threshold(1,1);
            [Spike_max,Spike_maxI]=max(data(Spike_thresh:Spike_thresh+1.5*sec,s));
            Spike_maxI=Spike_maxI+Spike_thresh;
            Spike_halfmaxI=find(data(:,s)>=(data(Spike_thresh,s)+((data(Spike_maxI,s)-data(Spike_thresh,s))/2)),1);
            Spike_pasthalfmaxI=find(data(Spike_maxI:Spike_maxI+3*sec,s)<=data(Spike_halfmaxI,s),1);%%trouble
            Spike_pasthalfmaxI=Spike_pasthalfmaxI+Spike_maxI;
            Spike_width=time(Spike_pasthalfmaxI)-time(Spike_halfmaxI);
            Spike_upstrokeV=(data(Spike_halfmaxI+.05*sec,s)-data(Spike_halfmaxI-.05*sec,s))/(.1);
            %fAHP
            [dersheet]=jahderivative(s,Spike_maxI+.5*sec,Spike_maxI+sec*15,3,time,sec,data);
            Spike_mahp_start=dersheet(find(dersheet(:,3)>=-.5,1),1);
            
            if isempty(Spike_mahp_start)==0
                [Spike_fahpY,Spike_fahpI]=min(data(Spike_maxI:Spike_mahp_start,s));
                Spike_fahpI=Spike_fahpI+Spike_maxI;
            else
                Spike_fahpI=Spike_pasthalfmaxI+2*sec;
                Spike_fahpY=data(Spike_fahpI,s);
            end
            
            Spike_fahpYd=abs(data(Spike_fahpI,s)-data(Spike_thresh,s));
            
            Spike_ap_amp=Spike_max-data(Spike_thresh,s);
            if type==3
                if data(Spike_fahpI,s)>=data(Spike_thresh,s)||data(Spike_thresh,s)>-40;
                    prompt = {'What was the threshold from CCIV'};
                    dlg_title = 'fahp error';
                    num_lines = 1;
                    def = {''};
                    Spike_thresh_temp= str2num(cell2mat(inputdlg(prompt,dlg_title,num_lines,def)));
                    Spike_fahpYd=abs(data(Spike_fahpI,s)-(Spike_thresh_temp));
                    Spike_ap_amp=Spike_max-Spike_thresh_temp;
                else
                    Spike_thresh_temp=data(Spike_thresh,s);
                end
            end
            %DAP
            [Spike_dapY,Spike_dapI]=max(data(Spike_mahp_start:Spike_maxI+20*sec,s));
            Spike_dapI=Spike_dapI+Spike_mahp_start;
            Spike_dapYd=abs(data(Spike_dapI,s)-data(Spike_fahpI,s));
            if data(Spike_dapI,s)<data(Spike_fahpI,s)
                Spike_dapYd=NaN;
                %mAHP
            end
            [Spike_mahpY,Spike_mahpI]=min(data(Spike_maxI+20*sec:Spike_maxI+70*sec,s));
            Spike_mahpI=Spike_mahpI+Spike_maxI+20*sec;
            Spike_mahpYd=abs(data(Spike_mahpI,s)-data(Spike_dapI,s));
            if data(Spike_mahpI,s)>data(Spike_fahpI,s)
                Spike_mahpYd=NaN;
            elseif isempty(Spike_mahp_start)==1
                Spike_fahpYd=NaN;
                Spike_dapYd=NaN;
                Spike_fahpYd=NaN;
            end
            
            if type==3
                for i=Spike_thresh+20*sec:Spike_thresh+200*sec
                    meanwidth=5*sec;
                    delta=20*sec;
                    if mean(data(i+delta:i+meanwidth+delta,s))...
                            -mean(data(i:i+meanwidth,s))>-1.5
                        break
                    end
                end
                Spike_durationI=i;
                Spike_duration=(Spike_durationI-10*sec)/sec;
            end
            if isempty(Spike_mahpYd)==1
                Spike_mahpYd=NaN;
            end
            
            if type==3
                Spike_Sheet={'Spike Time' 'Thresh' 'AP Amp'...
                    'AP Width' 'U-V' 'fAHP' 'ADP' 'mAHP' 'Spike Freq'};
                Spike_Sheet2=[num2cell(Spike_duration)...
                    num2cell(Spike_thresh_temp)...
                    num2cell(Spike_ap_amp)...
                    num2cell(Spike_width)...
                    num2cell(Spike_upstrokeV)...
                    num2cell(Spike_fahpYd)...
                    num2cell(Spike_dapYd)...
                    num2cell(Spike_mahpYd)...
                    num2cell(Spike_Freq,s)];
                Spike_Sheet=[Spike_Sheet;Spike_Sheet2];
                clear Spike_Sheet2
            else
                Spike_Sheet={'S' 'Thresh' 'AP Amp' 'AP Width' 'U-V' 'fAHP' 'ADP' 'mAHP'};
                Spike_Sheet2=[num2cell(s)...
                    num2cell(data(Spike_thresh,s))...
                    num2cell(Spike_ap_amp)...
                    num2cell(Spike_width)...
                    num2cell(Spike_upstrokeV)...
                    num2cell(Spike_fahpYd)...
                    num2cell(Spike_dapYd)...
                    num2cell(Spike_mahpYd)];
                Spike_Sheet=[Spike_Sheet;Spike_Sheet2];
                clear Spike_Sheet2
            end
            hold on;
            subplot(graphsize(1),graphsize(2),s);
            plot(time(Threshold(:,1)), data(Threshold(:,1),s),'ro');
            if Spike_first==1
                figure(2)
                plot(time(Spike_maxI),data(Spike_maxI,s),'ro', ...
                    time(Spike_pasthalfmaxI),data(Spike_pasthalfmaxI,s),'ro', ...
                    time(Spike_halfmaxI),data(Spike_halfmaxI,s),'ro', ...
                    time(Spike_fahpI),data(Spike_fahpI,s),'ro',...
                    time(Spike_dapI),data(Spike_dapI,s),'ro',...
                    time(Spike_mahpI),data(Spike_mahpI,s),'ro',...
                    time(Threshold(:,1)), data(Threshold(:,1),s),'ro',...
                    time,data(:,s))
                if type==3
                    hold on
                    plot(time(Spike_durationI), data(Spike_durationI),'go')
                end
                axis manual;
                axis([0, graphend, graphmin, graphmax])
                h = figure(2);
                set(h,'name',strcat(filename,' sweep ',num2str(s)),'numbertitle','off');
                %         time(dersheet(:,1)),dersheet(:,3),'g')
                figure(1)
                %
                %     plot(time(Spike_maxI),data(Spike_maxI,s),'go', ...
                %         time(Spike_pasthalfmaxI),data(Spike_pasthalfmaxI,s),'go', ...
                %         time(Spike_halfmaxI),data(Spike_halfmaxI,s),'go', ...
                %         time(Spike_fahpI),data(Spike_fahpI,s),'go',...
                %         time(Spike_dapI),data(Spike_dapI,s),'go',...
                %         time(Spike_durationI), data(Spike_durationI),'ro',...
                %         time(Spike_mahpI),data(Spike_mahpI,s),'go')
            end
        end%from if there is a spike, end
        hold on;
        subplot(graphsize(1),graphsize(2),s);
        plot(time(Threshold(:,1)), data(Threshold(:,1),s),'ro');
    else
        Spike_Freq(s,1)=0;
    end
end
Spike_Freq2=Spike_Freq';
%%
%This Portion Calculates Input Resistance
%this part of the script solves for voltage deflection from
%sweep 1 to sweepbefore
sweepbefore=find(Spike_Freq(:,1)>=1,1)-1;
Input_Resistance=zeros(sweepbefore,3);%makes blank matrix
for i=1:sweepbefore;%creates input voltages
    Input_Resistance(i,1)=(10*i-30);
end;
for i=1:sweepbefore;
    Input_Resistance(i,2)=(mean(data(find(time>=300,1):find(time>=350,1),i))...
        -mean(data(find(time>=0,1):find(time>=50,1),i)));
end;
for i=1:sweepbefore;%calculates voltage/current
    Input_Resistance(i,3)=Input_Resistance(i,2)/(Input_Resistance(i,1)/1000);
end;
Input_Resistance2=Input_Resistance';
%% This portion is for hypercurrent(HyC) protocols
if type==1 || type==2
    HyC_Step=zeros(size(data,2),1);
    HyC_ADP_Amp=zeros(size(data,2),1);
    HYC_ADP_Duration=zeros(size(data,2),1);
    HyC_SteadyState=zeros(size(data,2),1);
    HyC_Vrest=zeros(size(data,2),1);
    for s=1:size(data,2)%loops through the sweeps, s
        %    if Spike_Freq(s,1)==0
        HyC_Vrest(s,1)=mean(data(find(time>=1,1):find(time>=50,1),s));%resting potential defined by the first 50 ms
        % use this to generate a table of the first derivative
        % and make the minimum only occur when the first deriviative is close
        % to zero
        %    hold off
        %    figure(2)
        clear i j a b c k der der2;
        k=1;
        %search window
        i1=70*40;
        i2=300*40;
        width=1.25;
        for i=i1:i2
            j=i-(i1-1);%start the list at one by subtracting i1 from the index
            der(j,2)=(data(i+width*40,s)-data(i-width*40,s))/ ...
                (time(i+width*40)-time(i-width*40));%first derivative
            der(j,1)=time(i);%global time
            der(j,3)=i;%global index
            der(j,4)=data(i,s);%voltage
        end
        %der2=limit list
        for i=1:size(der,1)
            if abs(der(i,2))<.05;%maximum slope allowed
                der2(k,:)=der(i,:);
                k=k+1;
            end
        end
        [y,yi]=min(der2(:,4));
        HyC_Step_Min(s,:)=[der2(yi,1),der2(yi,4)];
        HyC_Step(s,1)=HyC_Step_Min(s,2);
        %% CurrentStop
        clear x
        CurrentStop=[find(time>=120,1):find(time>=1000,1)]';% find idecies of target times
        CurrentStop=[CurrentStop time(CurrentStop) data(CurrentStop,s)...
            (data(CurrentStop+40*8,s)-data(CurrentStop-40*8,s))/(time(16*40+1)-time(1))];%slope
        CurrentStop=CurrentStop(1:find(CurrentStop(:,3)>=HyC_Vrest(s,1),1),:);
        %    CurrentStop=CurrentStop(1:end-40*sec,:);
        %     n=1;% this calculates the std
        %        for i=CurrentStop(1,1):CurrentStop(end,1)
        %         x(n,1)=std(data(i-40*5:i+40*5,s));CurrentStop(:,5)<=1 &
        %         n=n+1;
        %        end
        %     CurrentStop=[CurrentStop x];%this adds the std column
        if type==1
            HyC_slope=.075;
        elseif type==2
            HyC_slope=.5;
        end
        CurrentStopTime(s,1)=CurrentStop(find(CurrentStop(:,3)<= HyC_Vrest(s,1)-2 &...
            CurrentStop(:,4)<=HyC_slope, 1,'last'),1);
        
        %% Steady State
        HyC_SteadyState(s,1)=mean(data(CurrentStopTime(s,1) ...
            -80:CurrentStopTime(s,1)-20,s));
        [y, yi]=max(data(CurrentStopTime(s,1):find(time>=1000,1),s));
        HyC_ADP_Max(s,:)=[y yi+CurrentStopTime(s,1)];
        HyC_ADP_Amp(s,1)=abs(HyC_ADP_Max(s,1)-HyC_Vrest(s,1));
        clear y yi;
        %HyC adp start
        for i=CurrentStopTime(s,1):1000*40
            if data(i,s)>=HyC_Vrest(s,1)
                break
            end
            start(s,1)=i;
        end
        clear i
        %% End of adp
        for i=HyC_ADP_Max(s,2)+4001:80000
            width=4000;
            if ((data(i+width,s)-data(i-width,s))/ ...
                    (time(i+width,1)-time(i-width,1)))>=(-.4/4000)%4000=100ms
                break
            end
        end
        stop(s,1)=i;
        HYC_ADP_Duration(s,1)=(time(stop(s,1))-time(start(s,1)));
        hold on;
        subplot(graphsize(1),graphsize(2),s);
        plot(HyC_Step_Min(s,1),HyC_Step_Min(s,2),'bo', ...
            time(CurrentStopTime(s,1)),data(CurrentStopTime(s,1),s),'ro', ...
            time(start(s,1)), data(start(s,1),s), 'co', ...
            time(HyC_ADP_Max(s,2)),data(HyC_ADP_Max(s,2),s), 'go', ...
            time(stop(s,1)), data(stop(s,1),s),'ko');
        %    else
        %    end
    end
    HyC_Sheet={'(-)Amp' 'Steady State' 'AP' '(+)ADP AMP' 'Duration'};
    HyC_Sheet=HyC_Sheet';
    HyC_Sheet2=[num2cell(HyC_Step)...
        num2cell(HyC_SteadyState)...
        num2cell(Spike_Freq)...
        num2cell(HyC_ADP_Amp)...
        num2cell(HYC_ADP_Duration)];
    HyC_Sheet2=HyC_Sheet2';
    HyC_Sheet=[HyC_Sheet,HyC_Sheet2];
    clear HyC_Sheet2
end

commandwindow
toc
end