%%
hold on
%%
hold off
[pks,loc]=findpeaks(data(:,35),'MINPEAKHEIGHT',0,'MINPEAKDISTANCE',1000)
%%

%%
clf
hold on
plot(data(:,35));
x=6213:7200;
sweep=35;
d=data(x,sweep);
% p=polyfit(x, d',41);
% y=polyval(p,x);
plot(x,smooth(d,16),'ro');
%%
size(startpositon:endposition)
size(d)