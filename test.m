%% auto ap freq
figure(2)
clf
numberOfAps=NaN(1,size(d,2));
commandwindow
for loopNumber = 1:size(d,2);%plot the sweeps
    sweepOfInterest=d(:,loopNumber);
    plot(time,sweepOfInterest);
    axis manual;
    axis([0, number_of_milliseconds_in_sweep, min_of_data, max_of_data]);
    disp('###click on either side of area to analyze');
    if loopNumber<2
    disp('###click on either side of area to analyze');
    [timesOfInterest ~]=ginput(2);
    timesOfInterestOne=find(time>=timesOfInterest(1),1);
    timesOfInterestTwo=find(time>=timesOfInterest(2),1);
    else
    end
    MPD=5;%mean peak distance
    MPH=-20;%mean peak height
    [peaks,locs]=findpeaks(sweepOfInterest(timesOfInterestOne:timesOfInterestTwo),...
        time(timesOfInterestOne:timesOfInterestTwo),...
    'MinPeakDistance',MPD,...
    'MinPeakHeight',MPH);
    hold on
    plot(locs,peaks,'ro');
    hold off
    isItEmpty=isempty(peaks);
    if isItEmpty>0
        numberOfAps=0;
    else
        numberOfAps(1,loopNumber)=size(peaks,1);
    end
    pause(.1)
end
shg
