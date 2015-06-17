%% set defaults and clear old variables
set(0,'DefaultFigureWindowStyle','docked');
set(0,'DefaultFigureCreateFcn','zoom on');
clear all
clc
close all
%%
dirToSaveIn=uigetdir();
dirToSaveIn=[dirToSaveIn '\'];
cd(dirToSaveIn)
%%
time=0;
data=0;
fit=0;
details=0;
openvar('fit')
openvar('data')
openvar('time')

%%
details=cell(5,size(data,2));
openvar('details')
names=cell(1,size(data,2));
openvar('names')

%% Print Fits
tic
clc
for i=1:size(data,2)
    %print Fit
    h = figure(1);
    clf    
    semilogx(time,data(:,i),'ko',time,fit(:,i),'r');
    axis manual
    axis([1,1e5,0,1])
    mytitle=names(i);
    title(strrep(mytitle,'_','\_'));
    xlabel('Time (ms)')
    ylabel('Normalized Current (I/Imax)')
    text(2,.9,{'Error';'a1'; 't1'; 'a2'; 't2'})
    text(4, .9 ,details(:,i))
    set(h,'name',[char(mytitle) ' fit'],'numbertitle','off');
    printName=[dirToSaveIn [char(strrep(mytitle,'/','')) ' fit']];
    print(printName, '-dpng', '-r300'); %<-Save as PNG with 300 DPI
%     input('Press Enter to Advance');
    beep on
    beep
end
toc