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
    path_filename = strcat(path,filename);
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
    %% Plot sweeps via 10x5 graphs
    min_of_data=min(min(d));
    max_of_data=max(max(d))+2;
    
    % if size(d,2)>30
    %     end_of_loop=30;
    % else
    %     end_of_loop=size(d,2);
    % end
    for loopNumber = 1:size(d,2);%plot the sweeps
        subplot(15,4,loopNumber);
        plot(time,d(:,loopNumber));
        axis manual;
        if size(d,2)>10 %axis for evoked
            axis([0, time(end), min_of_data, max_of_data]);
        elseif size(d,2)<10
            axis([0, 100, min_of_data, max_of_data]);
        end
        hold on;
        
    end
    h = figure(1);
    set(h,'name',filename,'numbertitle','off');
    pause(.5)
    %% auto ap freq
    figure(2)
    clf
    numberOfAps=NaN(1,50);
    commandwindow
    for loopNumber = 1:size(d,2);%plot the sweeps
        sweepOfInterest=d(:,loopNumber);
        plot(time,sweepOfInterest);
        axis manual;
        if size(d,2)>10
            axis([0, time(end), min_of_data, max_of_data]);
        elseif size(d,2)<10%axis for evoked
            axis([0, 100, min_of_data, max_of_data]);
        end
        
        if loopNumber<2% set the area for ap counting, has to be the first sweep
            disp('###click on either side of area to analyze');
            [timesOfInterest, ~]=ginput(2);
            timesOfInterestOne=find(time>=timesOfInterest(1),1);
            timesOfInterestTwo=find(time>=timesOfInterest(2),1);
        else
        end
        MPD=2;%mean peak distance
        MPH=-10;%mean peak height
        MPP=7;%MinPeakProminence
        dataForPeaks=sweepOfInterest(timesOfInterestOne:timesOfInterestTwo);
        timeForPeaks=time(timesOfInterestOne:timesOfInterestTwo);
        [peaks,locs]=findpeaks(dataForPeaks,timeForPeaks,...
            'MinPeakDistance',MPD,...
            'MinPeakHeight',MPH,...
            'MinPeakProminence',MPP);
        hold on
        plot(locs,peaks,'ro');
        hold off
        isItEmpty=isempty(peaks);
        if isItEmpty>0
            numberOfAps(1,loopNumber)=0;
        elseif isItEmpty<1
            numberOfAps(1,loopNumber)=size(peaks,1);
        end
        pause(.1)
    end
    shg
    %% egfreq plot
    figure(4);
    clf
    h = figure(4);
    plotname=('freq plot');
    set(h,'name',plotname,'numbertitle','off');
    plot(1:size(d,2),numberOfAps(1:size(d,2)));
    xlabel('Sweep');
    ylabel('Number of Action Potentials');
    pause(1.5)
    %% for by hand ap counting
    for i=1
        % figure(2)
        % clf
        % number_of_aps=NaN(1,30);
        % commandwindow
        % for loop_number = 1:size(d,2);%plot the sweeps
        %     count=0;
        %     plot(time,d(:,loop_number));
        %     axis manual;
        %     axis([0, number_of_milliseconds_in_sweep, min_of_data, max_of_data]);
        %     number_of_aps(1,loop_number)=input('number of aps=');
        % end
        % shg
    end
    %% old automated ap counting
    for i=1
        % figure(2)
        % clf
        % number_of_aps=NaN(1,50);
        % commandwindow
        % for loop_number = 1:size(d,2);%plot the sweeps
        %     plot(time,d(:,loop_number));
        %     axis manual;
        %     axis([0, number_of_milliseconds_in_sweep, min_of_data, max_of_data]);
        %     temp_max=find(d(:,loop_number)>0);
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
    end
    %% ap stats
    if size(d,2)>10
        sweepOfFirstAp=find(numberOfAps>=1,1);
    elseif size(d,2)<10% choose the sweep to analyze for evoked
        try
            figure(1);
            shg;
            sweepOfFirstAp=input('###Choose the Sweep to Analyze - ');
        catch
            
            sweepOfFirstAp=find(numberOfAps>=1,1);
        end
    end
    %% IR calculation
    if size(d,2)>20
        figure(6);
        clf
        h = figure(6);
        plotname=('IR Plot');
        set(h,'name',plotname,'numbertitle','off');
        hold on
        for i=1:sweepOfFirstAp
            plot(time,d(:,i));
        end
        axis([time(1),time(end),min_of_data,max_of_data]);
        
        
        
        disp('IR calculation: Pick boundaries of baseline and step measurement');
        [timesOfInterest, ~]=ginput(4);
        inda=find(time>=timesOfInterest(1),1);
        indb=find(time>=timesOfInterest(2),1);
        indc=find(time>=timesOfInterest(3),1);
        indd=find(time>=timesOfInterest(4),1);
        try
            clf
            hold on
            IRvoltageSteps=NaN(1,(sweepOfFirstAp-1));
            for irSweeps=1:sweepOfFirstAp-1
                meanA=mean(d(inda:indb,irSweeps));
                meanB=mean(d(indc:indd,irSweeps));
                IRvoltageSteps(irSweeps)=(meanB-meanA);
            end
            IRcurrentSteps=((1:sweepOfFirstAp-1)*10-30)/1000;
            plot(IRcurrentSteps,IRvoltageSteps);
            % calculate the negative IR
            tempFit=polyfit(IRcurrentSteps(1:3),IRvoltageSteps(1:3),1);
            plot(IRcurrentSteps(1:3),polyval(tempFit,IRcurrentSteps(1:3)));
            negativeIR=tempFit(1);
            % calculate the positive IR
            tempFit=polyfit(IRcurrentSteps(3:end),IRvoltageSteps(3:end),1);
            plot(IRcurrentSteps(3:end),polyval(tempFit,IRcurrentSteps(3:end)));
            positiveIR=tempFit(1);
            % calculate total IR
            tempFit=polyfit(IRcurrentSteps(1:end),IRvoltageSteps(1:end),1);
            plot(IRcurrentSteps(1:end),polyval(tempFit,IRcurrentSteps(1:end)));
            totalIR=tempFit(1);
            
            xlabel('pA');
            ylabel('mV');
        catch
            disp('***did not calculate ir***');
            negativeIR=NaN;
            positiveIR=NaN;
            totalIR=NaN;
        end
        pause(1.5)
    else
        negativeIR=NaN;
        positiveIR=NaN;
        totalIR=NaN;
    end
    
    
    %% export IR's
    % exportedData=['IRvoltageSteps'];
    % filenameOfExportData=['C:\Users\James\Desktop\tempData\' 'IR_' filename  '.txt'];
    % save(filenameOfExportData,'exportedData','-ascii','-tabs'); %,'-append'
    %% phase plot
    try
        figure(2);
        h = figure(2);
        plotname=['sweep ' num2str(sweepOfFirstAp)];
        set(h,'name',plotname,'numbertitle','off');
        pause(.5)
        clf
        % if max(time)<=600 %pick the sweep to analyze for evoked
        %     sweep_of_first_ap=input('sweep to analyze');
        % end
        plot(time,d(:,sweepOfFirstAp));
        xlabel('Time (s)');
        ylabel('Voltage (mV)');
        hold on
        plot(time,smooth(d(:,sweepOfFirstAp)),'r');
        if size(d,2)<10
            axis manual;
            axis([0, 100, min_of_data, max_of_data])
        end
        %choose ap to analyze
        disp('Click on either side of the AP you would like to analyze');
        [ap_idx,~]=ginput(2);
        %find the indexes of the ginput clicks
        for inc2=1:2
            ap_idx(inc2)=find(time>=ap_idx(inc2),1);
        end
        if d(ap_idx(1),sweepOfFirstAp)<-60
            ap_idx(1)=find(d(ap_idx(1):ap_idx(2),sweepOfFirstAp)>-60,1)+ap_idx(1);
        end
        % for evoked duration
        try
            evokedDuration=time(find(d(ap_idx(1)+100:end,sweepOfFirstAp)...
                <=d(ap_idx(1),sweepOfFirstAp),1))-time(ap_idx(1));
        catch
            evokedDuratoin=NaN;
        end
        %make the first derivative matrix
        delta_volt=diff(d(ap_idx(1):ap_idx(2),sweepOfFirstAp)/(si/1000));
        delta_volt_mat=[(ap_idx(1)+1:ap_idx(2))' ...
            delta_volt d(ap_idx(1)+1:ap_idx(2),sweepOfFirstAp)];%the matrix set up [idx dvolt volt]
        %the phase plot
        figure(3)
        h = figure(3);
        set(h,'name','phase plot','numbertitle','off');
        clf
        hold on
        plot(d(ap_idx(1):ap_idx(2)-1,sweepOfFirstAp),(delta_volt));
        plot(d(ap_idx(1):ap_idx(2)-1,sweepOfFirstAp),smooth(delta_volt),'r');
        %     axis manual
        %     axis([-60 65 -100 600]);
        xlabel('Voltage (mV)');
        ylabel('dV/dt (mV/ms)');
        pause(1)
    catch
        %     numberOfAps=NaN(1,50);
        %     numberOfAps = zeros(1,size(d,2));
    end
    %% export phaseplot
    exportedData=[d(ap_idx(1):ap_idx(2)-1,sweepOfFirstAp) delta_volt];
    filenameOfExportData=['/home/james/Desktop/tempData/' 'phaseplot_' filename  '.txt'];
    save(filenameOfExportData,'exportedData','-ascii','-tabs'); %,'-append'
    % printName=[filename ' phase plot.png'];
    % print(printName, '-dpng', '-r300'); %<-Save as PNG with 300 DPI
    
    %% do the actual ap stats
    try
        sweepOfFirstAp;
        rmp=mean(d(1:2000,sweepOfFirstAp));
        rheo=sweepOfFirstAp*10-30;
        % rmp for evoked
        if size(d,2)<10
            rmp=mean(d(1:600,sweepOfFirstAp));
            rheo=evokedDuration;
        end
        ap_threshold_ind=delta_volt_mat(find(smooth(delta_volt_mat(:,2))>20,1),1);
        ap_threshold=(delta_volt_mat(find(smooth(delta_volt_mat(:,2))>20,1),3));
        figure(2)
        plot(time(ap_threshold_ind),ap_threshold,'go') %plot the threshold on fig2
        delta_thresholt=ap_threshold-rmp;
        ap_amp=max(smooth(d(:,sweepOfFirstAp)));
        delta_amp=ap_amp-ap_threshold;
        delta_amp_vs_rmp=ap_amp-rmp;
        ap_half_max=delta_amp/2+ap_threshold;
        ap_half_max_ind=find(d(:,sweepOfFirstAp)>=ap_half_max,1);
        ap_half_max_ind2=find(d(ap_half_max_ind:ap_half_max_ind+400,sweepOfFirstAp)<=ap_half_max,1)...
            +ap_half_max_ind;
        ap_width=time(ap_half_max_ind2)-time(ap_half_max_ind);
        max_uv=max(delta_volt);%take not smooth max
        plot(time(find(d(:,sweepOfFirstAp)>=ap_amp,1)),ap_amp,'bo');
        plot(time(ap_half_max_ind),d(ap_half_max_ind,sweepOfFirstAp),'bo')%plot the ap 1/2 max on fig2
        plot(time(ap_half_max_ind2),d(ap_half_max_ind2,sweepOfFirstAp),'bo')
        
        % Create phase plot to copy to excel
        % output_phase_plot=[{NaN} filename; num2cell(d(ap_idx(1):ap_idx(2)-1,inc))...
        %     num2cell(smooth(delta_volt))];
        % output_plot=[{NaN} filename ; num2cell(time) num2cell(d(:,50))];
    catch
        rmp=NaN;
        sweepOfFirstAp=NaN;
        ap_threshold=NaN;
        delta_thresholt=NaN;
        ap_amp=NaN;
        delta_amp=NaN;
        delta_amp_vs_rmp=NaN;
        ap_width=NaN;
        max_uv=NaN;
        disp('here');
    end
    oneToFifty=1:50;
    columnTitles=['filename' 'RMP (mV)' '-IR' '+IR' 'Total IR' 'Rheobase (pA)' 'Threshold (mV)'...
        'Delta Threshold (mV)' 'AP Amplitude (mV)'...
        'Amp-Threshold (mV)' 'Amp-RMP (mV)' 'AP Width (ms)'...
        'Max UV (V/s)' {NaN} {NaN} num2cell(oneToFifty)];
    output=[filename num2cell(rmp) ...
        num2cell(negativeIR) num2cell(positiveIR) num2cell(totalIR)...
        num2cell(rheo)...
        num2cell(ap_threshold) num2cell(delta_thresholt) ...
        num2cell(ap_amp) num2cell(delta_amp) num2cell(delta_amp_vs_rmp) ...
        num2cell(ap_width) num2cell(max_uv) {NaN} {NaN} num2cell(numberOfAps)];
    
    output2=[columnTitles;output];
    %% Print Done!
    disp('Done!');
    disp(['Please copy the variable ''' 'output''' ' to your excel sheet.']);
    
    beep on
    for i=1:3
        beep
        pause(.1)
    end
    
    openvar('output2');
%% save variables
%     output3(:,fileNumber)=output;
%     IRtable(:,fileNumber)=IRvoltageSteps;