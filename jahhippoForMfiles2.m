%% set defaults and clear old variables
set(0,'DefaultFigureWindowStyle','docked');
set(0,'DefaultFigureCreateFcn','zoom on');
clear all
clc
close all
tic
%% Protocol??
commandwindow;
% protocolBeingAnalyzed=5;
protocolBeingAnalyzed=input('1=CCIV, 2=evoked, 3=Ihy 4=Thy 5=CCIVhippo 6=EPR hippo');
commandwindow;
%%

[filenames,path] = uigetfile('*.abf','.abf File','MultiSelect','on');
dirOfMatFiles=path;%[uigetdir('/home/james/Desktop','Directory of .abf files to analyze') '/'];
dirToSaveIn=dirOfMatFiles; %[uigetdir('/home/james/Desktop','Directory to save in') '/'];
cd(path)
%% Run through multiple files
if iscell(filenames)
    filesToRunThrough=1:size(filenames,2);
    numberOfFiles=size(filenames,2);
else
    filesToRunThrough=1;
    numberOfFiles=1;
end
for fileNumber=filesToRunThrough;
    %     tempfilename=char(filenames{fileNumber});
    %     filename=tempfilename;
    if iscell(filenames)==1
        path_filename = strcat(dirOfMatFiles,filenames{fileNumber});
        filename=filenames{fileNumber};
    else
        path_filename = strcat(dirOfMatFiles,filenames);
        filename=filenames;
    end
    
    %     load(path_filename);
    %     filename=tempfilename;
    %% load the .abf file
    
    %     [filename,path] = uigetfile('*.abf','.abf File','MultiSelect','on');
    %     cd(path)
    %     path_filename = strcat(path,filename);
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
    %% hardcoded items
    min_of_data=min(min(d));
    max_of_data=max(max(d))+2;
    if protocolBeingAnalyzed==2
        axisSettings=[0, 100, min_of_data, max_of_data];
    elseif protocolBeingAnalyzed==1
        apROIindexOne=find(time>=66,1);
        apROIindexTwo=find(time>=399,1);
        axisSettings=[0, time(end), min_of_data, max_of_data];
        irROIone=find(time>=5,1);% input resistance ROI's
        irROItwo=find(time>=45,1);
        irROIthree=find(time>=360,1);
        irROIfour=find(time>=399,1);
        IRcurrentSteps=((1:50)*10-30)/1000;
    elseif protocolBeingAnalyzed==5 %hippo cciv
        apROIindexOne=find(time>=66,1);
        apROIindexTwo=find(time>=399,1);
        axisSettings=[0, time(end), min_of_data, max_of_data];
        irROIone=find(time>=5,1);% input resistance ROI's
        irROItwo=find(time>=45,1);
        irROIthree=find(time>=310,1);
        irROIfour=find(time>=360,1);
        IRcurrentSteps=((1:50)*10-30)/1000;
    elseif protocolBeingAnalyzed==6 % hippo EPR
        apROIindexOne=find(time>=575,1);
        apROIindexTwo=find(time>=765,1);
        axisSettings=[0, time(end), min_of_data, max_of_data];
        irROIone=find(time>=5,1);% input resistance ROI's
        irROItwo=find(time>=45,1);
        irROIthree=find(time>=480,1);
        irROIfour=find(time>=560,1);
        IRcurrentSteps=((1:50)*10-10)/1000;
    end
    
    %% set up some variables
    
    %% Plot sweeps via 10x5 graphs
    figure(1)
    clf
    for loopNumber = 1:size(d,2);%plot the sweeps
        subplot(15,4,loopNumber);
        plot(time,d(:,loopNumber));
        axis manual;
        axis(axisSettings);
        hold on;
    end
    h = figure(1);
    set(h,'name',filename,'numbertitle','off');
    pause(1);
    %% auto ap freq
    figure(2)
    clf
    numberOfAps=NaN(1,50);
    
    %trigger for first peak
    isFirstPeak=0;
    firstPeakIndex=NaN;
    
    %commandwindow
    for loopNumber = 1:size(d,2);%plot the sweeps
        sweepOfInterest=d(:,loopNumber);
        plot(time,sweepOfInterest);
        axis manual;
        axis(axisSettings);
        
        %         if loopNumber<2% set the area for ap counting, has to be the first sweep
        %             disp('###click on either side of area to analyze');
        %             [timesOfInterest, ~]=ginput(2);
        %             timesOfInterestOne=find(time>=timesOfInterest(1),1);
        %             timesOfInterestTwo=find(time>=timesOfInterest(2),1);
        %
        %         else
        %         end
        
        MPD=2;%mean peak distance
        MPH=-10;%mean peak height
        MPP=10;%MinPeakProminence
        dataForPeaks=sweepOfInterest(apROIindexOne:apROIindexTwo);
        timeForPeaks=time(apROIindexOne:apROIindexTwo);
        if max(sweepOfInterest(apROIindexOne:apROIindexTwo))>=MPH
            [peaks,locs]=findpeaks(dataForPeaks,timeForPeaks,...
                'MinPeakDistance',MPD,...
                'MinPeakHeight',MPH,...
                'MinPeakProminence',MPP);
            hold on
            plot(locs,peaks,'ro');
            hold off
        else
            peaks=[];
            locs=[];
        end
        isItEmpty=isempty(peaks);
        if isItEmpty>0
            numberOfAps(1,loopNumber)=0;
        elseif isItEmpty<1
            numberOfAps(1,loopNumber)=size(peaks,1);
        end
        
        %clause to catch fucked up sweeps
        tempRMP=mean(d(1:2000,loopNumber));
        if tempRMP>=-55||tempRMP<=-70
            numberOfAps(1,loopNumber)=0;
        end
        %trigger for first peak
        if numberOfAps(1,loopNumber)>0
            isFirstPeak=isFirstPeak+1;
            if isFirstPeak==1
                firstPeakIndex=find(time>=locs(1),1);
            end
        end

        pause(.05)%time between plots of each sweep
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
    pause(1)
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
    %% find sweepOfFirstAp
    clear sweepOfFirstAp
    try
        sweepOfFirstAp=find(numberOfAps>=1,1);
    catch
        disp('There are no APs jaherror-02')
    end
    if protocolBeingAnalyzed==2% choose the sweep to analyze for evoked
        try
            figure(1);
            shg;
            sweepOfFirstAp=input('###Choose the Sweep to Analyze - ');
        catch
            sweepOfFirstAp=find(numberOfAps>=1,1);
        end
    end
    %% IR calculation
    if exist('IRtable','var')==0
        IRtable=NaN(numberOfFiles,50);
    else
    end
    if sweepOfFirstAp>5
        if protocolBeingAnalyzed== 1 || 3 || 4 || 5 || 6
            figure(6);
            clf
            h = figure(6);
            plotname=('IR Plot');
            set(h,'name',plotname,'numbertitle','off');
            hold on
            %         for i=1:sweepOfFirstAp
            %             plot(time,d(:,i));
            %         end
            %         axis([time(1),time(end),min_of_data,max_of_data]);
            
            
            % manually pick IR ROI's
            %         disp('IR calculation: Pick boundaries of baseline and step measurement');
            %         [timesOfInterest, ~]=ginput(4);
            %         inda=find(time>=timesOfInterest(1),1);
            %         indb=find(time>=timesOfInterest(2),1);
            %         indc=find(time>=timesOfInterest(3),1);
            %         indd=find(time>=timesOfInterest(4),1);
            %         try
            clf
            hold on
            if exist('sweepOfFirstAp','var')==0 || isempty(sweepOfFirstAp)==1
                sweepOfFirstAp=10;
            end
            IRstop=sweepOfFirstAp-1;
            IRcurrentSteps=IRcurrentSteps(1:IRstop);
            IRvoltageSteps=NaN(1,IRstop);
            for irSweeps=1:IRstop
                meanA=mean(d(irROIone:irROItwo,irSweeps));
                meanB=mean(d(irROIthree:irROIfour,irSweeps));
                IRvoltageSteps(irSweeps)=(meanB-meanA);
            end
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
            %         catch
            %             disp('Could not plot IR jaherror-05');
            %             negativeIR=NaN;
            %             positiveIR=NaN;
            %             totalIR=NaN;
            %         end
            pause(0.5)
        else
            negativeIR=NaN;
            positiveIR=NaN;
            totalIR=NaN;
        end
    else
        negativeIR=NaN;
        positiveIR=NaN;
        totalIR=NaN;
    end
    %% Are there action potentials
    if exist('sweepOfFirstAp','var')==1 && isempty(sweepOfFirstAp)==0
        %% Plot First Ap
        
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
        if protocolBeingAnalyzed==2
            axis manual;
            axis([0, 100, min_of_data, max_of_data])
        end
        %% manual phaseplot ROI select
        for i=1
            %         disp('Click on either side of the AP you would like to analyze');
            %         [apIdx,~]=ginput(2);
            %         find the indexes of the ginput clicks
            %         for inc2=1:2
            %             apIdx(inc2)=find(time>=apIdx(inc2),1);
            %         end
            %         if d(apIdx(1),sweepOfFirstAp)<-60 %change ap_Idx if it's below -60mV, for evoked
            %             apIdx(1)=find(d(apIdx(1):apIdx(2),sweepOfFirstAp)>-60,1)+apIdx(1);
            %         end
            %         % for evoked duration
            %         try
            %             evokedDuration=time(find(d(apIdx(1)+100:end,sweepOfFirstAp)...
            %                 <=d(apIdx(1),sweepOfFirstAp),1))-time(apIdx(1));
            %         catch
            %             evokedDuration=NaN;
            %         end
            %
        end
        %% auto phaseplot ROI select
        %     autophase1=find(d(:,sweepOfFirstAp)>=-20,1);%find idx of ap
        %     autophasestart=autophase1;
        %     autophasestop=autophase1+500;
        %     [y,autophase2]=max(d(autophasestart:autophasestop,sweepOfFirstAp));
        %     autophase2=autophase2+autophasestart;
        autophase2=firstPeakIndex;
        %         try
        %         apIdx(1)=find(d(autophase1-500:autophase1,sweepOfFirstAp)<=-50,1,'Last');
        %         catch
        apIdx(1)=autophase2-500;
        %         end
        %
        %         try
        %         apIdx(2)=find(d(autophase1+500:autophase1,sweepOfFirstAp)<=-50,1);
        %         catch
        apIdx(2)=autophase2+500;
        %         end
        hold on
        plot(time(apIdx(1)),d(apIdx(1),sweepOfFirstAp),'ko',time(apIdx(2)),d(apIdx(2),sweepOfFirstAp),'ko');
        
        %% phaseplot
        %make the first derivative matrix
        delta_volt=diff(d(apIdx(1):apIdx(2),sweepOfFirstAp))/(si/1000) ;
        %second derivative
        delta_delta_volt=[smooth(diff(smooth(delta_volt,10)/(si/1000))); 0];
        %the matrix set up [idx dvolt volt ddvolt]
        delta_volt_mat=[(apIdx(1)+1:apIdx(2))' ...
            delta_volt...
            d(apIdx(1)+1:apIdx(2),sweepOfFirstAp)...
            delta_delta_volt];
        
        %the phase plot
        figure(3)
        h = figure(3);
        set(h,'name','phase plot','numbertitle','off');
        clf
        hold on
        plot(d(apIdx(1):apIdx(2)-1,sweepOfFirstAp),(delta_volt));
        plot(d(apIdx(1):apIdx(2)-1,sweepOfFirstAp),smooth(delta_volt),'r');
        %     plot(d(apIdx(1)+5:apIdx(2)-5,sweepOfFirstAp),smooth(delta_delta_volt(5:end-5),10),'g');
        
        %2nd derivative
        %     axis manual
        %     axis([-60 65 -100 600]);
        xlabel('Voltage (mV)');
        ylabel('dV/dt (mV/ms)');
        pause(.5)
        %catch
        %     numberOfAps=NaN(1,50);
        %     numberOfAps = zeros(1,size(d,2));
        %end
        %% export phaseplot
        figure(3)
        %     exportedData=[d(apIdx(1):apIdx(2)-1,sweepOfFirstAp) delta_volt];
        %     filenameOfExportData=[dirToSaveIn  filename  ' phaseplot' '.txt'];
        %     save(filenameOfExportData,'exportedData','-ascii','-tabs'); %,'-append'
        
        if exist('phasePlotTable1','var')==0 %make phaseplot table
            phasePlotTable1=NaN(10000,size(filename,2));
            phasePlotTable2=NaN(10000,size(filename,2));
        else
        end
        
        phasePlotTable1(1:size(delta_volt_mat(:,3)',2),fileNumber)=delta_volt_mat(:,3);
        phasePlotTable2(1:size(delta_volt_mat(:,2)',2),fileNumber)=delta_volt_mat(:,2);
        printName=[dirToSaveIn filename ' phase plot.png'];
        print(printName, '-dpng', '-r300'); %<-Save as PNG with 300 DPI
        %% do the actual ap stats
        rmp=mean(d(1:2000,sweepOfFirstAp));
        
        if sweepOfFirstAp ==1
        rheo=0;
        else
        rheo=IRcurrentSteps(sweepOfFirstAp-1)*1000; %sweepOfFirstAp*10-30;
        end
        % rmp for evoked
        if size(d,2)<10
            rmp=mean(d(1:600,sweepOfFirstAp));
            rheo=evokedDuration;
        end
        ap_threshold_ind=delta_volt_mat(find(smooth(delta_volt_mat(:,2))>20,1),1);
        clear ap_threshold;
        ap_threshold=(delta_volt_mat(find(smooth(delta_volt_mat(:,2))>20,1),3));
        %if the there is a threshold go if not, NaN it
        if isempty(ap_threshold)==0
            %         alternative way of calculating threshold
            %                 [tempY, TempI]=max(delta_delta_volt(5:end-5));
            %                 alt_ap_threshold_ind=delta_volt_mat(tempI+5,1);
            figure(2)
            plot(time(ap_threshold_ind),ap_threshold,'go') %plot the threshold on fig2
            delta_thresholt=ap_threshold-rmp;
            [ap_amp, ap_amp_idx]=max(smooth(d(:,sweepOfFirstAp)));
            delta_amp=ap_amp-ap_threshold;
            delta_amp_vs_rmp=ap_amp-rmp;
            ap_half_max=delta_amp/2+ap_threshold;
            ap_half_max_ind=find(d(:,sweepOfFirstAp)>=ap_half_max,1);
            ap_half_max_ind2=find(d(ap_half_max_ind:ap_half_max_ind+400,sweepOfFirstAp)<=ap_half_max,1)...
                +ap_half_max_ind;
            ap_width=time(ap_half_max_ind2)-time(ap_half_max_ind);
            max_uv=max(delta_volt);%take not smooth max
            plot(time(ap_amp_idx),ap_amp,'bo');%time(find(d(:,sweepOfFirstAp)>=ap_amp,1))
            plot(time(ap_half_max_ind),d(ap_half_max_ind,sweepOfFirstAp),'bo')%plot the ap 1/2 max on fig2
            plot(time(ap_half_max_ind2),d(ap_half_max_ind2,sweepOfFirstAp),'bo')
            
            % Create phase plot to copy to excel
            % output_phase_plot=[{NaN} filename; num2cell(d(ap_idx(1):ap_idx(2)-1,inc))...
            %     num2cell(smooth(delta_volt))];
            % output_plot=[{NaN} filename ; num2cell(time) num2cell(d(:,50))];
        else
            ap_threshold=NaN;
            delta_thresholt=NaN;
            ap_amp=NaN;
            delta_amp=NaN;
            delta_amp_vs_rmp=NaN;
            ap_width=NaN;
            max_uv=NaN;
            disp(['Did not do ap stats for ' filename ' jaherror-01']);
        end
    else
        rmp=mean(d(1:2000,1));
        rheo=NaN;
        ap_threshold=NaN;
        delta_thresholt=NaN;
        ap_amp=NaN;
        delta_amp=NaN;
        delta_amp_vs_rmp=NaN;
        ap_width=NaN;
        max_uv=NaN;
        disp(['Did not do ap stats for ' filename ' jaherror-01']);
    end
    %% build output and output2
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
    
    %% save variables
    if exist('output3','var')==0
        tempOutput3=NaN(numberOfFiles,65);
        output3=num2cell(tempOutput3);
    else
    end
    output3(fileNumber,:)=output;
    IRtable(fileNumber,1:size(IRvoltageSteps,2))=IRvoltageSteps;
    %% stuff to export
    %pring png of first sweep
    figure(2)
    printName=[dirToSaveIn filename ' sweep ' num2str(sweepOfFirstAp) '.png'];
    print(printName, '-dpng', '-r300'); %<-Save as PNG with 300 DPI
    %%
    %     commandwindow
    %     input('Press Enter to Advance');
end
%% open all variables and export data
openvar('output3');
openvar('output2');
openvar('IRtable');
openvar('phasePlotTable1');
openvar('phasePlotTable2');
tempTime=clock;
filenameOfExportData=[dirToSaveIn 'Analyzed Data ' date ' ' num2str(tempTime(4)) 'hr' num2str(tempTime(5)) 'min' '.mat'];
save(filenameOfExportData,'output3','IRtable','phasePlotTable1','phasePlotTable2');

%% Print Done!
disp('Done!');
disp(['Please copy the variable ''' 'relevant outputs''' ' to your excel sheet.']);

beep on
for i=1:3
    beep;
    pause(.1);
end