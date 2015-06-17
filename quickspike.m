% This is a dirty file for quickly finding the number of spikes in
% dirty data
%% Loading Multiple Files
set(0,'DefaultFigureWindowStyle','docked');%'normal' to return to non docked setup
close all
clear
clc
[filename,path] = uigetfile('*.abf','.abf File','MultiSelect','on');%loading files
cd(path)
fn = strcat(path,filename);
%add ischar iscell to make this handle multiple or mainly, single files
mypeaks=zeros(size(fn,2),50);%cell(size(fn,2),1)
for fileidx=1:size(fn,2)
    data = abfload(char(fn(fileidx)));%changing back to character array
    for n= 1:size(data,3);
    data2(:,n) = data(:,1,n); %Get rid of unwanted dimension
    %eval(['' tempfile '=data2']);
    end
figure(fileidx)
h = figure(fileidx);
set(h,'name',char(filename(fileidx)),'numbertitle','off');
%% find peaks

    for s=1:size(data2,2)
    subplot(8,7,s)
    plot(data2(1:20000,s))
    hold on    
%     t=0
%     for i=2600:3000
%         if data(i+20)-data(i-20)>=20 & data(i)>-20
%             minheight=data(i)
%             t=t+1
%             break 
%         end
%     end
%     if t==0
%         minheight=20
%     end
    [pks,idx]=findpeaks(data2(:,s),'MINPEAKHEIGHT',.5,'MINPEAKDISTANCE',200);
        if isempty(pks)==1
            peaks(s)=0;
        else
            peaks(s)=size(pks,1);
        end
        plot(idx,pks,'ro')
    end
mypeaks(fileidx,1:size(peaks,2))=peaks;
end