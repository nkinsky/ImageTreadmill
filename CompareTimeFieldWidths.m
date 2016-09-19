function [xModTFWidths,iModTFWidths] = CompareTimeFieldWidths(md,plotit)
%[xModTFWidths,iModTFWidths] = CompareTimeFieldWidths(md,plotit)
%
%

%% Set up.
    cd(md.Location); 
    load('Pos_align.mat','FT'); 
    load('TimeCells.mat','TimeCells','T','TodayTreadmillLog'); 
    load('graphData_p.mat','A'); 
    
    %Make treadmill run indices even.
    inds = TodayTreadmillLog.inds; 
    inds = inds(find(TodayTreadmillLog.complete),:);
    inds(:,2) = inds(:,1) + 20*T-1; 
    
%% Partition the neurons into intrinsically and extrinsically modulated. 
    %Get sinks. 
    [~,sinks] = find(A); 
    sinks = unique(sinks); 
    nIMods = length(sinks);
    
    %Get time cells not intrinsically modulated. 
    xMod =  setdiff(TimeCells,sinks); 
    nXMods = length(xMod);
    
    %Median absolute deviation for time cells that are extrinsically
    %modulated. 
    xModTFWidths = zeros(1,nXMods);
    for x=1:nXMods
        xRaster = buildRaster(inds,FT,xMod(x));
        [~,TMAlignedOnsets] = find(xRaster);
        TMAlignedOnsets = (TMAlignedOnsets - 1) ./ 20;
        
        xModTFWidths(x) = mad(TMAlignedOnsets,1); 
    end
    
    %Median absolute deviation for intrinsically modulated cells. 
    iModTFWidths = zeros(1,nIMods);
    for i=1:nIMods
        iRaster = buildRaster(inds,FT,sinks(i));
        [~,TMAlignedOnsets] = find(iRaster);
        TMAlignedOnsets = (TMAlignedOnsets - 1) ./ 20;
    
        iModTFWidths(i) = mad(TMAlignedOnsets,1);
    end
    
    if plotit
        figure;
        %Histogram.
        subplot(2,2,1);
        hold on;
        [y,x] = hist(xModTFWidths,[0:0.1:max([xModTFWidths iModTFWidths])]);
        y = y./sum(y);                              %Normalize.
        stairs(x,y,'color','b','linewidth',2);      %Histogram.
        [y,x] = hist(iModTFWidths,[0:0.1:max([xModTFWidths iModTFWidths])]);
        y = y./sum(y);                              %Normalize.
        stairs(x,y,'color','r','linewidth',2);      %Histogram.
        ylabel('Proportion of Cells'); 
        set(gca,'ticklength',[0 0]); 
        legend({'Externally modulated','Internally modulated'});
        
        %ECDF. 
        subplot(2,2,3);
        hold on;
        [y,x] = ecdf(xModTFWidths);
        stairs(x,y,'color','b','linewidth',2); 
        [y,x] = ecdf(iModTFWidths);
        stairs(x,y,'color','r','linewidth',2); 
        xlabel('MAD of Temporal Field [s]'); 
        ylabel('Cumulative Proportion of Cells'); 
        set(gca,'ticklength',[0 0]); 
        
        %Bar plot. 
        xModMean = mean(xModTFWidths);  xJitter = 1-(0.1*randn(nXMods,1));
        iModMean = mean(iModTFWidths);  iJitter = 2-(0.1*randn(nIMods,1));
        xSEM = std(xModTFWidths)/sqrt(nXMods);
        iSEM = std(iModTFWidths)/sqrt(nIMods); 
        
        subplot(2,2,[2,4]); 
        hold on;
        bar(1,xModMean,'facecolor','w','linewidth',2,'edgecolor','b');
        bar(2,iModMean,'facecolor','w','linewidth',2,'edgecolor','r');
       
        %Scatter individual points. 
        scatter([xJitter; iJitter],[xModTFWidths'; iModTFWidths'],15,...
            'markeredgecolor',[0.7 0.7 0.7]);
        errorbar(1,xModMean,xSEM,'b','linewidth',2);
        errorbar(2,iModMean,iSEM,'r','linewidth',2);
        set(gca,'xtick',[1 2],...
            'xticklabel',{'Externally modulated','Internally modulated'},...
            'ticklength',[0 0]);
        ylabel('MAD of Temporal Field [s]');
        
    end
end