addpath(genpath('C:\Users\James\Documents\Dropbox\Lab\mfiles'));
jahCleanUp();
%%
cd('C:\Users\James\Desktop\New flox\immuno\20151221 mouse slides nav (red) ank(633)');
[filename, pathname]=uigetfile('*.*');
imLoc=[pathname filename];
%%


myImage=imread(imLoc);

clc
figure(1)
clf
drawnow
desiredColorS=[0 0 1; 0 1 1; 1 0 0; 0 1 0];
ch=[];
for iTargetChannel=1:4
    %targetChannel=iTargetChannel;
    desiredColor=desiredColorS(iTargetChannel,:);
    %funtion outputImage=imTrans(myImage,targetChannel,desiredColor)
    imSize=size(myImage);
    %create blank RGB
    output=zeros(imSize(1),imSize(1),3);
    
    %create RGB from image
    for iCreateRGB=1:3
        output(:,:,iCreateRGB)=myImage(:,:,iTargetChannel)*desiredColor(iCreateRGB);
    end
    output=output/255;
    imshow(output, 'Border', 'tight');
    drawnow;
%     if isequal(iTargetChannel,1)
%         ch1=output;
%     elseif iTargetChannel==2
%         ch2=output;
%     elseif iTargetChannel==3
%         ch3=output;
%     elseif iTargetChannel==4
%         ch4=output;
%     end;
    ch{iTargetChannel}=output;
end

%myMerge=[ch2,ch3,ch4,ch2+ch3+ch4];
myMerge=[ch{1},ch{2},ch{3},ch{4},ch{2}+ch{3}+ch{4}];
%myMerge=[ch2+ch3+ch4];
imshow(myMerge, 'Border', 'tight');
%print(gcf,'-clipboard','-dmeta')
%%
imshow(ch{2}+ch{3}+ch{4}, 'Border', 'tight');
BW = roipoly;
%mean(myImage(BW))
BW3=zeros(imSize(1),imSize(1),3);
for iBW3=1:3
BW3(:,:,iBW3)=BW;
end
%% side by side nav ank with mask
clc
a=ch4.*BW3;
[x, y]=find(ch4>0);
b=[];
imshow(a);
for i=.1:.05:.3
%b =[b a>i];
b=a.*(a>i);
imshow(b)
end
%a=[(ch3>.15).*BW3 ch4.*BW3];

%b=imrotate(a,45);
%sum(sum(a))
%sum(sum(b))
%imshow(b)
%%
clf
imshow(BW)
[x,y]=find(BW>0);
p=polyfit(x,y,1);
yfit = polyval(p,1:size(BW,1));
hold on
plot(1:size(BW,1),yfit,'r')
% ymin=min(y);
% ymax=max(y);
% xmin=min(x);
% xmax=max(x);
%% Fluorescence intensity over segmented line
%create spline and plot 3d profile
imshow(ch4, 'Border', 'tight');
[cx,cy,c,xi,yi] = improfile();

%%
figure(1)
clf
hold off
% subplot(2,1,1);
% improfile(myImage(:,:,3),cx,cy);
% subplot(2,1,2);
% improfile(myImage(:,:,3),xi,yi);
% hold on
improfile(myImage(:,:,4),xi,yi);
hold on
imshow(ch4, 'Border', 'tight');
%% plot the smoothed 2 plot
figure(3)
clf
smoothFactor=round(size(c,1)/40);
plot(smooth(c(:,1,2),smoothFactor));
hold on
%plot(c(:,1,2));

%%
min(i)
max(i)
min(j)
max(j)

%%