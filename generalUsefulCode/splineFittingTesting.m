%% this script uses spline to interpolate a cubic line across data x,y
% this is currently a work in progress.
set(0,'DefaultFigureWindowStyle','docked');
set(0,'DefaultFigureCreateFcn','zoom on');

clf


plot(derMat(:,1),smooth(derMat(:,4),100),'k')
hold on
myEnd=size(derMat(:,1),1);
xx=linspace(derMat(1,1),derMat(myEnd,1),500);
yy=spline(derMat(:,1),smooth(derMat(:,4),100),xx);
plot(xx,yy,'r')
%%
clf
plot(time,d(:,40))

for i=1:3
times=ginput(2);
range=find(time>=times(1,1),1):find(time>=times(2,1),1);
clf
plot(time(range),d(range,46))
end
%plot(time,d(:,40))
%%
clf
plot(time(range),d(range,46),'k')
hold on
plot(time(range),smooth(d(range,46),10),'r')
% yy=spline(time(range),d(range,46),time(range));
% plot(time(range),yy,'bo')

b=smooth(d(range,46),10);