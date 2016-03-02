function [inputResistance]=jahInputResistanceCalc(time,d,figNum,irRoi)

h=figure(figNum);
plotname=('IR Plot');
set(h,'name',plotname,'numbertitle','off');
clf

roi1=find(time>=irRoi(1),1);
roi2=find(time>=irRoi(2),1);
roi3=find(time>=irRoi(3),1);
roi4=find(time>=irRoi(4),1);

%% plot roi's over sweep 1
subplot(2,1,1)
plot(time,d(:,1));
hold on
iSweep=1;
for iPlot=[roi1,roi2,roi3,roi4]
    toPlot=iPlot;
    plot(time(toPlot), d(toPlot,iSweep), 'ro')
end
%% make irSweeps list, using only sweeps with no APs

%find peaks
isThereAp=NaN(size(d,2),1);

for iSweep=1:size(d,2)
    
    % call PeakDetUse
    MPD=2;%min peak distance
    MPH=-10;%min peak height
    MPP=10;%MinPeakProminence
    dataForPeaks = d(:,iSweep);
    timeForPeaks = time;
    [~,locs]=PeakDetUse(dataForPeaks,timeForPeaks,MPP,MPH,MPD);
    
    % assign sweeps with peaks
    if size(locs,1)>0
        isThereAp(iSweep,1)=1;
    else
        isThereAp(iSweep,1)=0;
    end
end

% return list of sweeps with no APs
allSweeps=1:size(d,2);
isThereAp(3)=1;%remove the zero current input step
sweepsWithNoAps=(allSweeps(find(isThereAp==0)))';

%% calc delta v


% make deltaVolt matrix [sweep nanoamps, deltaVolt, deltaVolt/nanoamps]
deltaVolt=NaN(size(sweepsWithNoAps,1),4);
% assign sweeps
deltaVolt(:,1)=sweepsWithNoAps;
% make nanoamps column
deltaVolt(:,2)=(((deltaVolt(:,1))*10-30)/1000)';

% run though sweeps before first AP
for iloop=1:size(deltaVolt,1)
    %calc deltaVolt each sweep
    deltaVolt(iloop,3)=mean(d(roi2:roi3,deltaVolt(iloop,1)))-mean(d(roi1:roi2,deltaVolt(iloop,1)));
    deltaVolt(iloop,4)=deltaVolt(iloop,3)/deltaVolt(iloop,2); 
end

% plot nanoamps vs deltaVolt
    subplot(2,1,2)
    plot(deltaVolt(:,2),deltaVolt(:,3))
%% output
inputResistance=mean(deltaVolt(:,4));

end

%% old code for doing this
%             % only run IR protocol if it's cciv and sweepOfFirstAp>5
%             if isempty(sweepOfFirstAp)==0 && ismember(1, protocolBeingAnalyzed)==1 && sweepOfFirstAp>5
%                 try
%                     figure(6);
%                     clf
%                     h = figure(6);
%                     plotname=('IR Plot');
%                     set(h,'name',plotname,'numbertitle','off');
%                     
%                     hold on
%                     clf
%                     hold on
%                     
%                     if exist('sweepOfFirstAp','var')==0 || isempty(sweepOfFirstAp)==1
%                         sweepOfFirstAp=10;
%                     end
%                     
%                     IRstop=sweepOfFirstAp-1;
%                     if sweepOfFirstAp-1<1
%                         IRstop=1;
%                     end
%                     
%                     IRcurrentSteps=IRcurrentSteps(1:IRstop);
%                     IRvoltageSteps=NaN(1,IRstop);
%                     for irSweeps=1:IRstop
%                         meanA=mean(d(irROIone:irROItwo,irSweeps));
%                         meanB=mean(d(irROIthree:irROIfour,irSweeps));
%                         IRvoltageSteps(irSweeps)=(meanB-meanA);
%                     end
%                     plot(IRcurrentSteps,IRvoltageSteps);
%                     % calculate the negative IR
%                     tempFit=polyfit(IRcurrentSteps(1:3),IRvoltageSteps(1:3),1);
%                     plot(IRcurrentSteps(1:3),polyval(tempFit,IRcurrentSteps(1:3)));
%                     negativeIR=tempFit(1);
%                     % calculate the positive IR
%                     tempFit=polyfit(IRcurrentSteps(3:end),IRvoltageSteps(3:end),1);
%                     plot(IRcurrentSteps(3:end),polyval(tempFit,IRcurrentSteps(3:end)));
%                     positiveIR=tempFit(1);
%                     % calculate total IR
%                     tempFit=polyfit(IRcurrentSteps(1:end),IRvoltageSteps(1:end),1);
%                     plot(IRcurrentSteps(1:end),polyval(tempFit,IRcurrentSteps(1:end)));
%                     totalIR=tempFit(1);
%                     
%                     xlabel('pA');
%                     ylabel('mV');
%                     % catch
%                     % disp('Could not plot IR jaherror-05');
%                     % negativeIR=NaN;
%                     % positiveIR=NaN;
%                     % totalIR=NaN;
%                     % end
%                     %        pause(0.5)
%                     
%                     % if IR calculation fails print error, make NaNs
%                 catch
%                     IRvoltageSteps=NaN(1,1);
%                     negativeIR=NaN;
%                     positiveIR=NaN;
%                     totalIR=NaN;
%                     warning('IR could not be calculated jaherror-05');
%                 end
%                 
%             else % make NaNs if IR isn't calculated
%                 IRvoltageSteps=NaN(1,1);
%                 negativeIR=NaN;
%                 positiveIR=NaN;
%                 totalIR=NaN;
%             end