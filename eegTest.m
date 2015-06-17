testWave=zeros(10000,1);
rand(1,10)
%%
clc
clear x y
x=0:.001:10;
freqFactor=2;
for i=1:size(x,2)
y(i)=sin(freqFactor*x(i)*2*pi)...
    *((-((x(i)-5))^2)+20)...
    +sin(freqFactor*x(i)*2*pi);
end

plot(x,y);