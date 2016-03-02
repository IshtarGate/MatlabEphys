function IhyStats = jahIhyStats(d,sweepOfFirstAp,IhyROIs)
IhyStats=cell(1,88);
for loopNumber=1:size(d,2)
    
    IhyRMP=mean(d(IhyROIs(1):IhyROIs(2),loopNumber));
    IhyStats{loopNumber}=IhyRMP;
    
    IhyVarState=min(d(IhyROIs(3):IhyROIs(4),loopNumber));
    IhyStats{loopNumber+22}=IhyVarState;
    
    IhySteadyState=mean(d(IhyROIs(5):IhyROIs(6),loopNumber));
    IhyStats{loopNumber+44}=IhySteadyState;

    if loopNumber<sweepOfFirstAp
        IhyADPheight=max(d(IhyROIs(7):IhyROIs(8),loopNumber));
    else
        IhyADPheight=NaN;
    end
    IhyStats{loopNumber+66}=IhyADPheight;
end