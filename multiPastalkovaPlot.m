function multiPastalkovaPlot(mapMD,base,comp,Ts)
%multiPastalkovaPlot(batch_session_map,base,comp,Ts)
%
%   Makes a figure with Pastalkova plots for multiple days ranking each
%   plot the same way as the sorted plot for the 'base' session. 
%
%   INPUTS
%       batch_session_map: from neuron_reg_batch.
%
%       base: MD entry for which you want sorted time cells. 
%
%       comp: MD entries for other sessions. This function will reference
%       batch_session_map and find the same neurons as the time cells in
%       'base'. Then it will plot those neurons' tuning curves sorted in
%       the same order as in 'base'.
%
%       Ts: Vector of delay durations. Must be same length as base+comp. 
%

%% Preliminary steps. 
    cd(mapMD.Location); load(fullfile(pwd,'batch_session_map.mat')); 
    
    sessions = [base,comp];             %Concatenate sessions. 
    dates = {sessions.Date};            %Dates
    sessionNums = [sessions.Session];   %Session numbers.
    nSessions = length(sessions);       %Number of sessions. 
    
    %Get time cell indices and tuning curves. 
    [TIMECELLS,~,CURVES] = CompileTimeCellData(sessions,Ts); 
    nTimeCells = length(TIMECELLS{1});
    
    %Find chronological order of dates. 
    d = datenum({sessions.Date},'mm_dd_yyyy');
    sorted = sort(d);
    [~,dateOrder] = ismember(d,sorted); 
    
    %For plot titles. 
    dateTitles = dates;
    for i=1:nSessions
        dateTitles{i}(3:3:6) = '-';
    end

%% Find relevant indices in batch_session_map. 
    %Find the columns in MAP 
    [MAP,MAPcols] = FilterMAPDates(batch_session_map,dates,sessionNums);
    
    %Find row indices from the batch_session_map that correspond to time
    %cells in base. 
    MAProws = find(ismember(MAP(:,MAPcols(1)),TIMECELLS{1}));
    
%% Create the figure. 
    %Number of time bins for each session.
    nBins = zeros(nSessions,1); 
    for i=1:nSessions
        nBins(i) = length(CURVES{i}.tuning{1}); 
    end
     
    f = figure('Position',[170 260 1280 460]); 
    for i=1:nSessions
        if i==1         %For the base session...
            %Get the index that references FT from MAP. 
            neurons = MAP(MAProws,MAPcols(i)); 
            missing = neurons==0;
            
            %Matrix with responses that tile delay. 
            tilemat = zeros(length(neurons),length(CURVES{i}.tuning{1}));
                  
            %Fill in matrix. 
            tilemat(~missing,:) = cell2mat(CURVES{i}.tuning(neurons(~missing)));  
            
            %Find peaks and where they are. Then normalize to peaks and
            %sort based on peaks. 
            [peaks,peakInds] = max(tilemat,[],2); 
            normtilemat = tilemat./repmat(peaks,1,nBins(i)); 
            [~,order] = sort(peakInds); 
            normtilemat = normtilemat(order,:); 
            
            %Plot. 
            subplot(1,nSessions,dateOrder(i)); 
            imagesc([0:Ts(i)],[1:5:nTimeCells],normtilemat); 
            colormap gray; xlabel('Time [s]'); title(dateTitles{i});            
        else %Almost the same as above. 
            %Preallocate. 
            tilemat = zeros(length(neurons),length(CURVES{i}.tuning{1}));
            
            %Get the index that references FT from MAP, but in the order
            %specified by above. 
            neurons = MAP(MAProws(order),MAPcols(i)); 
            missing = neurons==0;
            
            %Fill in matrix. 
            tilemat(~missing,:) = cell2mat(CURVES{i}.tuning(neurons(~missing)));         
            
            %Normalize. 
            peaks = max(tilemat,[],2); 
            normtilemat = tilemat./repmat(peaks,1,nBins(i)); 
            
            %Plot. 
            subplot(1,nSessions,dateOrder(i))
            imagesc([0:Ts(i)],[1:5:nTimeCells],normtilemat);
            colormap gray; xlabel('Time [s]'); title(dateTitles{i});
        end
        
        %Label y axis on first plot. 
        if dateOrder(i)==1, ylabel('Neurons'); end
    end
        
    set(f,'PaperPositionMode','auto');         
    set(f,'PaperOrientation','landscape');
end