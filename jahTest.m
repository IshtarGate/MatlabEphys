clc
myInput=[];
openvar('myInput')

%% Find all Peaks
allLocs=NaN(20,size(d,2));

for iSweep=1:size(d,2)
    apROIindexOne=1;
    apROIindexTwo=size(d,1);
    MPD=2;%min peak distance
    MPH=-10;%min peak height
    MPP=10;%MinPeakProminence
    dataForPeaks=d(apROIindexOne:apROIindexTwo,iSweep);
    timeForPeaks=time(apROIindexOne:apROIindexTwo);
    [peaks,locs]=PeakDetUse(dataForPeaks,timeForPeaks,MPP,MPH,MPD);
    allLocs(iSweep,1:size(locs,1))=locs;
end
openvar('allLocs')


% Cut peaks out of data
radiusBeforeAp=5;
radiusAfterAp=8;
for iSweep=1:size(d,2)

    if sum(isnan(allLocs(iSweep,:))==0)>=1
        
        for iSweepSub=1:sum(isnan(allLocs(iSweep,:))==0)
            tempIndexesToNaN=(find(time>=allLocs(iSweep,iSweepSub)-radiusBeforeAp,1):...
                find(time>=allLocs(iSweep,iSweepSub)+radiusAfterAp,1))';
            if iSweepSub<2
                indexesToNaN=tempIndexesToNaN;
            elseif iSweepSub>1
                indexesToNaN=[indexesToNaN;tempIndexesToNaN];
            end
        end
        
        d2(:,iSweep)=d(:,iSweep);
        d2(indexesToNaN,iSweep)=NaN;
        
    else
        d2(:,iSweep)=d(:,iSweep);
    end
    
    [adp(iSweep,1),tempIndexMaxAdp]=max(d2(find(time>=500,1):find(time>=800,1),iSweep));
    
    tempIndexMaxAdp=tempIndexMaxAdp+find(time>=500,1);
    
    dispMessage=[ num2str(time(tempIndexMaxAdp)) ' , '  num2str(d2(tempIndexMaxAdp,iSweep)) ];
    disp(dispMessage)
    
    plot(time,d(:,iSweep));
    hold on
    plot(time,d2(:,iSweep));
    plot(time(tempIndexMaxAdp),d2(tempIndexMaxAdp,iSweep),'ro')
    axis([500, 800, -60, -20])
    hold off
%     pause(.1)
    
    commandwindow
    input('')
end
%%
clc
outputSize=size(find(myInput(:,1)==mode(myInput(:,1))),1);
myOutput=NaN(outputSize,4);
openvar('myOutput')
ticker=0;
for i=[1 2 4 5]
   ticker=ticker+1;
   temp=find(myInput(:,1)==i);
   myOutput(1:size(temp),ticker)=myInput(temp,2);
end
myOutput2=num2cell(myOutput)

for i=1:size(myOutput2,1)
    for j=1:size(myOutput2,2)
        if isnan(cell2mat(myOutput2(i,j)))
            myOutput2{i,j}='';
        end
    end
end


%% find voltages >x and get the APs at that voltage
% This can be used to search for critiera in one matrix and select the 
% values of the same index from another matrix
% 
% ie [ x y z ] find index of y and use it to get value j from [ i j k ]

%jahCleanUp()

% example data voltages in x and APs in y
if 0
    %%
x = [];%[-64.2,-65.9,-66.9,-69.2,-71.3,-72.1,-74.7,-76.2,-78,-79.8,-82.3,-83.9,-84.6,-86.7,-88.7,-89.7,-91.7,-93.5,-95.5,-96.3;-61.3,-63.5,-65.3,-66.7,-68.2,-69.7,-71.2,-72.6,-73.8,-75.3,-76.2,-78.1,-79.8,-81.2,-82.1,-83.4,-85.1,-86.3,-87.9,-90.2;-64.1,-65.8,-67.3,-69.4,-70.7,-72.2,-73.7,-75.1,-76.2,-77.7,-78.9,-80.2,-81.4,-82.4,-83.8,-85.1,-86.5,-87.8,-89.1,-90.2;-65.8,-68.2,-69.3,-71.1,-73.2,-75,-75.8,-77.6,-79.3,-80.4,-80.8,-82.8,-84,-85.3,-85.6,-87.4,-89,-89.9,-90.3,-92.2;-62.6,-64.9,-66.8,-68.2,-69.8,-71,-72.3,-73.5,-74.7,-75.8,-76.8,-77.9,-79.1,-80,-81.2,-82.2,-83.2,-84.4,-85.2,-86.1;-60.8,-63.2,-64.1,-65.1,-66.3,-67.4,-68.3,-70.1,-71.3,-70,-71.4,-71.8,-72.7,-73,-76.8,-76.3,-77.2,-78.1,-78.7,-78.5;-61,-61.7,-63.1,-64.9,-65.9,-66.9,-67.9,-68.4,-69.6,-70,-71,-71.6,-72.3,-72.9,-73.5,-74,-74.7,-75.4,-75.8,-76.4;-64.5,-65.8,-66.9,-67.9,-68.5,-69.5,-70.3,-71.2,-71.8,-72.4,-72.7,-73.4,-73.7,-74,-74.7,-74.9,-75.6,-76.1,-76.3,-76.6;-58.9,-59.7,-60.4,-61.4,-61.9,-62.5,-63.2,-64,-64.5,-65.4,-65.7,-66.1,-66.8,-67.2,-67.6,-68.1,-68.6,-69.1,-69.6,-70;-59.5,-60.5,-60.7,-61.1,-62.1,-62.9,-63.4,-64,-64.2,-64.8,-65.3,-65.7,-66.4,-66.7,-67.3,-67.7,-68,-68.4,-68.7,-68.9;-63.2,-64.4,-66.2,-67.4,-69.1,-70.3,-71.9,-73.5,-74.6,-75.9,-77.4,-78.5,-80.7,-82.1,-83.7,-85,-86.9,-88.3,-89.8,-90.3;-63.2,-64.6,-66.3,-67.9,-69.4,-70.5,-72.1,-73.4,-74.8,-76.4,-77.7,-79,-80.4,-81.5,-82.6,-84.2,-85.2,-86.8,-88,-89.7;-60,-62.4,-63.9,-65.7,-66.9,-68.7,-69.5,-71,-72,-73,-74.3,-75.5,-76.8,-77.6,-78.8,-79.7,-81.8,-82.4,-83.2,-84.4;-61.6,-63.7,-65.1,-66.4,-67.5,-68.5,-69.8,-70.4,-71.7,-72.7,-73.4,-74.6,-75.4,-75.2,-77.6,-78.1,-79,-80,-80.9,-81.9;-60.9,-62.4,-63.5,-64.2,-65.3,-66.3,-67.3,-68.1,-69.2,-70.4,-71,-71.9,-72.7,-73.4,-74,-74.8,-75.5,-76.1,-76.7,-77.2;-59.2,-60.5,-61.6,-61.8,-62.5,-63.6,-64.2,-64.8,-65.8,-66.5,-67.1,-67.8,-67,-67.4,-68.6,0,0,0,0,0;-65.6,-66.3,-69.5,-71.5,-74.9,-77,-78.5,-80.8,-82.3,-83.9,-85.6,-86.4,-88.4,-90.2,-92.8,-96.5,-98.1,-101.100000000000,-102.900000000000,-105.200000000000;-64.5,-66.5,-67.9,-69.8,-71.3,-72.6,-74.1,-75.1,-76.4,-77.4,-78.2,-79.8,-81,-82,-83.1,-84.4,-85.4,-86.5,-87.7,-89;-61.2,-63.7,-65,-65.7,-67.6,-68,-69.6,-71.1,-70.5,-73.1,-73.9,-75.1,-76.4,-76.4,-78.8,-79.4,-80.2,-82.1,-81.1,-83.4;-60.3,-60.8,-62.8,-63.6,-64.5,-65.7,-66.6,-67.5,-68.6,-69.3,-69.5,-71.1,-71.9,-72.6,-73,-74.2,-74.7,-75.8,-76.6,-77.4;-59.3,-60.2,-61.6,-62.5,-63.1,-63.8,-64.9,-65.7,-66.6,-67.3,-68.5,-68.8,-69.6,-70.9,-71.4,-72,-72.9,-73.6,-74.4,-75.1;-63.6,-64.9,-66.6,-68,-68.2,-69.6,-69.9,-70.3,-71,-72.2,-72.1,-73.1,-74.1,-74.4,-74.7,-75.2,-75.9,-75.8,-76.7,-77.4;-62.9,-66.1,-71.4,-74.6,-77.7,-80.6,-83.3,-85.9,-87.8,-90.6,-89.8,-91.5,-94.2,-97.9,-101.800000000000,-104.600000000000,-107.800000000000,-110.700000000000,-113.800000000000,-116.700000000000;-64.9,-66.8,-68.7,-70.4,-72,-73.4,-75,-76.1,-77.5,-78.6,-79.9,-81.2,-81.9,-83.5,-84.6,-85.5,-86.9,-88.2,-89.5,-90.4;-58.5,-59.5,-61.1,-61.8,-62.6,-63.4,-63.9,-64.8,-65.4,-66,-66.5,-67.6,-68,-68.9,-69.4,-70,-70.7,-71,-72,-72.3;-61.9,-63.6,-65.3,-65.9,-67.3,-67.9,-69,-69.4,-70.5,-71.4,-71.4,-72.1,-72.9,-73.1,-73.5,-74.4,-74.9,-75.1,-75.5,-75.6;-56.7,-57.2,-54.6,-55.6,-56.5,-57.1,-57.2,-57.3,-57.5,-57.7,-58,-58.3,-58.7,-58.9,-59.1,-59.5,-59.9,-60.1,-60.5,-60.2];
y = [];%[0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1;0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2,3,3,2,2;0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,2,2,2;0,0,0,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2;0,0,0,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2;0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1;0,0,0,0,1,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2;0,2,2,2,2,2,2,2,2,3,3,2,3,3,3,3,3,3,3,3;0,0,0,0,0,0,0,0,1,1,2,2,2,2,2,2,2,2,2,2;0,0,0,0,0,0,0,0,0,0,2,2,2,2,2,2,2,2,2,2;0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1;0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,1,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2;0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1;0,0,0,0,2,2,2,2,2,2,2,2,2,2,2,3,2,2,3,3;0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1;0,0,0,0,0,0,0,1,1,2,2,2,2,2,2,2,2,2,2,2;0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1;1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
group=[];
openvar('x')
openvar('y')
openvar('group')
end
%%
clc

voltagesOfInterest=-60:-1:-130;%[-60 -65 -70 -75 -80];
indexesAtVoltage=NaN(size(x,1),1);
myResult=NaN(size(x,1),size(voltagesOfInterest,2));

%loop through multiple voltageOfInterest
iStep=0;
for iVoltOfInterest = voltagesOfInterest
    
    iStep=iStep+1;
    
    %loop through each cell looking for APs at a voltage
    for iloop=1:size(x,1)

        try % try to find steady state = voltageOfInterest, return # of APs
            indexesAtVoltage(iloop)=find(x(iloop,:)<=iVoltOfInterest,1);
        catch
            indexesAtVoltage(iloop)=NaN;
        end

        % if voltageOfInterest was found, report APs
        if indexesAtVoltage(iloop)>0
            myResult(iloop,iStep)=y(iloop,indexesAtVoltage(iloop));
        else
            myResult(iloop,iStep)=NaN;
        end

    end
end

% add voltages of interest to top of myResult
myResultCell=[num2cell(voltagesOfInterest); num2cell(myResult)];
openvar('myResultCell')

groupResult=NaN(4,size(voltagesOfInterest,2));

myGroups=[1 2 4 5];
offsets=[1 4 7 10];
for iGroup=1:4
    offset=offsets(iGroup);
    theGroupe=myGroups(iGroup);
    for iColumn = 1:size(voltagesOfInterest,2)
        tempGroup1=myResult(group==theGroupe,iColumn);
        tempGroup2=tempGroup1(isnan(tempGroup1)==0);
        groupResult(offset,iColumn)=mean(tempGroup2);
        groupResult(offset+1,iColumn)=std(tempGroup2)/sqrt(size(tempGroup2,1));
        groupResult(offset+2,iColumn)=size(tempGroup2,1);
    end
end

groupResultCell=[num2cell(voltagesOfInterest); num2cell(groupResult)];
openvar('groupResultCell')
%%
figure(1)
clf
clc

f=1;
for iloop=[1 2 4 5]
    
    subplot(2,2,f)
    j=(find(z==iloop));
    a=x(j,:);
    b=y(j,:);
    plot(a,b,'o');
    hold on
    tempFit=polyfit(a,b,1);
    plot(a,polyval(tempFit,a));
    f=f+1;
    axis([min(min(x))-1 max(max(x))+1 -1 4]);
end
%%
clf
f=1;
for iloop=[1 2 4 5]
    a=x(find(z==iloop),:);
    b=x(find(z==iloop),:);
    c = NaN;
    d = NaN;
    e = NaN;
    for j=size(a,1)
        c(iloop,j)=find(a(j,:)<=-70,1);
        d(iloop,j)=x(j,c(iloop,j));
        e(iloop,j)=x(j,c(iloop,j));
    end
    subplot(2,2,f)
    plot(d,e,'o')
    f=f+1;
end
    
%% This as a function

% function [output]=jahTest()
% 
% dispText = 'this is a test';
% disp(dispText);
% 
% output = plotTest();
% end
% 
% function [x,y] = plotTest()
% x=1:10;
% y=sin(x);
% clf
% 
% hold on
% 
% plot(x,y);
% 
% hold off
% 
% end