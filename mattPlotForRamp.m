%% reduced dSub
t2=find(time>=400,1);
range=1:round(t2/1000):t2;
plot(time(range), dSub(range));
fdata=[time(range), dSub(range)];
openvar('fdata')

%% reduced d2
clf

plot(time, d2)
t2=find(time>=610,1);
range=1:round(t2/1000):t2;
plot(time(range),  d2(range));
fdata2=[time(range), d2(range)];
openvar('fdata2')

%% LINEAR speacing

ramp=linspace(-100, +20, size(range,2))
openvar('ramp')

%% 
a=[-100:10:20]
openvar

%% resurg plot
iSweep=1:size(d,2)
sweep=9
                  
                
                    plot(time(),d(:,sweep))
                    clf
                    t2=find(time>=110,1);
                    range=1:round(t2/1000):t2;
                    plot(time(range), d(range,9))
                    d2=[time(range),d(range,9)];
                    openvar('d2')
                    clf
                    plot(time(range),dTtx(range,sweep),'r')
                     dttx=[time(range),dTtx(range,sweep)];
                     openvar('dttx')
                    plot(time(range),dSub(range,sweep),'c')
                   dsub=[time(range),dSub(range,sweep)];
                   openvar('dsub')
