function [HyTable]=jahHyStats(time,d,figureNumber)
% This replaces the old jahIhyStats
% pass in d and loopNumber to return a table containing
% the rmp, varable state,

%%
if exist('figureNumber')==0 || isempty(figureNumber)==1
    figureNumber=6;
end


HyTable=cell(1,110);

h = figure(figureNumber);
clf
plotname=('HyPlot');
set(h,'name',plotname,'numbertitle','off');


for loopNumber=1:size(d,2)
    subplot(round(size(d,2)/2),2,loopNumber);
   
    % hardcoded variables
    
    sd=smooth(d(:,loopNumber),500); % save the smoothed trace
    rmpEndTime=25;
    varStateSearchWidth=find(time>=80,1);
    
    %find things
    rmpEndIndex=find(time>=rmpEndTime,1); % find RMP end index
    
    iHyTempRMP=mean(sd(1:rmpEndIndex)); % find RMP
    
    iHyStartIndex=find(sd<iHyTempRMP-1,1); % find iHy start
    
    [~,iHyVarStateIndex]=min(sd(iHyStartIndex:iHyStartIndex+varStateSearchWidth)); %find iHyVarState
    iHyVarStateIndex=iHyVarStateIndex+iHyStartIndex; % correct iHyVarStateIndex for index offset
    iHyVarState=d(iHyVarStateIndex,loopNumber); % find mV value of iHyVarState
    
    iHyEndIndex=find(sd(iHyVarStateIndex:end)>=iHyTempRMP,1)+iHyVarStateIndex;% find end of hyperpolerization
    
    iHySteadyStateIndex=iHyEndIndex-find(time>=30,1);% find index just before end of hyperpolarization
    iHySteadyState=sd(iHySteadyStateIndex); % find mV
    
    MPD=2;%min peak distance
    MPH=-10;%min peak height
    MPP=10;%MinPeakProminence
    [peaks,locs]=PeakDetUse(d(:,loopNumber),time,MPP,MPH);
    
    if isempty(peaks)==1
        
        [~,iHyADPheightIndex] = max(sd(iHyEndIndex:iHyEndIndex+find(time>=100,1)));%find max ADP index
        iHyADPheightIndex=iHyADPheightIndex+iHyEndIndex;% correct for find offset
        iHyAdpHeight=sd(iHyADPheightIndex);
        iHyAdpHalfHeight=sd(iHyEndIndex)+(0.5*(sd(iHyADPheightIndex)-sd(iHyEndIndex)));
        iHyAdpDurationIndex=find(...
            sd(iHyADPheightIndex:find(time>=time(end),1))...
            <=iHyAdpHalfHeight,1) + iHyADPheightIndex;
        iHyAdpDuration=time(iHyAdpDurationIndex-iHyEndIndex);
        
        %if iHyAdpDurationIndex can't be found substitute with NaN
        if isempty(iHyAdpDurationIndex)
            iHyAdpDurationIndex=NaN;
            iHyAdpDuration=NaN;
        end
        
    else
        iHyADPheightIndex=NaN;
        iHyAdpDuration=NaN;
        iHyAdpHeight=NaN;
    end

    % plot things
    try
        if isempty(locs)==1
            xAxis2=time(iHyADPheightIndex)+100;% set axis just past ADP
        else
            xAxis2=locs(end)+100; % set right hand of X axis just past last AP
        end
    catch
       xAxis2=time(end); 
    end
    
    if isempty(xAxis2)
        xAxis2=time(end);
    end
    
    plot(time,smooth(d(:,loopNumber),10)); % regular sweep in red
    
    axis([ 0, xAxis2, min(d(:,loopNumber)), max(d(:,loopNumber) )]) % set axes
    hold on
   
    plot(time,sd); % smoothed sweep in blue
    
    plot(time(rmpEndIndex),sd(rmpEndIndex),'ko'); % plot rmp end
    plot(time(iHyStartIndex),sd(iHyStartIndex),'ko'); % plot iHy start
    plot(time(iHyVarStateIndex),iHyVarState,'ko'); % plot iHyVarState
    plot(time(iHyEndIndex),sd(iHyEndIndex),'ko'); %plot end of hyperpolarization
    plot(time(iHySteadyStateIndex),iHySteadyState,'ko'); % plot steady state
    if isempty(peaks)==1
        try
            plot(time(iHyADPheightIndex),sd(iHyADPheightIndex),'ko'); % plot ADP height
            plot(time(iHyAdpDurationIndex),sd(iHyAdpDurationIndex),'ko'); % plot ADP duration
        catch
        end
    end
    
    HyTable(loopNumber)=num2cell(iHyTempRMP);
    HyTable(loopNumber+22)=num2cell(iHyVarState);
    HyTable(loopNumber+44)=num2cell(iHySteadyState);
    HyTable(loopNumber+66)=num2cell(iHyAdpHeight);
    HyTable(loopNumber+88)=num2cell(iHyAdpDuration);
    
    %save('testvariable') %troubleshoot
    % load('testvariable') %troubleshoot
    
end