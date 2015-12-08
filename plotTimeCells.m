function plotTimeCells(sessionStruct,animal,date,session,T)
%
%
%

%%
    cd(sessionStruct.Location); 
        
    %Get treadmill data log. 
    TodayTreadmillLog = getTodayTreadmillLog(animal,date,2);
    TodayTreadmillLog = AlignTreadmilltoTracking(TodayTreadmillLog,TodayTreadmillLog.RecordStartTime);

    try
        load(fullfile(sessionStruct.Location,'TimeCells.mat')); 
    catch
        [TimeCells,ratebylap,curves,delays,x,y,time_interp,FT] = FindTimeCells(sessionStruct,animal,date,session,T); 
    end
    
    [nNeurons,nFrames] = size(FT); 
    FT = logical(FT); 
    [nLaps,nBins,~] = size(ratebylap);
    
    %Get indices for treadmill runs. 
    inds = getTreadmillEpochs(TodayTreadmillLog,time_interp);
    temp = [];
    for thisLap=1:size(inds,1)
        if TodayTreadmillLog.complete(thisLap) && TodayTreadmillLog.delaysetting(thisLap) == T
            temp = [temp,inds(thisLap,1):inds(thisLap,2)];
        end
    end
    treadmillruns = logical(zeros(1,nFrames));
    treadmillruns(temp) = 1; 

%% Plot. 
    thisNeuron = 1;
    keepgoing = 1;
    bins = [1:0.001:nBins]';
    t = linspace(0,T,length(bins));
    
    while keepgoing
        smoothfit = fit([1:nBins]',curves.tuning{TimeCells(thisNeuron)}','smoothingspline');
        curves.smoothed{TimeCells(thisNeuron)} = feval(smoothfit,bins); 
        
        figure(50); 
        subplot(2,2,1);
            plot(x,y,x(treadmillruns & FT(TimeCells(thisNeuron),:)),y(treadmillruns & FT(TimeCells(thisNeuron),:)),'r.','MarkerSize',16);
            axis off;
        subplot(2,2,2); 
            imagesc([0:T],[1:5:sum(delays==T)],ratebylap(delays==T,:,TimeCells(thisNeuron)));
                colormap gray; ylabel('Laps');
        subplot(2,2,3:4);
            plot(t,curves.smoothed{TimeCells(thisNeuron)},'linewidth',2);
                xlabel('Time [s]'); ylabel('Rate'); 
                yLims = get(gca,'ylim');
                ylim([0, yLims(2)]);
                set(gca,'ticklength',[0 0]);
            
        figure(50);
            [~,~,key] = ginput(1); 

            if key == 29 && thisNeuron < nNeurons
                thisNeuron = thisNeuron + 1; 
            elseif key == 28 && thisNeuron ~= 1
                thisNeuron = thisNeuron - 1; 
            elseif key == 27
                keepgoing = 0; 
                close(figure(50)); 
            end
            
    end
end