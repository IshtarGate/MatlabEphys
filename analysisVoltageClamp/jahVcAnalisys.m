% jahVcAnalysis loads and plots VC files for analysis based on a
% spreadsheet
%
% protocols are labeled as follows
%   10 = beck
%   11 = resurgent
%   12 = rush
%   13 = persistent
%   14 = ramp
%   

%% set defaults and clear old variables
    try    
        addpath('C:\Users\James\Documents\Dropbox\Lab\mfiles');
    catch
    end
    
    jahCleanUp;
    
    
%% uigetfile

    % get the path of the excel file and the folder it resides in
    [excelFileName,path] = uigetfile('*.xlsx', 'excel files');
    %[textFileName,path] = uigetfile('*.txt', 'text files');
    
    % make this the default path
    cd(path)

    % change this to change the imported excel range
    abfFilesInDirCell = JAHimportExcel(excelFileName, 1, 'a4:d1000');
    %abfFilesInDirCell = jahImportTxt(textFileName);%, startRow, endRow
    
    dirOfMatFiles=path;%[uigetdir('/home/james/Desktop','Directory of .abf files to analyze') '/'];
    dirToSaveIn=dirOfMatFiles; %[uigetdir('/home/james/Desktop','Directory to save in') '/'];
    filenames=abfFilesInDirCell(:,1);% filenames=cell(size(abfFilesInDirCell,1),1);

    
%% Run through multiple files

    %start timer
    tic

    %start the stopwatch
    %loopRunTime0=clock;

    % if iscell(filenames)
    %filesToRunThrough=1:size(filenames,1);
    numberOfFiles=size(filenames,1);

    % else
    % filesToRunThrough=1;
    % numberOfFiles=1;
    % end


%% emptyVars: create all the empty variables

    % Create the column titles for output3
    oneToFifty=1:50;
    columnTitles=['filename' 'RMP (mV)' '-IR' '+IR' 'Total IR'...
        'sweep of first ap' 'Rheobase (pA)' 'Threshold (mV)'...
        'Delta Threshold (mV)' 'AP Amplitude (mV)'...
        'Amp-Threshold (mV)' 'Amp-RMP (mV)' 'AP Width (ms)'...
        'Max UV (V/s)' ...
        {NaN} {NaN} {NaN} {NaN} {NaN} {NaN} num2cell(oneToFifty)];

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
    
    vcOutput= cell( numberOfFiles + 1, 20);
    vcOutput(1,1:2)= {'filename' 'current'};
    openvar('vcOutput');
    
    abfFilesInDirCellErrorSheet=cell(numberOfFiles,2);
    abfFilesInDirCellErrorSheet(:,1) = abfFilesInDirCell(:,1);

    
for fileNumber=1:numberOfFiles;
    
    try %if a file fails for any reason
        
        %% set the protocol to be analyzed
        protocolBeingAnalyzed=abfFilesInDirCell{fileNumber,3};
        path_filename = strcat(dirOfMatFiles,filenames{fileNumber});
        filename=filenames{fileNumber};
        
        % Get the ttx filename
        if protocolBeingAnalyzed >=10
            ttxFile=[path abfFilesInDirCell{fileNumber,4}];%fileNumber
        end
        
        if protocolBeingAnalyzed == 10 || ...
               protocolBeingAnalyzed == 14
            channel = 1;
        else
            channel = 2;
        end
        
        if isequal(abfFilesInDirCell{fileNumber,2},1)% abfFilesInDirCell{fileNumber,2}==1;
            %% load abf and consolidate to a single channel
            [data,si,~]=abfload(path_filename, 'sweeps','a');
            % channel=input('pick your channel:   '); %pick the channel
            %channel=1;%this is just the first channel
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
                apROIindexTwo=find(time>=time(end),1);%find(time>=70,1);
                axisSettings=[0, time(end), min_of_data, max_of_data];
                
            elseif protocolBeingAnalyzed==1
                apROIindexOne=find(time>=60,1);
                apROIindexTwo=find(time>=420,1);
                axisSettings=[0, 500, -70, 50];
                
            elseif protocolBeingAnalyzed==3 % I hy
                apROIindexOne=find(time>=575,1);
                apROIindexTwo=find(time>=1200,1);
                axisSettings=[0, time(end), -200, 50];
                
            elseif protocolBeingAnalyzed==4 % T hy
                apROIindexOne=find(time>=100,1);
                apROIindexTwo=find(time>=800,1);
                axisSettings=[0, time(end), min_of_data, max_of_data];
                
            elseif protocolBeingAnalyzed==5 %hippo cciv
                apROIindexOne=find(time>=65,1);
                apROIindexTwo=find(time>=399,1);
                axisSettings=[0, time(end), min_of_data, max_of_data];
                
            elseif protocolBeingAnalyzed==6 % hippo EPR
                apROIindexOne=find(time>=575,1);
                apROIindexTwo=find(time>=765,1);
                axisSettings=[0, time(end), min_of_data, max_of_data];
            
            elseif protocolBeingAnalyzed==14 % ramp
                apROIindexOne=find(time>=575,1);
                %apROIindexTwo=find(time>=765,1);
                subExtremaData=d(1:apROIindexOne,:);
                min_of_data=min(min(subExtremaData))-100;
                max_of_data=max(max(subExtremaData))+100;
                axisSettings=[0, time(end), min_of_data, max_of_data];
                
            elseif protocolBeingAnalyzed==14 % ramp
%                 apROIindexOne=find(time>=575,1);
%                 apROIindexTwo=find(time>=765,1);
                axisSettings=[0, time(end), min_of_data, max_of_data];
                
            end
            
            %% Plot sweeps via 10x5 graphs
            % Get the ttx filename
            if protocolBeingAnalyzed >=10 && protocolBeingAnalyzed <30
                %% load abf and consolidate to a single channel
%                 if strcmp(ttxfile,'NaN')
%                 
%                 else
                try
                [data2,si,~]=abfload(ttxFile, 'sweeps','a');

                % channel=input('pick your channel:   '); %pick the channel
                %channel=1;%this is just the first channel
                dTtx = zeros(size(data2,1),size(data2,3));
                for loopNumber = 1:size(data2,3);%condense the file
                    dTtx(:,loopNumber) = data2(:,channel,loopNumber);
                end;
%                 end
                catch
                    dTtx=[];
                end
                            
            end
            
            %% ramp and beck
            if protocolBeingAnalyzed == 10 || protocolBeingAnalyzed == 14
                figure(1)
                clf
                hold on
                rangeEnd=find(time>=610,1);
                range=1:round(rangeEnd/1000):rangeEnd; %624 time(end)
                numPoints=max(size(range));
                voltages=linspace(-100,20,numPoints);
                
                d2=zeros(size(d,1),1);
                dTtx2=zeros(size(d,1),1);
%                 for iIndex=1:size(d,1)
%                     d2(iIndex,1)=mean(d(iIndex,:));
%                     dTtx2(iIndex,1)=mean(d(iIndex,:));
%                 end
                d2=mean(d,2)-mean(mean(d(1:65,:)));%335
                dTtx2=mean(dTtx,2)-mean(mean(dTtx(1:65,:)));
                
                dSub=d2(range)-dTtx2(range);
                for iSweep=1:size(d,2)
                    plot(voltages,d2(range),'k')
                    plot(voltages,dTtx2(range),'r')
                    plot(voltages,dSub,'c')
                    %axis(axisSettings);
                end
                 %tempOutput=[voltages' dSub d2(range) dTtx2(range)];openvar('tempOutput');
               %% 
                if 0
                %%
                traceOutput1=[time(range) dSub];
                traceOutput=traceOutput1(1:round(size(traceOutput1,1)/1000):end,:);
                openvar('traceOutput')
                end
                
                [minY, minI]=min(dSub(range));
                plot(time(minI), minY,'ro')
                drawnow;
                waitforbuttonpress;
                click=ginput(1);
                minI=find(time>=click(1),1);
                minY=dSub(minI);
                vcOutput(fileNumber+1,1:2)={filename minY};
            end
            if 1
                %pring png
                dirToSaveIn = 'C:\Users\James\Desktop\FloxProjectDataFiles\crunchFolder\toGetFileNamesTemp\';
                printName = [dirToSaveIn filename '.png'];
                print(printName, '-dpng', '-r300'); %<-Save as PNG with 300 DPI
                
            end
            
            
            %% Resurgent and Rush
            
            
            if protocolBeingAnalyzed==11 || protocolBeingAnalyzed==12
                clf
                for iSweep=1:size(d,2)
                    dSub(:,iSweep)=d(:,iSweep)-dTtx(:,iSweep);
                end
                
                for iSweep=1:size(d,2)
                    hold on
                    plot(time(),d(:,iSweep),'k')
                    plot(time(),dTtx(:,iSweep),'r')
                    plot(time(),dSub(:,iSweep),'c')
                end
                drawnow;
                pause(.1)
%                 click=ginput(1);
%                 minI=find(time>=click(1),1);
%                 ivValues=dSub(minI,:);
                ssCurrent=d(find(time>=28,1),1);
                resCurrent=d(find(time>=28,1),:);
                ivValues=resCurrent-ssCurrent;
                vcOutput(fileNumber+1,1:size(ivValues,2)+1)=[filename num2cell(ivValues)];
                
            end
            %%
            if 0
            for i=1:13
                plot(time,d(:,i))
                pause(.1)
            end
            end
            %% if protocol is Ca related
            if protocolBeingAnalyzed==30
            t1=0;
            t2=50;
            t0=find(time>=t1,1):find(time>=t2,1);
            plot(time(t0),d(t0,:));
            axis([0 50 min(min(d)) 20 ])
            drawnow;
            click=ginput(1);
            minI=find(time>=click(1),1);
            ivValues=d(minI,:);
            vcOutput(fileNumber+1,1:size(ivValues,2)+1)=[filename num2cell(ivValues)];
            end
            
            %%
            
%             figure(1)
%             clf
%             d2=d(:,1:10:40);
%             plot(d)
%             plot(time,d2);
            
            
%             if size(d,2)<=20
%                 numOfPlots=size(d,2);
%                 numOfRows=10;
%                 numOfColumns=2;
%             else
%                 numOfPlots=size(d,2);
%                 numOfRows=10;
%                 numOfColumns=5;
%             end
%             for loopNumber = 1:numOfPlots;%plot the sweeps
%                 subplot(numOfRows,numOfColumns,loopNumber);
%                 plot(time,d(:,loopNumber));
%                 axis manual;
%                 axis(axisSettings);
%                 hold on;
%             end
% 
%             axis manual;
%             axis(axisSettings);
%             h = figure(1);
%             set(h,'name',filename,'numbertitle','off');

            
        end
    catch
        errorMesage=[ filename ' had and error'];
        warning(errorMesage);
        
    end

end
disp('*****done******')


%% to reduce the resolution of dSub ("data subtracted")
if 0
    %%
    clc
    
    %reduce resolution of data
    dataSize=find(time>=450,1);%size(dSub,2);
    resolution=1:round(dataSize/1000):dataSize;
    time2plot=time(resolution);
    data2plot=d2(resolution);
    ttxTrace=dTtx2(resolution);
    %plot
    figure(2)
    clf
    plot(time2plot,data2plot);
    hold on
    plot(time2plot,ttxTrace);
    plot(time2plot,dSub(resolution));
    
    voltageRamp=linspace(-120,20,size(resolution,2))';
    %create and output to "test"
    test=[voltageRamp data2plot ttxTrace];
    openvar('test')
    
end
%%
if 0
range=1:find(time>=450,1);
dSub=d2(range)-dTtx2(range);
plot(time(range),dSub,'c')
end