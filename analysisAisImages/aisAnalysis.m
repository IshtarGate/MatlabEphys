%% final ais analysis code
% code shows merged image, finds an AIS, crops, rotates, does summed
% analysis and creates storage variable

restoredefaultpath
addpath(genpath('C:\Users\James\Documents\Dropbox\Lab\mfiles'));
jahCleanUp();

cd('C:\Users\James\Google Drive\_Patel Lab\Projects\Flox Nav Paper\immuno\20151221 mouse slides nav (red) ank(633)\to use copy');
extractedAisImagesPath='C:\Users\James\Google Drive\_Patel Lab\Projects\Flox Nav Paper\immuno\20151221 mouse slides nav (red) ank(633)\to use copy\extracted AISs';

%%
%for iNumAis=1:5
cellsAnalyzed=0;
output=cell(1,1);

%%
%while true %run until finished
[filename, pathname]=uigetfile('*.*');
imLoc=[pathname filename];



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
    tempChannel=zeros(imSize(1),imSize(1),3);
    
    %create RGB from image
    for iCreateRGB=1:3
        tempChannel(:,:,iCreateRGB)=myImage(:,:,iTargetChannel)*desiredColor(iCreateRGB);
    end
    tempChannel=tempChannel/255;
    imshow(tempChannel, 'Border', 'tight');
    drawnow;
    ch{iTargetChannel}=tempChannel;
end

%myMerge=[ch2,ch3,ch4,ch2+ch3+ch4];
%myMerge=[ch{1},ch{2},ch{3},ch{4},ch{2}+ch{3}+ch{4}];
myMerge=[ch{1}+ch{2}+ch{3}+ch{4}]; % one merged image
imshow(myMerge, 'Border', 'tight');
%print(gcf,'-clipboard','-dmeta')

%% get points describing all the beginning and ends of AISs in the image
myAisTempList=cell(1);
running=1;
while running>=1
% rotate and crop
    % get points
        h=figure(2);
        set(h,'Name',filename,'NumberTitle','off') %set figure name

        clf
        clc
        imshow(ch{3}+ch{4}, 'Border', 'tight');
        [gx,gy]=ginput(2);
        gx=round(gx);
        gy=round(gy);
        myAisTempList{running}.gx=gx;
        myAisTempList{running}.gy=gy;
        
        myInput=input('are there more AISs?:  ','s');
        running=running+1;
        if myInput=='n'
            running=0;
        end
end
%% create cropped and rotated rbg images for all AISs in image
for iMask=1:size(myAisTempList,2)
    gx=myAisTempList{iMask}.gx;
    gy=myAisTempList{iMask}.gy;
    %jahMaskFrom2Points inputs
        imSize=size(myImage,1);
%         subfunction BW =jahMaskFrom2Points(gx,gy,imSize)
        roiX=[gx(1),gx(2),gx(2)+1,gx(1)+1,gx(1)];
        roiY=[gy(1),gy(2),gy(2)+1,gy(1)+1,gy(1)];
        BW=poly2mask(roiX,roiY,1512,1512);
%         BW=zeros(imSize,imSize);
%         BW(gx(1),gy(1))=1;
%         BW(gx(2),gy(2))=1;
        imshow(BW, 'Border', 'tight')

    %compute angle to rotate
        rotateAngle=atand( abs(gy(1)-gy(2)) / abs(gx(1)-gx(2)) );
        if gx(1)<gx(2) && gy(1)>gy(2)
            rotateAngle=rotateAngle+90; %quadrant 1
        elseif gx(1)<gx(2) && gy(1)<gy(2)
            rotateAngle=abs(rotateAngle-90); %quadrant 2
        elseif gx(1)>gx(2) && gy(1)<gy(2)
            rotateAngle=-abs(rotateAngle-90); %quadrant 3
        elseif gx(1)>gx(2) && gy(1)>gy(2)
            rotateAngle=-rotateAngle-90; %quadrant 4
        end
        
    clf
    rotatedImage=imrotate([ch{3}+ch{4}],-rotateAngle);%(imageToRotate,Angle)
    rotatedBW=imrotate(BW,-rotateAngle);
    %imshow(rotatedBW,'Border','tight');
    [ngr,ngc]=find(rotatedBW==1);
    border=100;
    imshow(rotatedImage(...
        ngr(1)-border:ngr(end)+border,...
        ngc(1)-border:ngc(1)+border,...
        :),...
        'Border','tight');
    
    %create cropped rgb image
        rotCh=[];
        for iCh=1:4
            rotCh{iCh}=imrotate(ch{iCh},-rotateAngle);
        end
        cropCh=[];
        for iCh=1:4
            cropCh{iCh}=rotCh{iCh}(...
        ngr(1)-border:ngr(end)+border,...
        ngc(1)-border:ngc(1)+border,...
        :);%gy(1):gy(2),gx(1):gx(2),:);
        end
    %add to myAisTempList
        myAisTempList{iMask}.cropCh=cropCh;
end
%%

%set croping edges
% [gx,gy]=ginput(2);
% gx=round(gx);% need delta of about 200 for x
% gy=round(gy);% need delta of about 600 for x
% gx1=round(mean(gx()))-100;
% gx2=round(mean(gx()))+100;
% gx=[gx1;gx2];
% gy1=round(mean(gy()))-350;
% gy2=round(mean(gy()))+350;
% gy=[gy1;gy2];


% rotCh=[];
% for iCh=1:4
%     rotCh{iCh}=imrotate(ch{iCh},-rotateAngle);
% end
% cropCh=[];
% for iCh=1:4
%     cropCh{iCh}=rotCh{iCh}(gy(1):gy(2),gx(1):gx(2),:);
% end

% create scale bar overlay 1x5um (14.88 pixels per um)
imageSize=size(cropCh{3});
sx1=15;
sx2=15*6;
sy1=imageSize(1)-(15*2);
sy2=imageSize(1)-15;
cropChRedPlusScaleBar=cropCh{3};
cropChRedPlusScaleBar(sy1:sy2,sx1:sx2,:)=1;
imshow(cropChRedPlusScaleBar, 'Border', 'tight');

imshow([cropChRedPlusScaleBar,cropCh{4},cropCh{3}+ cropCh{4}], 'Border', 'tight');
%print(gcf,'-clipboard','-dmeta')


%%
% image profile
    h=figure(3)
    set(h,'Name',filename,'NumberTitle','off') %set figure name
    imshow(cropCh{4}(:,:,2),'Border','tight')
    [cx,cy,c,xi,yi] = improfile();
    
    %start profile
    navProfile=improfile(cropCh{3}(:,:,1),xi,yi);
    profSize=size(navProfile,1);
    navAgProfile=zeros(profSize,1);
    ankAgProfile=zeros(profSize,1);

    aisWidthToMeasure=25;
    for iWidth=-aisWidthToMeasure:1:aisWidthToMeasure
        navProfile=improfile(cropCh{3}(:,:,1),xi+iWidth,yi);
        ankProfile=improfile(cropCh{4}(:,:,2),xi+iWidth,yi);
        navAgProfile=navAgProfile+navProfile;
        ankAgProfile=ankAgProfile+ankProfile;
    end


    %plot 
    clf
    %convert range to micrometers
    xRange=(1:size(navProfile,1))/14.88; 
    hold on
    plot(xRange,ankAgProfile,'g')
    plot(xRange,navAgProfile,'r')
    
    
%%
%store data
    % reset cellsAnalyzed and output
    % cellsAnalyzed=0;output=cell(1);
    
    %increment the number of cells analyzed and make cell
    cellsAnalyzed=cellsAnalyzed+1;
    
    % output{n}=empty cell
    output{cellsAnalyzed}=cell(1,1);
    
    % output{n}{1}=range
    output{cellsAnalyzed}{1}=[{filename} num2cell([xRange])];
    
    % output{n}{2}=nav profile
    output{cellsAnalyzed}{2}=[{filename} num2cell([navAgProfile]')];
    
    % output{n}{3}=ank Profile
    output{cellsAnalyzed}{3}=[{filename} num2cell([ankAgProfile]')];
    disp(['finished analysis of ' filename])
%end


%% give output
formattedOutput=cell(1,1);
lineTitle=[{'range'};{'nav'};{'ank'}];
for i=1:size(output,2)
    for j=1:3
    outputLength=size(output{i}{j},2);
    formattedOutput((i-1)*3+j,1:outputLength+1)=[lineTitle(j) output{i}{j}];
    end
end
%output{cellsAnalyzed}{1}=[{filename} num2cell([xRange])]
%output{cellsAnalyzed}{2}=[{filename} num2cell([navAgProfile]')];
%output{cellsAnalyzed}{3}=[{filename} num2cell([ankAgProfile]')];

for icell=1:size(output,2)
    %return to matrix
    xRange=cell2mat(output{icell}{1}(2:end));
    navProf=cell2mat(output{icell}{2}(2:end));
    ankProf=cell2mat(output{icell}{3}(2:end));
    
    for i=1:50
        tempInd1=xRange<i;
        tempInd2=xRange>i-1;
        tempInd3=tempInd1.*tempInd2;
        tempDecNav(i)=mean(navProf(tempInd3==1));
        tempDecAnk(i)=mean(ankProf(tempInd3==1));
    end
    decFormattedOutput(icell,:)=[output{icell}{1}(1) {} num2cell(tempDecNav) {} num2cell(tempDecAnk)];
end


    

%%
figure(4)
clf
plot(1:50,tempDecNav,'r')
hold on
plot(1:50,tempDecAnk,'g')

%% decimate code
%create decimate factor
% decimateFactor=round(size(navProfile,1)/max(xRange));
% decNavAgProfile=decimate(navAgProfile,decimateFactor);
% xDecRange=1:round(max(xRange));
% clf
% plot(xDecRange,decNavAgProfile)
% hold on
% plot(xRange,navAgProfile,'r')