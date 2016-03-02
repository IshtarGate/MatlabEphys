%% set defaults and clear old variables
    try    
        addpath('C:\Users\James\Documents\Dropbox\Lab\mfiles');
    catch
    end
    
    jahCleanUp;

[fileName, pathName]=uigetfile('.txt','input eeg file');
cd(pathName)
%%
clc
headerInfo = jahEegImportHeader([pathName fileName]);
rawData = jahImportEeg([pathName fileName]);
time=rawData(:,1);
data=rawData(:,2);
subplot(2,1,1)
plot(time,data);
click=ginput(2);
t1=find(time>=click(1,1),1);
t2=find(time>=click(2,1),1);
subplot(2,1,2)
plot(time(t1:t2),data(t1:t2));
