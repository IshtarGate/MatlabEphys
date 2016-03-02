function [plotOutput,plotOutput3]=jahAbfToPrismIntegrated(jahAbfToPrism2Inputs)
% Quickly convert large abf files into a smaller dataset for use in prism
% 
% This version of jahAbfToPrism is for multiple sweeps
%
% Any parameters can be changed in '*****User Inputs*****'
%
% 
% 
% example script using jahAbfToPrism2() to convert abf files to prism
% graphs, copy the text below but remove the %
% 
% Example:
% 
% jahCleanUp; % clean all variables, figures, and command window
% 
% % ***** User Inputs *****
%     maxNumberOfPointsToPlot=600; % how many points in the final time/voltage plot per sweep
%     useTheseSweeps=[10 20 30 40]; % Use this '1:size(d,2);' or something like this '[10 20 30 40]';
%     xAxisStart=50; % x axis start time (in milliseconds)
%     xAxisStop=500; % x axis stop time (in milliseconds)
% 
%     % Will you stack several current steps in a figure? Do you want the
%     % AP's shortened so they stack nicely?
%     makeTruncatedApGraph='True'; % 'True' or 'False'
%     voltagesGreaterThanThisWillBeTruncated=-30; %the last sweep will not be truncated
% 
% 
% 
% 
% %load input for jahAbfToPrism2
%     jahAbfToPrism2Inputs=struct('one',maxNumberOfPointsToPlot,...
%         'two',useTheseSweeps,'three',xAxisStart,'four',xAxisStop,...
%         'five', makeTruncatedApGraph, 'six', voltagesGreaterThanThisWillBeTruncated);
% 
% % call function jahAbfToPrism2
%     [plotOutput,plotOutput3]=jahAbfToPrism(jahAbfToPrism2Inputs);

%% Convert struct input to regular variables
    
    maxNumberOfPointsToPlot = jahAbfToPrism2Inputs.one;
    useTheseSweeps = jahAbfToPrism2Inputs.two;
    xAxisStart = jahAbfToPrism2Inputs.three;
    xAxisStop = jahAbfToPrism2Inputs.four;
    makeTruncatedApGraph = jahAbfToPrism2Inputs.five;
    voltagesGreaterThanThisWillBeTruncated = jahAbfToPrism2Inputs.six;
    path = jahAbfToPrism2Inputs.seven;
    fileName = jahAbfToPrism2Inputs.eight;
    figNum = jahAbfToPrism2Inputs.nine;
    
%% 
    pathFileName = [path fileName];
    
%% convert the file to more usable form: 3d matrix to 2d (voltage/sweep)

    [data,si,~]=abfload(pathFileName, 'sweeps','a');

    % consolidate to a single channel

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
    
%% if useTheseSweeps=='All' get all sweep numbers
if strcmp(useTheseSweeps,'All')
    useTheseSweeps=1:size(d,2);
end

%% find the number of sweeps to look at
    numSweeps=size(useTheseSweeps,2);
    
%% Set time1 and time 2
        try
            time1=find(time>=xAxisStart,1);
        catch
            time1=time(1);
            xAxisStart=time(1);
        end

        try
            time2=find(time>=xAxisStop,1);
        catch
            time2=time(end);
            xAxisStop=time(end);
        end
    
%% create custom subset of data
    myTime=time(time1:time2);

    allLocs=[];
    for iSweeps = 1:numSweeps
        
        %find peaks for feature extraction
        MPD=2;%min peak distance
        MPH=-10;%min peak height
        MPP=10;%MinPeakProminence
        dataForPeaks = d(:,useTheseSweeps(iSweeps));
        timeForPeaks = time;
        [~,locs]=PeakDetUse(dataForPeaks,timeForPeaks,MPP,MPH,MPD);
        allLocs=[allLocs; locs];
        
    end
        
    
%% reduce the data to less than the maxNumberOfPointsToPlot
    reductionFactor=round(size(myTime,1)/maxNumberOfPointsToPlot);
    reductionFactorIndices=(1:reductionFactor:size(myTime))';

    allLocsIndex=NaN(size(allLocs,1),size(allLocs,2));
    for iAllLocs=1:size(allLocs,1)
        allLocsIndex(iAllLocs,1)=find(time>=allLocs(iAllLocs,1),1);
    end
    
%% add peak data and sort
    finalIndex=sort([reductionFactorIndices+time1; allLocsIndex]);


    
%% create 'output' variable

    plotOutput=cell(size(finalIndex,1)+1,numSweeps+1);
    plotOutput(:,1)=[{fileName}; num2cell(time(finalIndex))];
    for iSweeps = 1:numSweeps
        plotOutput(:,iSweeps+1)=[{['sweep ' num2str(useTheseSweeps(iSweeps))]};...
            num2cell(d(finalIndex,useTheseSweeps(iSweeps)))];

    end
%     openvar('plotOutput');
        
%% Trim Peaks to stack sweeps in figure
    % delete all points higher than -30 on the sweeps leading up to the
    % last
    if strcmp(makeTruncatedApGraph,'True')
        lastCutSweep=size(useTheseSweeps,2);
        plotOutput2=cell2mat(plotOutput(2:end,2:lastCutSweep));
        plotOutput2(cell2mat(plotOutput(2:end,2:lastCutSweep))...
            >=voltagesGreaterThanThisWillBeTruncated)...
            =voltagesGreaterThanThisWillBeTruncated;
        plotOutput3=plotOutput;
        plotOutput3(2:end,2:lastCutSweep)=num2cell(plotOutput2);
%         openvar('plotOutput3')
    else
        plotOutput3=NaN;
    end
    %%
    h=figure(figNum);
    clf
    set(h,'name',fileName,'numbertitle','off');

    for iSweeps = 1:numSweeps
        subplot(numSweeps,1,iSweeps)
        plot(time(finalIndex),d(finalIndex,(useTheseSweeps(iSweeps))),'b')
        hold on
        plot(time,d(:,useTheseSweeps(iSweeps)),'r')
        axis([time(time1),time(time2),min(min(d)),max(max(d))]);
    end
  
end