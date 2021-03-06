% jahhippoForMfiles loads filenames from an excel sheet to determine which
% abf files in the same folder will be analyzed
% 
% the excel sheet must contain three colums
% 'Filename' 'Analyze File?' 'Protocol Number'


%% set defaults and clear old variables
jahCleanUp;

%% uigetfile

[excelFileName,path] = uigetfile('*.xlsx', 'excel files');
cd(path)
abfFilesInDirCell = JAHimportExcel(excelFileName, 1, 'a4:c400');
dirOfMatFiles=path;%[uigetdir('/home/james/Desktop','Directory of .abf files to analyze') '/'];
dirToSaveIn=dirOfMatFiles; %[uigetdir('/home/james/Desktop','Directory to save in') '/'];

% filenames=cell(size(abfFilesInDirCell,1),1);
filenames=abfFilesInDirCell(:,1);

%% Run through multiple files

%start timer
tic

%start the stopwatch
loopRunTime0=clock;

% if iscell(filenames)
filesToRunThrough=1:size(filenames,1);
numberOfFiles=size(filenames,1);

% else
% filesToRunThrough=1;
% numberOfFiles=1;
% end

oneToFifty=1:50;
columnTitles=['filename' 'RMP (mV)' '-IR' '+IR' 'Total IR'...
    'sweep of first ap' 'Rheobase (pA)' 'Threshold (mV)'...
    'Delta Threshold (mV)' 'AP Amplitude (mV)'...
    'Amp-Threshold (mV)' 'Amp-RMP (mV)' 'AP Width (ms)'...
    'Max UV (V/s)' ...
    {NaN} {NaN} {NaN} {NaN} {NaN} {NaN} num2cell(oneToFifty)];

%% emptyVars: create all the empty variables

% create empty IRtable
IRtable=NaN(numberOfFiles,50);

% create empty HyTable
HyTable=cell(numberOfFiles,22*5);
% start of points to add data 1    23    45    67
% ends at 84

% create phasePlotTable
phasePlotTable1=NaN(10000,numberOfFiles);
phasePlotTable2=NaN(10000,numberOfFiles);

% create output3
output3=cell(numberOfFiles,70);


% create variables for deep analysis
deepApAnalysisSheet = cell( numberOfFiles + 1, 5+4 );

deepApAnalysisColumnTitles = {'tempThresholdVolt' 'max2ndDerVolt'...
    'tempMaxUpStrokeIndexValue' 'tempUpStrokeAtZeroValue'};

deepApAnalysisSheet( 1, : ) = ['filename', deepApAnalysisColumnTitles, deepApAnalysisColumnTitles];



for fileNumber=1:numberOfFiles;
    
    try %if a file fails for any reason
        
        %% set the protocol to be analyzed
        protocolBeingAnalyzed=abfFilesInDirCell{fileNumber,3};
        path_filename = strcat(dirOfMatFiles,filenames{fileNumber});
        filename=filenames{fileNumber};
        
        if abfFilesInDirCell{fileNumber,2}==1;
            %%
            % tempfilename=char(filenames{fileNumber});
            % filename=tempfilename;
            % if iscell(filenames)==1
            % path_filename = strcat(dirOfMatFiles,filenames{fileNumber});
            % filename=filenames{fileNumber};
            % else
            % path_filename = strcat(dirOfMatFiles,filenames);
            % filename=filenames;
            % end
            %
            % load(path_filename);
            % filename=tempfilename;
            %% load the .abf file
            
            % [filename,path] = uigetfile('*.abf','.abf File','MultiSelect','on');
            % cd(path)
            % path_filename = strcat(path,filename);
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
                apROIindexOne=find(time>=5,1);
                apROIindexTwo=find(time>=70,1);
                irROIone=find(time>=5,1);% input resistance ROI's
                irROItwo=find(time>=45,1);
                irROIthree=find(time>=360,1);
                irROIfour=find(time>=399,1);
                IRcurrentSteps=((1:50)*10-30)/1000;
                
            elseif protocolBeingAnalyzed==1
                apROIindexOne=find(time>=60,1);
                apROIindexTwo=find(time>=420,1);
                axisSettings=[0, time(end), min_of_data, max_of_data];
                irROIone=find(time>=5,1);% input resistance ROI's
                irROItwo=find(time>=45,1);
                irROIthree=find(time>=360,1);
                irROIfour=find(time>=399,1);
                IRcurrentSteps=((1:50)*10-30)/1000;
                
            elseif protocolBeingAnalyzed==3 % I hy
                apROIindexOne=find(time>=575,1);
                apROIindexTwo=find(time>=765,1);
                axisSettings=[0, time(end), min_of_data, max_of_data];
                irROIone=find(time>=5,1);% input resistance ROI's
                irROItwo=find(time>=45,1);
                irROIthree=find(time>=480,1);
                irROIfour=find(time>=560,1);
                IRcurrentSteps=((1:50)*10-10)/1000;
                IhyROIs=[1 1000 8000 9280 20000 22001 23001 29521];
                
            elseif protocolBeingAnalyzed==4 % T hy
                apROIindexOne=find(time>=575,1);
                apROIindexTwo=find(time>=765,1);
                axisSettings=[0, time(end), min_of_data, max_of_data];
                irROIone=find(time>=5,1);% input resistance ROI's
                irROItwo=find(time>=45,1);
                irROIthree=find(time>=480,1);
                irROIfour=find(time>=560,1);
                IRcurrentSteps=((1:50)*10-10)/1000;
                IhyROIs=[1 1000 8000 9280 20000 22001 23001 29521];
                
            elseif protocolBeingAnalyzed==5 %hippo cciv
                apROIindexOne=find(time>=65,1);
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
            
            %% Plot sweeps via 10x5 graphs
            figure(1)
            clf
            if size(d,2)<=20
                numOfPlots=size(d,2);
                numOfRows=10;
                numOfColumns=2;
            else
                numOfPlots=size(d,2);
                numOfRows=10;
                numOfColumns=5;
            end
            for loopNumber = 1:numOfPlots;%plot the sweeps
                subplot(numOfRows,numOfColumns,loopNumber);
                plot(time,d(:,loopNumber));
                axis manual;
                axis(axisSettings);
                hold on;
            end
            h = figure(1);
            set(h,'name',filename,'numbertitle','off');
            %pause(1);
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
                
                % if loopNumber<2% set the area for ap counting, has to be the first sweep
                % disp('###click on either side of area to analyze');
                % [timesOfInterest, ~]=ginput(2);
                % timesOfInterestOne=find(time>=timesOfInterest(1),1);
                % timesOfInterestTwo=find(time>=timesOfInterest(2),1);
                %
                % else
                % end
                
                MPD=2;%min peak distance
                MPH=-10;%min peak height
                MPP=10;%MinPeakProminence
                dataForPeaks=sweepOfInterest(apROIindexOne:apROIindexTwo);
                timeForPeaks=time(apROIindexOne:apROIindexTwo);
                if max(sweepOfInterest(apROIindexOne:apROIindexTwo))>=MPH
                    [peaks,locs]=PeakDetUse(dataForPeaks,timeForPeaks,MPP,MPH);
                    % [peaks,locs]=findpeaks(dataForPeaks,timeForPeaks,...%% replaced findpeaks with PeakDetUse
                    % 'MinPeakDistance',MPD,...
                    % 'MinPeakHeight',MPH,...
                    % 'MinPeakProminence',MPP);
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
                % if tempRMP>=-55%||tempRMP<=-70
                % numberOfAps(1,loopNumber)=0;
                % disp('RMP is weird jaherror-03')
                % end
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
            %pause(1)
            
            %% find sweepOfFirstAp
            clear sweepOfFirstAp
            try
                sweepOfFirstAp=find(numberOfAps>=1,1);
            catch
                warning('There are no APs jaherror-02')
            end
            if protocolBeingAnalyzed==2 && max(numberOfAps)>=1% choose the sweep to analyze for evoked
                try
                    figure(1);
                    shg;
                    
                    %find max of each sweep
                    tempMaxes=NaN(1,size(d,2));
                    for i=1:size(d,2)
                        tempMaxes(i)=max(d(:,i));
                    end
                    
                    % assign best sweep to sweepOfFirstAp and display
                    [~,sweepOfFirstAp]=max(tempMaxes);
                    displayText=['Sweep ' num2str(sweepOfFirstAp) ' was chosen'];
                    disp(displayText);%input('###Choose the Sweep to Analyze - ');
                    %        pause(.5);
                    
                catch
                    % either assign sweepOfFirstAp to the first sweep that has
                    % an ap or assign it blank
                    try
                        sweepOfFirstAp=find(numberOfAps>=1,1);
                    catch
                        sweepOfFirstAp=[];
                    end
                end
            end
            %% IR calculation
            % create IRtable if there is none
            %if exist('IRtable','var')==0
            %    IRtable=NaN(numberOfFiles,50);
            %else
            %end
            
            % only run IR protocol if it's cciv and sweepOfFirstAp>5
            if isempty(sweepOfFirstAp)==0 && ismember(1, protocolBeingAnalyzed)==1 && sweepOfFirstAp>5
                try
                    figure(6);
                    clf
                    h = figure(6);
                    plotname=('IR Plot');
                    set(h,'name',plotname,'numbertitle','off');
                    hold on
                    clf
                    hold on
                    if exist('sweepOfFirstAp','var')==0 || isempty(sweepOfFirstAp)==1
                        sweepOfFirstAp=10;
                    end
                    IRstop=sweepOfFirstAp-1;
                    if sweepOfFirstAp-1<1
                        IRstop=1;
                    end
                    
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
                    % catch
                    % disp('Could not plot IR jaherror-05');
                    % negativeIR=NaN;
                    % positiveIR=NaN;
                    % totalIR=NaN;
                    % end
                    %        pause(0.5)
                    
                    % if IR calculation fails print error, make NaNs
                catch
                    IRvoltageSteps=NaN(1,1);
                    negativeIR=NaN;
                    positiveIR=NaN;
                    totalIR=NaN;
                    warning('IR could not be calculated jaherror-05');
                end
                
            else % make NaNs if IR isn't calculated
                IRvoltageSteps=NaN(1,1);
                negativeIR=NaN;
                positiveIR=NaN;
                totalIR=NaN;
            end
            %% Ihy stats: calculate var state, steady state and ADP
            % create HyTable if none exists
            %if exist('HyTable','var')==0
            %    HyTable=cell(numberOfFiles,22*5);
            %    % start of points to add data 1    23    45    67
            %    % ends at 84
            %else
            %end
            
            if sum(ismember([ 3 4], protocolBeingAnalyzed))==1
                
                
                %IhyStats = jahIhyStats(d,sweepOfFirstAp,IhyROIs);
                %IhyTable(fileNumber,1:88)=IhyStats;
                figureNumberforjahHyStats=6;
                HyStats = jahHyStats(time,d,figureNumberforjahHyStats);
                HyTable(fileNumber,1:22*5)=HyStats;
            end
            
            
            
            %% Plot First Ap
            
            %% create phasePlotTable
            %if exist('phasePlotTable1','var')==0 %make phaseplot table
            %    phasePlotTable1=NaN(10000,size(filename,2));
            %    phasePlotTable2=NaN(10000,size(filename,2));
            %else
            %end
            
            % Are there action potentials
            if exist('sweepOfFirstAp','var')==1 && isempty(sweepOfFirstAp)==0
                
                
                figure(2);
                h = figure(2);
                plotname=['sweep ' num2str(sweepOfFirstAp)];
                set(h,'name',plotname,'numbertitle','off');
                %pause(.5)
                clf
                % if max(time)<=600 %pick the sweep to analyze for evoked
                % sweep_of_first_ap=input('sweep to analyze');
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
                
                
                %% auto Ap ROI select for phaseplot
                
                
                autophase2=firstPeakIndex;
                
                %autoPhaseTimeBeforeAp = find(time>=5,1)-1;
                %apIdx(1)=autophase2-autoPhaseTimeBeforeAp;
                %apIdx(2)=autophase2+500;
                
                %if protocolBeingAnalyzed==2
                tempRMP=mean(d(1:20,sweepOfFirstAp));
                apIdx(1)=find(d(1:autophase2,sweepOfFirstAp)<tempRMP,1,'last');
                apIdx(2)=autophase2+200;
                %end
                
                hold on
                plot(time(apIdx(1)),d(apIdx(1),sweepOfFirstAp),'ko',time(apIdx(2)),d(apIdx(2),sweepOfFirstAp),'ko');
                
                %% deep phaseplot analysis
                %numberOfAps
                
                %    if exist('deepApAnalysisSheet', 'var')==0
                %        deepApAnalysisSheet = cell( numberOfFiles + 1, 5+4 );
                %
                %        deepApAnalysisColumnTitles = {'tempThresholdVolt' 'max2ndDerVolt'...
                %   'tempMaxUpStrokeIndexValue' 'tempUpStrokeAtZeroValue'};
                %
                %        deepApAnalysisSheet( 1, : ) = ['filename', deepApAnalysisColumnTitles, deepApAnalysisColumnTitles];
                %    else
                %    end
                
                % phase plot of first ap of first sweep
                if protocolBeingAnalyzed == 1 && exist('sweepOfFirstAp', 'var') == 1 ...
                        && isempty(sweepOfFirstAp) == 0 %&& loopNumber == sweepOfFirstAp
                    
                    sweepOfInterest = sweepOfFirstAp;
                    figureNumbers=[7 8];
                    apIdx(1) = apIdx(1)+find(time>=5,1);
                    [ deepApAnalysisColumnTitles, deepApAnalysis, derMat ] = ...
                        jahApAnalysis( time, d, apIdx, sweepOfInterest, si,...
                        dirToSaveIn, filename, figureNumbers );
                    
                    
                    deepApAnalysisSheet( fileNumber+1, 1:5 ) = [filename num2cell(deepApAnalysis)];
                    
                end
                
                % phase plot of first ap of last sweep
                if protocolBeingAnalyzed == 1 && numberOfAps(1,size(d,2))>=1 && loopNumber == size(d,2)
                    
                    %find middle of upstroke of first ap
                    apMiddleIndex = find(d(:,loopNumber)>=0,1);
                    
                    % find 20 milliseconds before apMiddle
                    apStartIndex = apMiddleIndex-find(time>=20,1);
                    
                    %find RMP of last sweep
                    lastRMP=mean(d(1:20,loopNumber));
                    
                    % find were current injection starts
                    apIdxLast(1) = find(...
                        diff(d(apStartIndex:apMiddleIndex,loopNumber))/(si/1000)...
                        <=1,1,'last')...
                        +apStartIndex;
                    
                    %adjust apIdxLast 2 mV higher than RMP
                    apIdxLast(1) = find(...
                        d(apIdxLast(1):apMiddleIndex,loopNumber)>=lastRMP+2,1)+apIdxLast(1);
                    
                    %find end of the ap area
                    apIdxLast(2) = apMiddleIndex+find(time>=2,1);
                    
                    sweepOfInterest = loopNumber;
                    
                    % initiate jahApAnalysis
                    figureNumbers=[9 10];
                    [ deepApAnalysisColumnTitles, deepApAnalysis, derMat ] = ...
                        jahApAnalysis( time, d, apIdxLast, sweepOfInterest, si, ...
                        dirToSaveIn, filename, figureNumbers );
                    
                    % Assign Data to deepApAnalysisSheet
                    deepApAnalysisSheet( fileNumber+1, 6:9 ) = num2cell(deepApAnalysis);
                    
                end
                
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
                % plot(d(apIdx(1)+5:apIdx(2)-5,sweepOfFirstAp),smooth(delta_delta_volt(5:end-5),10),'g');
                
                %2nd derivative
                % axis manual
                % axis([-60 65 -100 600]);
                xlabel('Voltage (mV)');
                ylabel('dV/dt (mV/ms)');
                %    pause(.5)
                %catch
                % numberOfAps=NaN(1,50);
                % numberOfAps = zeros(1,size(d,2));
                %end
                %% export phaseplot: phasePlotTable
                figure(3)
                % exportedData=[d(apIdx(1):apIdx(2)-1,sweepOfFirstAp) delta_volt];
                % filenameOfExportData=[dirToSaveIn  filename  ' phaseplot' '.txt'];
                % save(filenameOfExportData,'exportedData','-ascii','-tabs'); %,'-append'
                
                
                
                phasePlotTable1(1:size(delta_volt_mat(:,3)',2),fileNumber)=delta_volt_mat(:,3); % voltage
                phasePlotTable2(1:size(delta_volt_mat(:,2)',2),fileNumber)=delta_volt_mat(:,2); % dVoltage
                % printName=[dirToSaveIn filename ' phase plot.png'];
                % print(printName, '-dpng', '-r300'); %<-Save as PNG with 300 DPI
                %% do the actual ap stats
                rmp=mean(d(1:2000,sweepOfFirstAp));
                
                if sweepOfFirstAp ==1
                    rheo=0;
                else
                    rheo=IRcurrentSteps(sweepOfFirstAp-1)*1000; %sweepOfFirstAp*10-30;
                end
                % rmp for evoked
                if protocolBeingAnalyzed==2
                    % rmp=mean(d(1:50,sweepOfFirstAp));
                    % figure(2);
                    % [ xtemp, ytemp]=ginput(2);
                    % evokedDuration=xtemp(2)-xtemp(1);
                    evokedDuration=...
                        time(find(d(autophase2:end,sweepOfFirstAp)<tempRMP,1))...
                        -time(apIdx(1));
                    if isempty(evokedDuration)
                        evokedDuration=NaN;
                    end
                    
                    rheo=evokedDuration;
                end
                
                if sum(ismember([1 3 4 5 6 ],protocolBeingAnalyzed))>=1
                    rheo=NaN;
                end
                
                % find Ap Threshold based on smoothed dVoltage
                ap_threshold_ind=delta_volt_mat(find(smooth(delta_volt_mat(:,2))>20,1),1);
                clear ap_threshold;
                ap_threshold=(delta_volt_mat(find(smooth(delta_volt_mat(:,2))>20,1),3));
                
                %if the there is a threshold go if not, NaN it
                if isempty(ap_threshold)==0
                    % alternative way of calculating threshold
                    % [tempY, TempI]=max(delta_delta_volt(5:end-5));
                    % alt_ap_threshold_ind=delta_volt_mat(tempI+5,1);
                    
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
                    % num2cell(smooth(delta_volt))];
                    % output_plot=[{NaN} filename ; num2cell(time) num2cell(d(:,50))];
                    
                else
                    ap_threshold=NaN;
                    delta_thresholt=NaN;
                    ap_amp=NaN;
                    delta_amp=NaN;
                    delta_amp_vs_rmp=NaN;
                    ap_width=NaN;
                    max_uv=NaN;
                    warning(['Did not do ap stats for ' filename ' jaherror-01']);
                    
                end % end of 'if isempty(ap_threshold)==0'
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
                sweepOfFirstAp=NaN;
                warning(['Did not do ap stats for ' filename ' jaherror-01']);
            end
            
            %% build output and output2
            
            
            %if protocolBeingAnalyzed==2
            %    columnTitles=['filename' 'RMP (mV)' '-IR' '+IR' 'Total IR'...
            %        'sweep of first ap' 'ADP Duration' 'Threshold (mV)'...
            %        'Delta Threshold (mV)' 'AP Amplitude (mV)'...
            %        'Amp-Threshold (mV)' 'Amp-RMP (mV)' 'AP Width (ms)'...
            %        'Max UV (V/s)' ...
            %        {NaN} {NaN} {NaN} {NaN} {NaN} {NaN} num2cell(oneToFifty)];
            %end
            
            output=[filename num2cell(rmp) ...
                num2cell(negativeIR) num2cell(positiveIR) num2cell(totalIR)...
                num2cell(sweepOfFirstAp) num2cell(rheo)...
                num2cell(ap_threshold) num2cell(delta_thresholt) ...
                num2cell(ap_amp) num2cell(delta_amp) num2cell(delta_amp_vs_rmp) ...
                num2cell(ap_width) num2cell(max_uv) ...
                {NaN} {NaN} {NaN} {NaN} {NaN} {NaN} num2cell(numberOfAps)];
            
            % output2=[columnTitles;output];
            
            %% save variables
            
            %if exist('output3','var')==0
            %    %    tempOutput3=NaN(numberOfFiles,70);
            %    output3=cell(numberOfFiles,70);%num2cell(tempOutput3);
            %else
            %end
            
            % i think this step saves the output after the output structures
            % have been determined
            output3(fileNumber,:)=output; %1:size(output,2)
            IRtable(fileNumber,1:size(IRvoltageSteps,2))=IRvoltageSteps;
            
            %% stuff to export
            %pring png of first sweep
            % figure(2)
            % printName=[dirToSaveIn filename ' sweep ' num2str(sweepOfFirstAp) '.png'];
            % print(printName, '-dpng', '-r300'); %<-Save as PNG with 300 DPI
                        
            % commandwindow
            % input('Press Enter to Advance');
            
            %     else
            %
            %oneToFifty=1:50;
            %columnTitles=['filename' 'RMP (mV)' '-IR' '+IR' 'Total IR' 'Rheobase (pA)' 'Threshold (mV)'...
            %    'Delta Threshold (mV)' 'AP Amplitude (mV)'...
            %    'Amp-Threshold (mV)' 'Amp-RMP (mV)' 'AP Width (ms)'...
            %    'Max UV (V/s)' {NaN} {NaN} num2cell(oneToFifty) cell(1,5)];
            %
            %if protocolBeingAnalyzed==2
            %    columnTitles=['filename' 'RMP (mV)' '-IR' '+IR' 'Total IR' 'ADP Duration' 'Threshold (mV)'...
            %        'Delta Threshold (mV)' 'AP Amplitude (mV)'...
            %        'Amp-Threshold (mV)' 'Amp-RMP (mV)' 'AP Width (ms)'...
            %        'Max UV (V/s)' {NaN} {NaN} num2cell(oneToFifty) cell(1,5)];
            %end
            %
            %testempty=cell(1,69);
            %output=[filename testempty];
            %output2=[columnTitles;output];
            
        end
        
        %% print message about estimated time to finish
        loopRunTime2=clock;
        timeElapsed=loopRunTime2-loopRunTime0;
        minutesTimeElapsed = timeElapsed(4)*60+timeElapsed(5)+timeElapsed(6)/60;
        if abfFilesInDirCell{fileNumber,2}==1 && fileNumber<size(abfFilesInDirCell,1)
            filesRemaining=sum(cell2mat(abfFilesInDirCell(fileNumber+1:end,2)));
            filesCompleted=sum(cell2mat(abfFilesInDirCell(1:fileNumber,2)));
            estimatedTimeToFinish = (toc/60)/filesCompleted*filesRemaining;
            averageTimePerCell = (toc/60)/filesCompleted;
            displayMessage=[ 'Minutes before completion ' num2str(estimatedTimeToFinish)...
                '(avgTimePerCell = ' num2str(averageTimePerCell) ];
            fprintf('\n');
            disp(displayMessage);
            fprintf('\n');
        end
        
       
    catch
        %% if an error occurs record which cell it was
        openvar('abfFilesInDirCellErrorSheet')
        abfFilesInDirCellErrorSheet(fileNumber,2) = num2cell(1);
        warningMessage=['Did not do analysis of' filename];
        warning(warningMessage);
        
    end
end
%% Add column titles to output3 and HyTable
output3=[columnTitles; output3];
output3=[output3 cell(size(output3,1),1)];

HyTableTitles=['rmp' cell(1,21) 'variable state' cell(1,21) ...
    'steady state' cell(1,21) 'ADP' cell(1,21) ...
    'ADP duration' cell(1,21)];
HyTable = [HyTableTitles; HyTable];

%% open all variables and export data
openvar('HyTable');
openvar('output3');
% openvar('output2');
% openvar('IRtable');
% openvar('phasePlotTable1');
% openvar('phasePlotTable2');
openvar('deepApAnalysisSheet');

tempTime=clock;

filenameOfExportData=[dirToSaveIn 'Analyzed Data ' date ' ' num2str(tempTime(4)) 'hr' num2str(tempTime(5)) 'min' '.mat'];

if exist('HyTable','var')
    save(filenameOfExportData,'output3','IRtable','phasePlotTable1','phasePlotTable2','HyTable');
else
    save(filenameOfExportData,'output3','IRtable','phasePlotTable1','phasePlotTable2');
end

% data to write to excel file
HyTableTitles=['rmp' cell(1,21) 'variable state' cell(1,21) ...
    'steady state' cell(1,21) 'ADP' cell(1,21) ...
    'ADP duration' cell(1,21)];

if exist('HyTable','var')
    excelData=[output3 HyTable];
else
    excelData=output3;
end

filenameOfExportData=[dirToSaveIn 'Analyzed Data ' date ' '...
    num2str(tempTime(4)) 'hr' num2str(tempTime(5)) 'min' '.xls'];
xlswrite(filenameOfExportData,excelData);


%% Print Done!
disp('Done!');
disp(['Please copy the variable ''' 'relevant outputs''' ' to your excel sheet.']);
fprintf(  [ '\n Run Time ' num2str(toc/60) '\n'])
beep on
for i=1:3
    beep;
    pause(.1);
end

