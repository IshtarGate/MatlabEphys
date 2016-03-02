%% get the file
restoredefaultpath
try
addpath(genpath('C:\Users\newpc\Dropbox\mfiles'));
catch
end
try
addpath(genpath('C:\Users\James\Documents\Dropbox\Lab\mfiles'));
catch
end
jahCleanUp();

%%
%cd('Y:\Matteo\nd mice\8-18 cells good for D+')
%cd('Y:\Matteo\nd mice\')
%cd('Y:\Matteo\DD paper\')
    % get the path of the excel file and the folder it resides in
    [fileName,path] = uigetfile('*.abf', 'abf files');
    pathFileName = [path fileName];
    % make this the default path
    cd(path)
[data,si,h]=abfload(pathFileName);


%%
clf
clc
sweep=15;
time=(0:si/1000:si*(size(data,1)-1)/1000);
%time=time/1000;
plot(time,data(:,2,sweep));
dataForPeaks= data(:,2,sweep);
timeForPeaks=time;
MPP=10;
MPH=-40;
MPD=0;
[peaks, locs]=PeakDetUse(dataForPeaks,timeForPeaks,MPP,MPH,MPD);%removed MPD
hold on
plot(locs,peaks,'ro')
plot(timeForPeaks,dataForPeaks,'r')
%% Area
t1=find(time==10,1);
t2=find(time==100,1);
range=(t1:t2);
Dt= si/1000;
t3=find(time==0,1);
t4=find(time==3,1);
Rmp= mean(data(t3:t4));
plot(time(range),data(range)-Rmp);
AreaUC = (sum(data(range)-Rmp))*Dt;
openvar('AreaUC')
%% reduced plot 

figure(1)
clf
plot(time,data(:,1,sweep));

click=ginput(2);
t1=find(time>=click(1,1),1);
t2=find(time>=click(2,1),1);

range1=t1:t2;
tSize=size(range1,2);
indexSub=t1:round(tSize/3000):t2;
tReduced=time(indexSub);
dReduced=data(indexSub,1,sweep);

timeForPeaks=time(range1);
dataForPeaks=data(range1,1,sweep);

[peaks, locs]=PeakDetUse...
    (dataForPeaks,timeForPeaks,MPP,MPH,MPD);%removed MPD

Fdata=sortrows([locs peaks; tReduced' dReduced]);

plot(Fdata(:,1),Fdata(:,2))

openvar( 'Fdata')




%%
clc
phaseData=data(:,1,sweep);
time=(0:si/1000:si*(size(data,1)-1)/1000)/1000;
clf
plot(time,phaseData)
a=ginput(2);
t1=find(time>=a(1,1),1);
t2=find(time>=a(2,1),1);
apIdx(1)=t1;
apIdx(2)=t2;

derMat = zeros( size( apIdx( 1 ):apIdx( 2 ), 2 ), 5 );
    derMat( :, 1 ) = apIdx( 1 ):apIdx( 2 );
    derMat( :, 2 ) = time( apIdx( 1 ):apIdx( 2 ) )';
    derMat( :, 3 ) = phaseData( apIdx( 1 ):apIdx( 2 ) );
    derMat( 1:end-1, 4 ) = diff( phaseData( apIdx( 1 ):apIdx( 2 ) ) )/( si/1000 );
    derMat( 1:end-2, 5 ) = diff( diff( phaseData( apIdx( 1 ):apIdx( 2 )) ) )/( si/1000 );
clf
    plot(derMat(:,3),derMat(:,4))
    hold on
    plot(derMat(:,3),derMat(:,5))
    resultIndex=find(derMat(:,3)>=-40);
   plot(derMat(resultIndex,3),derMat(resultIndex,4))
trucDerMat=derMat(resultIndex,:);
range=(1:round(size(derMat,1)/1000):size(derMat,1));
derMat(range,:)
truncDerMat=[trucDerMat;derMat(range,:)];
truncDearMat2=sortrows(truncDerMat,1);
plot(truncDearMat2(:,3),truncDearMat2(:,4))
    openvar('truncDearMat2');
    
    %% half width
    
    max(derMat(:,3))
    max(derMat(:,4))
    find(derMat(:,5)>=10,1)
    derMat(find(derMat(:,5)>=10,1),3)
    rmp=mean(phaseData(1:90));
    thr=derMat(find(derMat(:,5)>=10,1),3);
   amp=max(derMat(:,3));
    uv=max(derMat(:,4));
    VoltageT1= (amp-thr)/2+thr;
    IndexT1=find(derMat(:,3)>= VoltageT1,1);
    
 
   IndexT1g=derMat(IndexT1,1);
   IndexT2=find(time>=.003,1)+IndexT1;
   indexRange=IndexT1+1:IndexT2;
   IndexApWidth=find(derMat(indexRange,3)<=derMat(IndexT1,3),1)
   ApWidth=time(IndexApWidth)*1000;
    clf
    plot(derMat(indexRange,2),derMat(IndexApWidth,3))
    
output=[{fileName}, num2cell(rmp),num2cell(amp) , num2cell(thr),num2cell(uv), num2cell(ApWidth) ];
   openvar('output')