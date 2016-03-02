data=[];
openvar('data');
%%
time=[];
d=[];
range=1:round(size(data,1)/1000):find(data(:,1)>=400,1);
clf
plot(data(range,1),data(range,2),'k')
time=data(range,1);
d=data(range,2);
ind1=find(time>=25,1);
ind2=find(time>=150,1);

time1=time(ind1);
time2=time(ind2);
volt1=d(ind1);
volt2=d(ind2);

slope1=(volt2-volt1)/(time2-time1);
%y=mx+b
lineX=time;
lineY=slope1*time+d(1);
hold on
plot(lineX,lineY,'r')
plot(lineX,(d-lineY),'c')
fdata=[lineX,(d-lineY)];
openvar('fdata');