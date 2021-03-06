% jahhippoForMfiles loads filenames from an text file to determine 
%     which abf files in the same folder will be analyzed
% 
% the text file must contain three colums (don't need column titles) (tab delimited)
%     'Filename' 'Analyze File?' 'Protocol Number'
%
% Use jahGetABFfileNames() to get filenames of all abf files in a 
%     folder
%
% Extra Notes:
%     parts of this program that need fixing are marked with '% toFix'
%
%     archived code has been moved to 'jahOldCode.m' (edit jahOldCode.m)
%
%     Use jahplot2.m() to review many abf files at once
%     
%     Use jahAbfToPrism2 to quickly convert abf flies into truncated Prism
%       format
% 

%% set defaults and clear old variables
    jahCleanUp;
    
    
%% uigetfile

    % get the path of the excel file and the folder it resides in
    %[excelFileName,path] = uigetfile('*.xlsx', 'excel files');
    [textFileName,path] = uigetfile('*.txt', 'text files');
    
    % make this the default path
    cd(path)

    % change this to change the imported excel range
    %abfFilesInDirCell = JAHimportExcel(excelFileName, 1, 'a4:c400');
    abfFilesInDirCell = jahImportTxt(textFileName);%, startRow, endRow
    
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
    
    % create variables for deep analysis
    deepApAnalysisSheet = cell( numberOfFiles, 1+3*4);
    openvar('deepApAnalysisSheet')
    deepApAnalysisSheet(:,1) = filenames; 
    %     deepApAnalysisColumnTitles = {'tempThresholdVolt' 'max2ndDerVolt'...
    %         'tempMaxUpStrokeIndexValue' 'tempUpStrokeAtZeroValue'};
    % deepApAnalysisSheet( 1, : ) = ['filename', deepApAnalysisColumnTitles, deepApAnalysisColumnTitles];

    % initialize derivative matrix
    derMatSheet = [filenames num2cell(NaN(numberOfFiles,3000))];
    openvar('derMatSheet')
    
    % Create list of files that didn't run
    abfFilesInDirCellErrorSheet=cell(numberOfFiles,2);
    abfFilesInDirCellErrorSheet(:,1) = abfFilesInDirCell(:,1);
    
    
for fileNumber=1:numberOfFiles;
    
    try %if a file fails for any reason
        
        %% set the protocol to be analyzed
        protocolBeingAnalyzed=abfFilesInDirCell{fileNumber,3};
        path_filename = strcat(dirOfMatFiles,filenames{fileNumber});
        filename=filenames{fileNumber};
        
        
        if abfFilesInDirCell{fileNumber,2}==1;
            %% load abf and consolidate to a single channel
            
            [data,si,~]=abfload(path_filename, 'sweeps','a');
            
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
            axisSettings=[0, time(end), min_of_data, max_of_data];
            
            
            apROIindexOne=find(time>=60,1);
            apROIindexTwo=find(time>=420,1);
            
                     
            %% auto ap freq
%             allLocs=NaN(20,size(d,2));
%             
%             for iSweep=1:size(d,2)
%                 apROIindexOne=1;
%                 apROIindexTwo=size(d,1);
%                 MPD=2;%min peak distance
%                 MPH=-10;%min peak height
%                 MPP=10;%MinPeakProminence
%                 dataForPeaks=d(apROIindexOne:apROIindexTwo,iSweep);
%                 timeForPeaks=time(apROIindexOne:apROIindexTwo);
%                 [peaks,locs]=PeakDetUse(dataForPeaks,timeForPeaks,MPP,MPH,MPD);
%                 allLocs(iSweep,1:size(locs,1))=locs;
%             end
            %% find duration of ADP
            if exist('adpOutput','var')==0
                adpOutput=cell(numberOfFiles,21);
                adpOutput(:,1)=filenames;
                openvar('adpOutput');
            end
%             % find sweep of first ap
%             apMatrix=isnan(allLocs)==0;
%             [j,k]=find(apMatrix>0,1);
%             iSweep=j;
            
            clc
            %find duration of ADP
            for iSweep=1:size(d,2)
            rmpStart=1;
            rmpStop=find(time>=50,1);
            tempRMP=mean(d(rmpStart:rmpStop,iSweep));
            hyperEnd=find(time>=566,1);
            adpStart=find(d(hyperEnd:end,iSweep)>=tempRMP,1)+hyperEnd;
            newAdpStart=adpStart+find(time>=30,1);
            adpEnd=find(d(newAdpStart:end,iSweep)<=tempRMP+2,1)+newAdpStart;
            adpDuration=time(adpEnd-adpStart);
            
            if isempty(adpDuration)
                adpDuration=[];
            end
            adpOutput(fileNumber,iSweep+1)={adpDuration};
            disp(adpDuration);
            
            %
            hold off
            plot(time, d(:,iSweep))
            axis([1, 2000,-75,-40])
            hold on
            plotThis=adpStart;
            plot(time(plotThis),d(plotThis,iSweep),'ro');
            plotThis=adpEnd;
            plot(time(plotThis),d(plotThis,iSweep),'ro');
            %plot(time(1:end-1), smooth(diff(d(:,iSweep))*1000,1000)+tempRMP)
            pause(.1)
            end
            %%
%           
%             
%             %% phaseplot
% 
%             figureNumbersSet=[1 2; 3 4; 5 6];
%             sweepOfInterest = 46;
%             % Step through first 3 Ap's of sweep 46
%             for iAp=1:3
% 
%                 if allLocs(sweepOfInterest,iAp)>6
% 
%                 figureNumbers=figureNumbersSet(iAp,:);
%                 printPlotsToFile=0;% 1=true 0=false
% 
%                 %find times to begin and end AP
%                 if iAp==1
% 
%                 apIdx(1) = find(time>=allLocs(sweepOfInterest,iAp),1)...
%                     - find(time>=3,1); % before ap
%                 apIdx(2) = find(time>=allLocs(sweepOfInterest,iAp),1)...
%                     + find(time>=5,1); % after ap
% 
%                 else
% 
%                     %apIdx(1) is the minimum before the AP
%                         % assign the index of prior ap and this one
%                         priorApIndex = find(time>=allLocs(sweepOfInterest,iAp-1),1);
%                         thisApIndex = find(time>=allLocs(sweepOfInterest,iAp),1);
% 
%                         %find index of minimum between prior and this Ap
%                         [~, apIdx(1)] = min(d(priorApIndex:thisApIndex,sweepOfInterest));
% 
%                         % correct for index offset from find()
%                         apIdx(1)= apIdx(1) + priorApIndex;
% 
%                     %is there an ap after this one?
%                     if allLocs(sweepOfInterest,iAp+1)>6
% 
%                         %apIdx(2) is the minimum before the AP
%                             nextApIndex = find(time>=allLocs(sweepOfInterest,iAp+1),1);
% 
%                             %find index of minimum between prior and this Ap
%                             [~, apIdx(2)] = min(d(thisApIndex:nextApIndex,sweepOfInterest));
% 
%                             % correct for index offset from find()
%                             apIdx(2)= apIdx(2) + thisApIndex;
% 
%                     else
%                         %find a time 40 ms later
%                         apIdx(2) = thisApIndex + find(time>=40,1);
% 
%                     end % "is there an ap after this one?"
% 
%                 end
%                 [ ~, deepApAnalysis, derMat ] = ...
%                     jahApAnalysis( time, d, apIdx, sweepOfInterest, si,...
%                     dirToSaveIn, filename, figureNumbers, printPlotsToFile );
% 
%                 % Save derMat to derMatSheet
%                 tempSize=size(derMat,1);
%                 tempOffSet=(iAp-1)*4000+1;
%                 derMatSheet(fileNumber,1+tempOffSet:tempSize+tempOffSet)...
%                     =num2cell(derMat(:,3)'); %assign voltage
%                 derMatSheet(fileNumber,1+tempOffSet+2000:tempSize+tempOffSet+2000)...
%                     =num2cell(derMat(:,4)'); %assign volt/sec
% 
%                 % Save deepApAnalysis to deepApAnalysisSheet
%                 tempOffSet=(iAp-1)*4+1;
%                 deepApAnalysisSheet( fileNumber, 1+tempOffSet:4+tempOffSet )...
%                     = num2cell(deepApAnalysis);
% 
%                 end % if time of peak > 6    
%             end
%                                
        end
        
        %% Time Until Finished: print message about estimated time to finish
        %loopRunTime2=clock;
        %timeElapsed=loopRunTime2-loopRunTime0;
        %minutesTimeElapsed = timeElapsed(4)*60+timeElapsed(5)+timeElapsed(6)/60;
        
        % if the file is being analyzed and is not the last file
        % calculate the average time to analyze and time to completion
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
        
       
    catch ME
        %% Analysis Catch: if an error occurs record which cell it was
        
        abfFilesInDirCellErrorSheet(fileNumber,2) = num2cell(1);
        openvar('abfFilesInDirCellErrorSheet');
        warningMessage=['Did not do analysis of ' filename];
        warning(warningMessage);
        
        rethrow(ME);
        
    end % end of try statement (%if a file fails for any reason)
    
end % end of for loop through files
%% converty empty cells in derMatSheet to NaNs

emptycells=cellfun(@isempty,derMatSheet);
derMatSheet(emptycells)={NaN};

%% open all variables and export data
currentTime=clock;
saveFileName=['crunchData-' num2str(currentTime(1)) '-'  num2str(currentTime(2)) '-' ...
    num2str(currentTime(3)) '-'  num2str(currentTime(4)) ' hr '  num2str(currentTime(5)) ' min' ];
save(saveFileName)
try
    %xlswrite([saveFileName '.xlsx'],cell2mat(derMatSheet(:,2:end)));
    dlmwrite([saveFileName '.txt'],cell2mat(derMatSheet(:,2:end)) , 'delimiter', '\t');
catch
    error(['could not write txt file: ' saveFileName '.txt']);
end
%% Print Done!
disp('Done!');
disp(['Please copy the variable ''' 'relevant outputs''' ' to your excel sheet.']);
fprintf(  [ '\n Run Time ' num2str(toc/60) '\n'])
beep on
for i=1:3
    beep;
    pause(.1);
end
%%
runThroughPhasePlots=0;
%%
if runThroughPhasePlots==1
    %% load phase plot data
    % Run this portion to load the phase plots from 'cruchData.m' 
    % even if you have already closed the analysis
    [derMatFile,derMatPath,~]=uigetfile;
    load([derMatPath derMatFile],'derMatSheet'); %load only derMatSheet
    %% set up figure 7 with axes settings
    h=figure(7);
    xAxisMax=max(max(cell2mat(derMatSheet(1:size(derMatSheet,1),2:499))))+10;
    xAxisMin=min(min(cell2mat(derMatSheet(1:size(derMatSheet,1),2:499))))-10;
    yAxisMax=max(max(cell2mat(derMatSheet(1:size(derMatSheet,1),501:999))))+2;
    yAxisMin=min(min(cell2mat(derMatSheet(1:size(derMatSheet,1),501:999))))-2;
    myAxes=[xAxisMin,xAxisMax,yAxisMin,yAxisMax];

    %helpful print
    fprintf('\n')
    disp('these were the axes settings: xmin xmax ymin ymax');
    disp(num2cell(myAxes));
    disp('to exit the display of all phase plots: select the command window and press "cntr + c" ');
    fprintf('\n')

    %run through all the phase plots
    for i=1:size(derMatSheet,1)
    plot(cell2mat(derMatSheet(i,2:502)),cell2mat(derMatSheet(i,501:1001)))
    axis(myAxes);
    hold on
    title(cellstr(derMatSheet(i,1)))
    figureName=char(derMatSheet(i,1));
    set(h,'name',figureName,'numbertitle','off');
    plot(cell2mat(derMatSheet(i,1001:1501)),cell2mat(derMatSheet(i,1501:2001)))
    plot(cell2mat(derMatSheet(i,2001:2501)),cell2mat(derMatSheet(i,2501:3001)))
    hold off
    pause(.5)
    end
%%
end