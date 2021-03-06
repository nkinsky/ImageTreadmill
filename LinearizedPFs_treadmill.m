function [rate,normRates,sortedRates,order,X,edges] = LinearizedPFs_treadmill(MD)
%[normRate,sortedRate] = LinearizedPFs_treadmill(MD,FT)
%
%   Linearizes trajectory then computes place fields by binning FT
%   responses in space. 
%
%   INPUTS
%       MD: Session entry. 
%
%       FT: Output from Tenaspis. Can be a subset of the full neuron base. 
%
%   OUTPUTS
%       normRate: Normalized responses, non-sorted.
%
%       sortedRate: Same as normRate, but sorted by peak. 
%

%% Preliminary. 
    %Go to directory. 
    currdir = pwd; 
    cd(MD.Location); 
    
    %Get treadmill log for excluding treadmill epochs. 
    load('TimeCells.mat','TodayTreadmillLog'); 
    d = TodayTreadmillLog.direction; 
    
    %Find direction for linearizing trajectory. 
    if strfind(d,'left')
        mazetype = 'left';
    elseif strfind(d,'right')
        mazetype = 'right';
    elseif strfind(d,'alternation')
        mazetype = 'tmaze';
    end
    
    %Some parameters. 
    nBins = 80;     %Spatial bins.
    minspeed = 3;   %Speed threshold (cm/s). 
    
    %Load aligned position data. 
    load(fullfile(pwd,'Pos_align.mat'),'x_adj_cm','y_adj_cm','speed','time_interp','PSAbool');
    x=x_adj_cm; y=y_adj_cm; PSAbool=logical(PSAbool); clear x_adj_cm y_adj_cm;
    [nNeurons,nFrames] = size(PSAbool); 
    
    %Exclude treadmill epochs. 
    inds = TodayTreadmillLog.inds;
    i=[];
    for e=1:size(inds,1)
        i = [i,inds(e,1):inds(e,2)];
    end
    onTM = logical(zeros(1,nFrames)); 
    onTM(i) = true; 
    
    %Speed threshold. 
    isrunning = speed>minspeed; 
    
%% Linearize trajectory and bin responses spatially.
    %Linearized trajectory. 
    X = LinearizeTrajectory_treadmill(x,y,mazetype); 

    %Occupancy map. 
    [occ,edges] = histcounts(X,nBins); 
    
    %Bin spatial responses. 
    rate = nan(nNeurons,nBins);
    for n=1:nNeurons
        spkpos = X(PSAbool(n,:) & isrunning & ~onTM);
        
        binned = histcounts(spkpos,edges);
        
        rate(n,:) = binned ./ occ; 
    end
    

    
    %Find peak and normalize. 
    [peak,inds] = max(rate,[],2);     
    normRates = bsxfun(@rdivide,rate,peak);
      
    %Smooth. 
    sm = fspecial('gaussian'); 
    parfor n=1:nNeurons
        normRates(n,:) = imfilter(normRates(n,:),sm);
    end
    
    load(fullfile(pwd,'Placefields.mat'),'pval');
    load(fullfile(pwd,'PlacefieldStats.mat'),'PFnHits','bestPF');
    load(fullfile(pwd,'SpatialInfo.mat'),'MI'); 
    idx = sub2ind(size(PFnHits),1:size(PFnHits,1),bestPF');
    PCcrit = .01;
    PCs = pval<PCcrit & MI'>0 & PFnHits(idx)>4; 
    
    %Sort. 
    [~,order] = sort(inds(PCs)); 
    sortedRates = normRates(PCs(order),:);
    
    cd(currdir); 
end
    