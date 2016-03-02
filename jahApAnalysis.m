function [ deepApAnalysisColumnTitles, deepApAnalysis, derMat ] = jahApAnalysis( time, data, apIdx, sweepOfInterest, si, dirToSaveIn, filename, figureNumbers, printPlotsToFile)
    %% AP analysis
    % save('testVariables');
    % load('testVariables');
    % to protect against errors

    % test for noise
    % data=NaN(size(data2,1),size(data2,2));
    %
    % for i=1:size(data2,2)
    %     data(:,i)=smooth(data2(:,i),2);
    % end


    % derMat Structure
    % derMatColumnTitles = {'index' 'time' 'volt' 'dvolt' 'ddvolt'};
    derMat = zeros( size( apIdx( 1 ):apIdx( 2 ), 2 ), 5 );
    derMat( :, 1 ) = apIdx( 1 ):apIdx( 2 );
    derMat( :, 2 ) = time( apIdx( 1 ):apIdx( 2 ) );
    derMat( :, 3 ) = data( apIdx( 1 ):apIdx( 2 ), sweepOfInterest );
    derMat( 1:end-1, 4 ) = diff( ...
        data( apIdx( 1 ):apIdx( 2 ), sweepOfInterest ))...% added smoothing of 10 samples
        /( si/1000 ); 
    derMat( 1:end-2, 5 ) = diff( diff( ...
        data( apIdx( 1 ):apIdx( 2 ), sweepOfInterest ) ) )...% added smoothing of 10 samples
        /( si/1000 );

    % make a smoothed version of derMat
        smoothFactor = 5;
        smoothDerMat = zeros( size( apIdx( 1 ):apIdx( 2 ), 2 ), 5 );
        smoothDerMat( :, 1 ) = apIdx( 1 ):apIdx( 2 );
        smoothDerMat( :, 2 ) = time( apIdx( 1 ):apIdx( 2 ) );
        smoothDerMat( :, 3 ) = data( apIdx( 1 ):apIdx( 2 ), sweepOfInterest );
        smoothDerMat( 1:end-1, 4 ) = smooth(...
            diff( data( apIdx( 1 ):apIdx( 2 ), sweepOfInterest ) )/( si/1000 ),...
            smoothFactor);
        smoothDerMat( 1:end-2, 5 ) = smooth(...
            diff( diff( data( apIdx( 1 ):apIdx( 2 ), sweepOfInterest ) ) )/( si/1000 ), ...
            smoothFactor);

    % Threshold Measurements
    tempThresholdTime = derMat( find( derMat( :, 4 )>= 20, 1 ), 2 );
    tempThresholdVolt = derMat( find( derMat( :, 4 )>= 20, 1 ), 3 );
    tempThresholdValue = derMat( find( derMat( :, 4 )>= 20, 1 ), 4 );
    
    secondDerIndex = find( smoothDerMat( :, 5 )>= 5, 1 );
    max2ndDerTime = derMat( secondDerIndex, 2 );
    max2ndDerVolt = derMat( secondDerIndex, 3 );
    max2ndDerValue = derMat( secondDerIndex, 5 );
    
        % Catch emptyies
        if isempty(tempThresholdTime)
            tempThresholdTime = NaN;
            tempThresholdVolt = NaN;
            tempThresholdValue = NaN;
        end

        if isempty(secondDerIndex)
            secondDerIndex = NaN;
            max2ndDerTime = NaN;
            max2ndDerVolt = NaN;
            max2ndDerValue = NaN;
        end

    % Upstroke Measurements
        [ ~, tempMaxUpStrokeIndex ] = max( derMat( :, 4 ) );
        tempMaxUpStrokeIndexTime = derMat( tempMaxUpStrokeIndex, 2 );
        tempMaxUpStrokeIndexVolt = derMat( tempMaxUpStrokeIndex, 3 );
        tempMaxUpStrokeIndexValue = derMat( tempMaxUpStrokeIndex, 4 );

        tempUpStrokeAtZeroIndex = find( derMat( :, 3 ) >= 0, 1);
        tempUpStrokeAtZeroTime = derMat( tempUpStrokeAtZeroIndex, 2 );
        tempUpStrokeAtZeroVolt = derMat( tempUpStrokeAtZeroIndex, 3 );
        tempUpStrokeAtZeroValue = derMat( tempUpStrokeAtZeroIndex, 4 );
    
    % Amplitude Calculation
    [ ~, maxAmpIndex ] = max( derMat( :, 3 ) );
    maxAmpTime = derMat( maxAmpIndex, 2 );
    maxAmpVolt = derMat( maxAmpIndex, 3 );
    
    % Ap Width Calculation
    try
    halfHeight=(maxAmpVolt-tempThresholdVolt)/2+tempThresholdVolt;
    halfHeightIndex(1)=find(derMat( 1:maxAmpIndex, 3 )>=halfHeight,1);
    halfHeightIndex(2)=find(derMat( maxAmpIndex:end, 3 )<=halfHeight,1)+maxAmpIndex;
    apWidth=derMat(halfHeightIndex(2),2)-derMat(halfHeightIndex(1),2);
    catch
        halfHeight = NaN;
        halfHeightIndex = NaN(1,2);
        apWidth = NaN;
    end
    
    % Plotting
    % plot phase plot
    h = figure( figureNumbers(1) );
    set(h,'name','deep phase','numbertitle','off');
    clf
    hold on
    plot( derMat( :, 3 ), derMat( :, 4 ) );
    plot( derMat( :, 3 ), derMat( :, 5 ) );
    % plot( smoothDerMat( :, 3 ), smoothDerMat( :, 4 ) );
    % plot( smoothDerMat( :, 3 ), smoothDerMat( :, 5 ) );
    plot( tempThresholdVolt, tempThresholdValue, 'ro' );
    plot( max2ndDerVolt, max2ndDerValue, 'kx' );
    plot( tempMaxUpStrokeIndexVolt, tempMaxUpStrokeIndexValue, 'ro' );
    plot( tempUpStrokeAtZeroVolt, tempUpStrokeAtZeroValue, 'kx' );
    drawnow
    
    % plot ap and 1st and 2nd derivative
    h = figure( figureNumbers(2) );
    set( h , 'name', 'ap and der', 'numbertitle', 'off');
    clf
    hold on
    plot( derMat( :, 2 ), derMat( :, 3 ) );
    plot( derMat( :, 2 ), derMat( :, 4 ) );
    plot( derMat( :, 2 ), derMat( :, 5 ) );
    % plot( smoothDerMat( :, 2 ), smoothDerMat( :, 4 ) );
    % plot( smoothDerMat( :, 2 ), smoothDerMat( :, 5 ) );
    plot( tempThresholdTime, tempThresholdValue, 'ro' );
    plot( max2ndDerTime, max2ndDerValue, 'kx' );
    plot( tempThresholdTime, tempThresholdVolt, 'ro' );
    plot( max2ndDerTime, max2ndDerVolt, 'kx' );
    plot( tempMaxUpStrokeIndexTime, tempMaxUpStrokeIndexValue, 'ro' );
    plot( tempUpStrokeAtZeroTime, tempUpStrokeAtZeroValue, 'kx' );
    plot( tempMaxUpStrokeIndexTime, tempMaxUpStrokeIndexVolt, 'ro' );
    plot( tempUpStrokeAtZeroTime, tempUpStrokeAtZeroVolt, 'kx' );
    drawnow
    
    %% print Plots
    if printPlotsToFile==1
        %print phase plot
        figure(figureNumbers(1))
        printName=[dirToSaveIn filename ' sweep ' num2str(sweepOfInterest) ' phase plot ' '.png'];
        print(printName, '-dpng', '-r300'); %<-Save as PNG with 300 DPI
        % for emf file use '.emf' and '-dmeta' with no resolution

        % print derivative vs time plot
        figure(figureNumbers(2))
        printName=[dirToSaveIn filename ' sweep ' num2str(sweepOfInterest) ' derivative plot '  '.png'];
        print(printName, '-dpng', '-r300'); %<-Save as PNG with 300 DPI
        % Values for Output
    end
    %% assign output
        deepApAnalysisColumnTitles = {'tempThresholdVolt' 'max2ndDerVolt'...
            'tempMaxUpStrokeIndexValue' 'tempUpStrokeAtZeroValue'};
        
        % want to assign 'threshold amp width upstroke'
        deepApAnalysis = [ tempThresholdVolt maxAmpVolt ...
            apWidth tempMaxUpStrokeIndexValue ];
        
        %save('testVariables') %load('testVariables')
end





%% old way
% plot( d( apIdx( 1 ):apIdx( 2 )-1, sweepOfFirstAp ), ...
%  diff( d( apIdx( 1 ):apIdx( 2 ), sweepOfFirstAp ) )/( si/1000 ) )
% 
% plot( d( apIdx( 1 ):apIdx( 2 )-1, sweepOfFirstAp ), ...
%  smooth( diff( d( apIdx( 1 ):apIdx( 2 ), sweepOfFirstAp ) )/( si/1000 ) ) )
% 
% plot( d( apIdx( 1 ):apIdx( 2 )-2, sweepOfFirstAp ), ...
%  smooth( diff( diff( d( apIdx( 1 ):apIdx( 2 ), sweepOfFirstAp ) )/( si/1000 ) ), 10 ) )
% 
% tempThresholdIndex = find( diff( d( apIdx( 1 ):apIdx( 2 ), sweepOfFirstAp ) )/( si/1000 )>= 20, 1 )+apIdx( 1 )-1;
% plot( d( tempThresholdIndex, sweepOfFirstAp ), 20, 'kx' );
% disp( time( tempThresholdIndex ) );
% 
% [max2ndDer, secondDerIndex] = max( smooth( diff( diff( d( apIdx( 1 ):apIdx( 2 ), sweepOfFirstAp ) )/( si/1000 ) ), 10 ) );
% secondDerIndex = secondDerIndex + apIdx( 1 )-2;
% disp( time( secondDerIndex ) );
% plot( d( secondDerIndex, sweepOfFirstAp ), max2ndDer, 'kx' );
% %%
% figure( 7 )
% clf
% clc
% hold on
% 
% plot( time( apIdx( 1 ):apIdx( 2 ) ), d( apIdx( 1 ):apIdx( 2 ), sweepOfFirstAp ) )
% 
% plot( time( apIdx( 1 ):apIdx( 2 )-1 ), ...
%  diff( d( apIdx( 1 ):apIdx( 2 ), sweepOfFirstAp ) )/( si/1000 ) )
% 
% % plot( time( apIdx( 1 ):apIdx( 2 )-1 ), ...
% % smooth( diff( d( apIdx( 1 ):apIdx( 2 ), sweepOfFirstAp ) )/( si/1000 ) ) )
% 
% plot( time( apIdx( 1 ):apIdx( 2 )-2 ), ...
%  smooth( diff( diff( d( apIdx( 1 ):apIdx( 2 ), sweepOfFirstAp ) )/( si/1000 ) ), 10 ) )
% 
% tempThresholdIndex = find( diff( d( apIdx( 1 ):apIdx( 2 ), sweepOfFirstAp ) )/( si/1000 )>= 20, 1 )+apIdx( 1 )-1;
% plot( time( tempThresholdIndex ), d( tempThresholdIndex, sweepOfFirstAp ), 'kx' );
% disp( time( tempThresholdIndex ) );
% 
% [~, secondDerIndex] = max( smooth( diff( diff( d( apIdx( 1 ):apIdx( 2 ), sweepOfFirstAp ) )/( si/1000 ) ), 10 ) );
% secondDerIndex = secondDerIndex + apIdx( 1 )-2;
% disp( time( secondDerIndex ) );
% plot( time( secondDerIndex ), d( secondDerIndex, sweepOfFirstAp ), 'kx' );
% %%
% size( d( apIdx( 1 ):apIdx( 2 ), sweepOfFirstAp ) )
% size( diff( d( apIdx( 1 ):apIdx( 2 ), sweepOfFirstAp ) )/( si/1000 ) )
% size( diff( diff( d( apIdx( 1 ):apIdx( 2 ), sweepOfFirstAp ) )/( si/1000 ) ) )