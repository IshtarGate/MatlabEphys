function [evokedDuration] = jahEvokedDuration(evokedDurationInputVar)
% finds first ap and measures duration before trace returns to RMP+2mV


%% set up variables
time = evokedDurationInputVar.time;
d = evokedDurationInputVar.d;
sweep = evokedDurationInputVar.sweepOfFirstAp;

%start

evokedRmp=mean(d(1:50,sweep));

%find first peak
MPD=2;%min peak distance
MPH=-10;%min peak height
MPP=10;%MinPeakProminence
dataForPeaks = d(:,sweep);
timeForPeaks = time;
[~,locs]=PeakDetUse(dataForPeaks,timeForPeaks,MPP,MPH,MPD);

%find index of first ap
indexOfFirstApInSweep = find(time>=locs(1),1);

heightAboveRmp = 2; % evoked duration ends when trace returns to 2mV above RMP

%find index of end of evoked duration
evokedDurationIndex=...
    find(d(indexOfFirstApInSweep:end,sweep)...
    <evokedRmp+heightAboveRmp,1)...
    +indexOfFirstApInSweep;

evokedDuration=time(evokedDurationIndex)...
    -time(indexOfFirstApInSweep);


%Set evokedDuration to NaN if not found
if isempty(evokedDuration)
    evokedDuration=NaN;
end

%try to plot evoked duration end
try
    hold on
    figure(2)
    plot(time(evokedDurationIndex),d(evokedDurationIndex,sweep),'bo')
catch
end


end