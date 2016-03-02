% test for multiple phase plots

%% set defaults and clear old variables
try
    addpath('C:\Users\James\Documents\Dropbox\Lab\mfiles');
catch
end

jahCleanUp;


%% uigetfile

% get the path of the excel file and the folder it resides in
[excelFileName,path] = uigetfile('*.xlsx', 'excel files');
%[textFileName,path] = uigetfile('*.txt', 'text files');

% make this the default path
cd(path)

% change this to change the imported excel range
abfFilesInDirCell = JAHimportExcel(excelFileName, 1, 'a4:c1000');
%abfFilesInDirCell = jahImportTxt(textFileName);%, startRow, endRow

dirOfMatFiles=path;%[uigetdir('/home/james/Desktop','Directory of .abf files to analyze') '/'];
dirToSaveIn=dirOfMatFiles; %[uigetdir('/home/james/Desktop','Directory to save in') '/'];
filenames=abfFilesInDirCell(:,1);% filenames=cell(size(abfFilesInDirCell,1),1);


%% Run through multiple files
%start timer
tic
numberOfFiles=size(filenames,1);

% Create list of files that didn't run
abfFilesInDirCellErrorSheet=cell(numberOfFiles,2);
abfFilesInDirCellErrorSheet(:,1) = abfFilesInDirCell(:,1);

for fileNumber=1:numberOfFiles;
    
    try %if a file fails for any reason
        
        %% set the protocol to be analyzed
        protocolBeingAnalyzed=abfFilesInDirCell{fileNumber,3};
        path_filename = strcat(dirOfMatFiles,filenames{fileNumber});
        filename=filenames{fileNumber};
        channel=1;
        
        if isequal(abfFilesInDirCell{fileNumber,2},1)% abfFilesInDirCell{fileNumber,2}==1;
            %% load abf and consolidate to a single channel
            [rawData,si,~]=abfload(path_filename, 'sweeps','a');
            % channel=input('pick your channel:   '); %pick the channel
            %channel=1;%this is just the first channel
            data = zeros(size(rawData,1),size(rawData,3));
            for loopNumber = 1:size(rawData,3);%condense the file
                data(:,loopNumber) = rawData(:,channel,loopNumber);
            end;
            number_of_milliseconds_in_sweep=size(data,1)*(si/1000);...
                %calculate the number of milliseconds
            time = (0:number_of_milliseconds_in_sweep/(size(rawData,1)-1):...
                number_of_milliseconds_in_sweep)';%create time column
            
            
            %% phase plot
            if 1
            figure(1)
            min_of_data=min(min(data));
            max_of_data=max(max(data))+2;
            apIdx=[find(time>=60,1) find(time>=450,1)];
            sweep=50;
            derInterval=1;
            derTime=time( apIdx( 1 ):apIdx( 2 ) );
            derData=smooth(data( apIdx( 1 ):apIdx( 2 ), sweep ),5);            
            
            derMat = zeros( size( apIdx( 1 ):apIdx( 2 ), 2 ), 5 );
            derMat( :, 1 ) = apIdx( 1 ):apIdx( 2 );
            derMat( :, 2 ) = derTime;
            derMat( :, 3 ) = derData;
            derMat( 1:end-derInterval, 4 ) = diff( derData, derInterval )/( si/1000 );
            derMat( 1:end-derInterval*2, 5 ) = diff( diff( derData, derInterval ), derInterval )...
                /( si/1000 )^2;
            end
            %%
            if 0
            figure(1)
            min_of_data=min(min(data));
            max_of_data=max(max(data))+2;
            apIdx=[find(time>=60,1) find(time>=450,1)];
            sweep=45;
            derInterval=1;
            derTime=time( apIdx( 1 ):apIdx( 2 ) );
            derData=data( apIdx( 1 ):apIdx( 2 ), sweep );   
            %interpolate ddV
                interpFactor=3;
                inTime1=derTime(1);
                inTime2=derTime(end);
                inData=derData;
                inNewTime=linspace(inTime1,inTime2,max(size(derTime))*interpFactor)';
                inNewData=smooth(interp(inData,interpFactor),10);
                clf
            plot(inNewTime,inNewData)
            derTime=inNewTime;
            derData=inNewData;
            derMat = zeros( size(inNewTime,1), 5 );
            derMat( :, 1 ) = 1:size(inNewTime,1) ;
            derMat( :, 2 ) = derTime;
            derMat( :, 3 ) = derData;
            derMat( 1:end-derInterval, 4 ) = diff( derData, derInterval )/( si/1000 );
            derMat( 1:end-derInterval*2, 5 ) = diff( diff( derData, derInterval ), derInterval )...
                /( si/1000 )^2;
            clf
            plot(derMat(:,3),derMat(:,4))
            hold on
            plot(derMat(:,3),derMat(:,5))
            drawnow
            pause(.5)
%             plot(derMat(:,2),derMat(:,5))
            end
            %%
            if 0
            figure(2)
            clf
            hold on
            sfact=10;
            %plot derivative
                plot(derMat( :, 3 ),smooth(derMat( :, 4 )...
                    /500,sfact))%max(derMat( range, 4 ))
                %plot 2nd derivative
                plot(derMat( :, 3 ),smooth(derMat(:, 5 )...
                    /3000,sfact)-.25)%max(derMat( range, 5 ))
                axis([-60 50 -.5 1])
                
            title(filename);
            %print 
            if isequal(abfFilesInDirCell{fileNumber,3},1)
                printPath=[path 'phase' 'control_' filename(1:end-4) '.png'];
            else
                printPath=[path 'phase' 'cre_' filename(1:end-4) '.png'];
            end
            drawnow
            %print(printPath,'-dpng')% ,'-r100'
            
            end

            %% first five aps derivative vs time
            if 1
            dataForPeaks=derData;
            timeForPeaks=derTime;
            MPP=10;
            MPH=10;
            MPD=10;
            [peaks, locs]=PeakDetUse(dataForPeaks,timeForPeaks,MPP,MPH,MPD);
            figure(1)
            
            
            if exist('ddVmaxSheet','var')==0 || isempty(ddVmaxSheet)
                ddVmaxSheet=cell(numberOfFiles,6);
                ddVmaxSheet(:,1)=filenames;
                openvar('ddVmaxSheet');
            end
            
            if exist('ddVwidthSheet','var')==0 || isempty(ddVwidthSheet)
                ddVwidthSheet=cell(numberOfFiles,6);
                ddVwidthSheet(:,1)=filenames;
                openvar('ddVwidthSheet');
            end
                        
            clf
                        
            %limit to 5 action potentials
            if size(locs,1)>5
                apEnd=5;
            else
                apEnd=size(locs,1);
            end
            
            for ap=1:apEnd
                subplot(5,1,ap)
                ind1=find(derMat(:,2)>=locs(ap)-1.5,1);
                ind2=find(derMat(:,2)>=locs(ap)+1,1);
                range=ind1:ind2;
                [ddVmax, ddVmaxI ]= max(derMat(range,5));
                ddVmaxI=ddVmaxI+ind1-1;
                ddVmaxSheet(fileNumber,ap+1)=num2cell(ddVmax);
                
                %interpolate ddV
                interpFactor=10;
                inTime1=derMat(range(1), 2 );
                inTime2=derMat(range(end), 2 );
                inData=derMat(range, 5 );
                inNewTime=linspace(inTime1,inTime2,max(size(range))*interpFactor);
                inNewData=interp(inData,interpFactor);
                
                %find width of interpolated ddV
                try
                ddVstart=find(inNewData>=500,1);%ddVmax*.25
                ddVend=find(inNewData>=500,1,'last');
                ddVwidthSheet(fileNumber,ap+1)=num2cell(...
                    inNewTime(ddVend)-inNewTime(ddVstart)...
                    );
                catch
                end
                
                % oringal find width
%                 ddVstart=find(derMat(range,5)>=ddVmax*.25,1)+range(1);
%                 ddVend=find(derMat(range,5)>=ddVmax*.25,1,'last')+range(1);
                
%                 ddVmaxSheet(fileNumber,ap+1)=
                hold on
                %plot ap
                plot(derMat( range, 2 ),(derMat( range, 3 )-derMat( range(1), 3 ))...
                    /100)%(max(derMat( range, 3 ))-min(derMat( range, 3 )))
                %plot derivative
                plot(derMat( range, 2 ),derMat( range, 4 )...
                    /500)%max(derMat( range, 4 ))
                %plot 2nd derivative
                plot(derMat( range, 2 ),derMat(range, 5 )...
                    /3000)%max(derMat( range, 5 ))
                %plot max of 2nd derivative
                plot(derMat( ddVmaxI,2), derMat(ddVmaxI,5)...
                    /3000,'ro')
                text(derMat(range(1),2),.8,filename)
                %plot interpolated 2nd derivative
                plot(inNewTime,inNewData/3000)% interped ddV
                plot(inNewTime(ddVstart),inNewData(ddVstart)/3000,'ro');
                plot(inNewTime(ddVend),inNewData(ddVend)/3000,'ro');
                
                
                
                
                axis([derMat( range(1), 2 ) derMat( range(end), 2 ) 0 1])
                
                
                
            end
            
            
            %print 
            if isequal(abfFilesInDirCell{fileNumber,3},1)
                printPath=[path 'control_' filename(1:end-4) '.png'];
            else
                printPath=[path 'cre_' filename(1:end-4) '.png'];
            end
            
            print(printPath,'-dpng')% ,'-r100'
            
            
            %axis([-60 60 -150 400])
            drawnow
            end
            %%
%             clf
%             plot(derTime,derData)
%             printPath=[path filename(1:end-4) '.png'];
%             print(printPath,'-dpng','-r100')
                    
        end
    catch
        errorMesage=[ filename ' had and error'];
        warning(errorMesage);
    end
    
end

for iBeep=1:5
    beep
    pause(.1)
end
disp('*****done******')
