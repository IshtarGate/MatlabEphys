% matteoTest script

jahCleanUp;
maxNumberOfPointsToPlot=600;
useTheseSweeps=[1 3 9 18];%1:size(d,2);% [10 20 30 40];
xAxisStart=550; % time in ms
xAxisStop=700; % time in ms

jahAbfToPrism2Inputs.one = maxNumberOfPointsToPlot;
jahAbfToPrism2Inputs.two = useTheseSweeps;
jahAbfToPrism2Inputs.three = xAxisStart;
jahAbfToPrism2Inputs.four = xAxisStop;
[plotOutput] = jahAbfToPrism2(jahAbfToPrism2Inputs);

 
%% create protocol cartoon
jahCleanUp
a=[0 50 50.001 350 350.001 500]
b=[0 0 1 1 0 0]
c=[-1050:40:-100] 
for i=1:size(c,2)
    d(:,i)=b*c(i)
end
openvar('d')