function [A,Au] = SequenceGraph(animal,date,session,T,window,alpha)
%A = SequenceGraph(animal,date,session,T,window,alpha)
%
%   Constructs an adjacency matrix for a session using the following
%   algorithm:
%       1. Pick a neuron and see when it is active during treadmill run. 
%       2. Perform pairwise comparisons between other neurons to check for
%       reliable predictions within a window.
%       3. If the distribution of lags between calcium events in these two
%       neurons differs from uniform, place an edge. 
%
%   INPUTS
%       animal: Name of mouse (e.g., 'GCamp6f_45_treadmill').
%
%       date: Date of recording (e.g., '11_20_2015').
%
%       session: Session number. 
%   
%       T: Length of treadmill run. 
%
%       window: Duration of window for lag, in seconds. 
%
%       alpha: Statistical threshold.
%   
%   OUTPUT
%       A: Directed graph in the form of an adjacency matrix. 
%   
%       Au: Undirected graph. 
%       

%% Get indices of treadmill runs. 
    ChangeDirectory(animal,date,session);
        
    %Get treadmill data log. 
    TodayTreadmillLog = getTodayTreadmillLog(animal,date,2);
    TodayTreadmillLog = AlignTreadmilltoTracking(TodayTreadmillLog,TodayTreadmillLog.RecordStartTime);

    try
        load(fullfile(pwd,'TimeCells.mat')); 
    catch
        [TimeCells,ratebylap,curves,delays,x,y,time_interp,FT] = FindTimeCells(animal,date,session,T); 
    end
    
    [nNeurons,nFrames] = size(FT); 
    FT = logical(FT); 
    
    %Get indices for treadmill runs. 
    treadmillEpochs = getTreadmillEpochs(TodayTreadmillLog,time_interp);
    treadmillruns = [];
    for thisLap=1:size(treadmillEpochs,1)
        if TodayTreadmillLog.complete(thisLap) && TodayTreadmillLog.delaysetting(thisLap) == T
            treadmillruns = [treadmillruns, treadmillEpochs(thisLap,1):treadmillEpochs(thisLap,2)];
        end
    end
    
%% Setup. 
    samplingRate = 20;                          %Hertz.
    nBins = samplingRate*window;                %Number of time bins.
    [onset,~] = getFEpochs(FT);                 %Onset indices for calcium events. 
    null = randi([-nBins,nBins],1,100000);      %Null distribution for lags. 
    A = zeros(nNeurons);                        %Preallocate. 
    Au = zeros(nNeurons);                       %Undirected graph. 
    
%% Construct the graph. 
    p = ProgressBar(nNeurons);
    %For each reference neuron...
    for n=1:nNeurons
        %Get the indices of activity that co-occur with treadmill runs. 
        treadmillActivity = intersect(treadmillruns,onset{n});
        
        if ~isempty(treadmillActivity)
            %Onset plus/minus the lag.
            wBack =     treadmillActivity-nBins;
            wForward =  treadmillActivity+nBins;

            %Number of calcium onset events. 
            nEpochs = length(treadmillActivity); 
        
            %Preallocate. Reset for every reference neuron. Each cell entry
            %represents the lag at which another neuron was coincident
            %within T seconds.
            coincidistance = cell(nNeurons,1); 
            coincidistance{n} = nan;
            
            %For each reference calcium event...
            for e=1:nEpochs
                b = wBack(e);       %Index of beginning of epoch, minus lag.
                f = wForward(e);    %Index of end of epoch, plus lag.
                
                %Neurons that fire within the window of neuron n. 
                coincident = find(cellfun(@any,cellfun(@(c) c>b & c<f, onset,'unif',0)));
                coincident(coincident==n) = [];             %Remove self-coincidence.
                
                %For each neuron that fire in the window...
                for i=1:length(coincident)
                    c = coincident(i);
                    
                    %Get the lap number for each spike in the coincident
                    %cell.
                    coincidentLaps = findLap(onset{c},treadmillEpochs);
                    referenceLaps = findLap(treadmillActivity,treadmillEpochs);
                    
                    %Laps where both neurons were active.
                    commonLaps = intersect(coincidentLaps,referenceLaps);   
                    
                    %Get lags relative to each of the reference neuron's
                    %calcium events for each comparator neuron.
                    lags = onset{c}(ismember(coincidentLaps,commonLaps))-b-nBins;         
                    coincidistance{c} = [coincidistance{c}, lags(lags<nBins & lags>-nBins)]; 
                end
            end
            
            %For each neuron that was coincident...
            for i=1:length(coincident)
                c = coincident(i);

                if ~isempty(coincidistance{c})
                    %Test lag distribution against a uniform null. 
                    h = kstest2(coincidistance{c},null,'alpha',alpha);
                    
                    %Get the average lag to get its sign.
                    avgLag = mean(coincidistance{c}); 

                    %Directed graph weighted by the average number of
                    %lag frames.
                    if avgLag>0 && h
                        A(n,c) = avgLag; 
                        Au(n,c) = avgLag; Au(c,n) = avgLag;
                    elseif avgLag<0 && h
                        A(c,n) = -avgLag; 
                        Au(n,c) = -avgLag; Au(c,n) = -avgLag;
                    end
                end
            end
            
        end
        
        p.progress;
    end
    p.stop;
    
    %Save data.
    save(['A',num2str(alpha),'.mat'], 'A','Au','window');
    
end