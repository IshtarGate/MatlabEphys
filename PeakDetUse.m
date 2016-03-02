function [peaks, locs]=PeakDetUse(dataForPeaks,timeForPeaks,MPP,MPH,MPD)%removed MPD
% PeakDetUse serves as an adaptor to replicate the function of findpeaks
% a function provided by the signal processing toolbox
%
% ToDo: Add MPD
%%
[maxtab, ~]=peakdet(dataForPeaks,MPP,timeForPeaks);

try
    maxtab2=maxtab(maxtab(:,2)>MPH,:);
    peaks=maxtab2(:,2);
    locs=maxtab2(:,1);
%     hold on
%     plot(locs,peaks,'ro')
%     hold off
catch
    peaks=[];
    locs=[];
end


%% code for comparison agains findpeaks
% plot(time,data(:,1));
% [peaks,locs]=findpeaks(dataForPeaks,timeForPeaks,...
%                 'MinPeakDistance',MPD,...
%                 'MinPeakHeight',MPH,...
%                 'MinPeakProminence',MPP);
% hold on
% plot(locs,peaks,'ro')
% peaks
% locs

% [peaks, locs]=peakdetuse(dataForPeaks,timeForPeaks,MPD,MPH,MPP)
