%% jahAnova
% this is a simple set up that tests equality of variance and then tests
% using either a one way anova or a kruskal-wallis one way anova on ranks
%
%% set up data
jahCleanUp

myGroups=[];%put in the treatment number 1, 2, 4, or 5
myData=cell(1,1); % add excel data here
groupsToTest=[1 4 1 ; 2 5 4 ]; % which groups will be tested 1 vs 2, 4 vs 5, 1 vs 4

openvar('myGroups')
openvar('myData')

%% run test, each group then each measurement
clc


% make the myResult variable equal to a 3 by n matrix where n is the number
% of measurments in myData
myResult=cell(6,size(myData,2));
openvar('myData')

% run through vars
iGroupToRun=1:3;
iDataToRun=1:size(myData,2);

%run through con vs ttap, con vs tle, tle vs ttap
for iGroup=iGroupToRun
    
    groupA=groupsToTest(1,iGroup);
    groupB=groupsToTest(2,iGroup);
    
    indexA=find(myGroups==groupA);
    indexB=find(myGroups==groupB);
    
    for iData=iDataToRun

        try
        
            % if there are any empty data or char cells 
            % exclude their index from 'myGroup'
                index2remove=cellfun(@isempty,myData(indexA,iData));
                tempIndexA=indexA(index2remove==0);
                    index2remove=cellfun(@ischar,myData(tempIndexA,iData));
                    tempIndexA=tempIndexA(index2remove==0);

                index2remove=cellfun(@isempty,myData(indexB,iData));
                tempIndexB=indexB(index2remove==0);
                    index2remove=cellfun(@ischar,myData(tempIndexB,iData));
                    tempIndexB=tempIndexB(index2remove==0);
                    
                    
            % make the anova data into the subset of data for each measurement
            % of the selected groups (a and b)
                anovaData=[cell2mat(myData(tempIndexA,iData));cell2mat(myData(tempIndexB,iData))];
                anovaGroup=[myGroups(tempIndexA,1);myGroups(tempIndexB,1)];    
            
            % test if data is non parametric
            % One-sample Kolmogorov-Smirnov test
                try 
                    kstestResultA=kstest(cell2mat(myData(tempIndexA,iData)));
                catch
                    kstestResultA=0;
                end
                try 
                    kstestResultB=kstest(cell2mat(myData(tempIndexA,iData)));
                catch
                    kstestResultB=0;
                end

                kstestTotal=kstestResultA+kstestResultB;
                    
                    
            % if equal variance use anova else use kruskal-wallis one way
            % anova on ranks
            % vartest2 is a Two-sample F-test for equal variances
            if vartest2(cell2mat(myData(tempIndexA,iData)),cell2mat(myData(tempIndexB,iData)))== 0%equal variance
                
                [p,tbl,stats]=anova1(anovaData,anovaGroup,'off');
                myResult{iGroup,iData}=p;
                myResult{iGroup+3,iData}='anova';
                %myResultStruct(iGroup,iData)=struct('p',p,'tbl',tbl,'stats',stats);
            
            elseif vartest2(cell2mat(myData(tempIndexA,iData)),cell2mat(myData(tempIndexB,iData)))== 1 %equal variance
               
                p = kruskalwallis(anovaData,anovaGroup,'off');
                myResult{iGroup,iData}=p;
                myResult{iGroup+3,iData}='kruskal';
                
            end
            
%             if kstestTotal>0 % add 'not gaussian' to the test description if group A or B wasn't gaussian
%                 myResult{iGroup+3,iData}=[myResult{iGroup+3,iData} ': not gaussian'] ;
%             end
%             
%             try % makes sure not to have cells that just say 'not gaussian'
%                 if isempty(myResult{iGroup,iData})==1% isempty(myResult{3,ta})==1
%                 myResult{iGroup+3,iData}=[];
%                 end
%             catch
%             end
            
        catch
            myResult{iGroup,iData}='failed';
            myResult{iGroup+3,iData}='failed';
        end
    end
end
openvar('myResult')
disp('done')