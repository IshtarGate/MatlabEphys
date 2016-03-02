%% james truncate - use this for existing traces
   %%
   data=[];
   openvar('data')
%% Set Windowsize
clf
for iData=2:size(data,2)
    hold on
    plot(data(:,1),data(:,iData),'k')
end

windowSize=ginput(2);
windowSize=[windowSize(1,1) windowSize(2,1) windowSize(1,2) windowSize(2,2)];
%% Plot with truncated traces at windowsize
range=1:find(data(:,1)>=windowSize(2),1);%size(data,1);
truncInterval=ceil(size(range,1)/1000); %size(data,1)
truncRange=range(1:truncInterval:end);


clf

for iData=2:size(data,2)
    hold on
    plot(data(range,1),data(range,iData),'k')
    plot(data(truncRange,1),data(truncRange,iData),'r')
    axis(windowSize)
end
%% find peaks
    allLocs=[];
    for iSweeps = 2:size(data,2)
        
        %find peaks for feature extraction
        MPD=2;%min peak distance
        MPH=-10;%min peak height
        MPP=10;%MinPeakProminence
        dataForPeaks = data(:,iSweeps);
        timeForPeaks = data(:,1);
        [~,locs]=PeakDetUse(dataForPeaks,timeForPeaks,MPP,MPH,MPD);
        allLocs=[allLocs; locs];
        
    end
    
    %convert peak times to indices
    peakIndex=[];
    peakIndices=[];
    for iLocs=1:size(allLocs,1)
        peakIndex=find(data(:,1)>=allLocs(iLocs,1),1);
        peakIndices=[peakIndices;peakIndex];
    end
    
    % add to range
        truncRange=sort([truncRange';peakIndices]);
    
    % plot again
        clf
        for iData=2:size(data,2)
            hold on
            plot(data(range,1),data(range,iData),'k')
            plot(data(truncRange,1),data(truncRange,iData),'ro')
            axis(windowSize)
        end
%% export data2 with selected windowsize
data2=data(truncRange,1);
for iData=2:size(data,2)
    data2(:,iData)=data(truncRange,iData);
end
openvar('data2')