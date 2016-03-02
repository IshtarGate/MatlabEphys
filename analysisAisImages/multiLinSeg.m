%function output = multiLinSeg(nLines)
%%
p=[];
for i=1:3
    p{i}.c=rand(20,1);
    p{i}.xi=rand(20,1);
    p{i}.yi=rand(20,1);
end
openvar('p')

%% program

%show image


    %% use ginput(2) to zoom in on single AIS the image
    figure(1);
    clf
    clc
    imshow(ch{2}+ch{4}, 'Border', 'tight');
    [gy,gx]=ginput(2);
    gx=round(gx);
    gy=round(gy);
    chSub=[];
    chSub{1}=ch{3}(gx(1):gx(2),gy(1):gy(2),:);
    chSub{2}=ch{4}(gx(1):gx(2),gy(1):gy(2),:);
    
    imshow([chSub{1} chSub{2}],'Border', 'tight');
    %% improfile
    [cx,cy,c,xi,yi] = improfile();
    %% get profiles for ank and nav, and AIS length
    navProfile=improfile(chSub{1},xi,yi);
    ankProfile=improfile(chSub{2},xi,yi);
    xAxis=1:size(ankProfile,1);
    figure(3)
    clf
    plot(xAxis,smooth(navProfile),'r');
    hold on
    plot(xAxis,smooth(ankProfile),'g');
    plot(xAxis,smooth(navProfile)./smooth(ankProfile),'c');
    
    %caculate pixel length of AIS
    sumLength=0;
    for iLength=1:size(xi,1)-1
        sumLength=sumLength+...
            sqrt(abs(xi(iLength)-xi(iLength+1))^2+...
            abs(xi(iLength)-xi(iLength+1))^2);
    end
    %%
%improfile

%% rotate and crop
% get points
figure(1);
clf
clc
imshow(ch{3}+ch{4}, 'Border', 'tight');
[gx,gy]=ginput(2);
gx=round(gx);
gy=round(gy);

rotateAngle=atand( abs(gy(1)-gy(2)) / abs(gx(1)-gx(2)) );
if gx(1)<gx(2) &&gy(1)>gy(2)
    rotateAngle=rotateAngle+90; %quadrant 1
elseif gx(1)<gx(2) &&gy(1)<gy(2)
    rotateAngle=rotateAngle; %#ok<ASGSL> %quadrant 2
elseif gx(1)>gx(2) &&gy(1)<gy(2)
    rotateAngle=-rotateAngle; %quadrant 3
elseif gx(1)>gx(2) && gy(1)>gy(2)
    rotateAngle=-rotateAngle-90; %quadrant 4
end
clf
rotatedImage=imrotate([ch{3}+ch{4}],-rotateAngle);%(imageToRotate,Angle)
imshow(rotatedImage,'Border','tight');
[gx,gy]=ginput(2);
gx=round(gx);
gy=round(gy);

rotCh=[];
for iCh=1:4
    rotCh{iCh}=imrotate(ch{iCh},-rotateAngle);
end
cropCh=[];
for iCh=1:4
    cropCh{iCh}=rotCh{iCh}(gy(1):gy(2),gx(1):gx(2),:);
end

imshow([cropCh{2}+cropCh{1},cropCh{3},cropCh{4},cropCh{3}+ cropCh{4}], 'Border', 'tight');

%% subtract background
% imshow(cropCh{3}(:,:,1),'Border','tight')
% [gx,gy]=ginput(2);
% gx=round(gx);
% gy=round(gy);
% sub=mean(mean((cropCh{3}(:,:,1))));
% imshow(cropCh{3}(:,:,1)-sub,'Border','tight')

%% image profile
figure(1)
imshow(cropCh{3}(:,:,1),'Border','tight')
[cx,cy,c,xi,yi] = improfile();

navProfile=improfile(cropCh{3}(:,:,1),xi,yi);
profSize=size(navProfile,1);
navAgProfile=zeros(profSize,1);
ankAgProfile=zeros(profSize,1);
for iWidth=-8:1:8
navProfile=improfile(cropCh{3}(:,:,1),xi+iWidth,yi);
ankProfile=improfile(cropCh{4}(:,:,2),xi+iWidth,yi);
navAgProfile=navAgProfile+navProfile;
ankAgProfile=ankAgProfile+ankProfile;
end


figure(2)
clf
plot(1:size(navProfile,1),navAgProfile,'r')
hold on
plot(1:size(navProfile,1),ankAgProfile,'g')
plot(1:size(navProfile,1),navAgProfile/ankAgProfile,'b')