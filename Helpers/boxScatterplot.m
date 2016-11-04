function boxScatterplot(x,grps,varargin)
%boxScatterplot(x,grps,varargin)
%
%   I usually like to plot individual data points on top of boxplots so
%   this function does that by separating your x vector into grps and then
%   jittering the data points to overlay. 
%
%   INPUTS
%       x: vector of data points to plot.
%
%       grps: grouping vector the same size as x. Each value indicates
%       which group each value of x belongs to. 
%
%       NAME,VALUE arguments:
%           xLabels: cell array of strings specifying the group names, must
%           be in the same order as grps (i.e., the min of grps must be the
%           first string in xLabels and the max of grps must be the last. 
%           
%           yLabel: string specifying y axis label. 
%
%           boxColor: string or RGB value specifying what color you want
%           the boxplot to be.
%
%           circleSize: scalar or vector specifying scatter plot circle
%           sizes. 
%
%           circleColors: string or RGB values specifying what color you
%           want all or individual circles in the scatter plot to be.
%       
%           transparency: scalar specifying how transparent you want the
%           circles to be. 1 is opaque, 0 is completely transparent. 
%
%           sf: spread factor, scalar specifying how wide you want the
%           individual data points to be jittered. 
%
%           position: vector specifying the position of the figure. 
%

%% Set up. 
    p = inputParser; 
    p.addRequired('x',@(x) isnumeric(x));
    p.addRequired('grps',@(x) isnumeric(x));
    p.addParameter('xLabels',{'Group 1','Group 2'},@(x) iscell(x));
    p.addParameter('yLabel','Metric',@(x) ischar(x)); 
    p.addParameter('boxColor','k',@(x) ischar(x) || isnumeric(x));
    p.addParameter('circleSize',10,@(x) isnumeric(x)); 
    p.addParameter('circleColors',[.7 .7 .7],@(x) ischar(x) || isnumeric(x));
    p.addParameter('transparency',.5,@(x) isscalar(x)); 
    p.addParameter('sf',.05,@(x) isscalar(x));
    p.addParameter('position',[520 350 300 450],@(x) isnumeric(x)); 
    
    p.parse(x,grps,varargin{:});
    xLabels = p.Results.xLabels; 
    yLabel = p.Results.yLabel; 
    boxColor = p.Results.boxColor;
    circleSize = p.Results.circleSize;
    transparency = p.Results.transparency;
    circleColors = p.Results.circleColors;
    sf = p.Results.sf; 
    position = p.Results.position;
    
    %Turn into column.
    if size(x,1) < size(x,2) 
        x = x';
    end
    
    if size(grps,1) < size(grps,2)
        grps = grps'; 
    end
    
    %Number of values. 
    n = numel(x);
%% Make figure. 
    %Group numbers. 
    grpNums = unique(grps)';
    jitters = zeros(n,1); 
    
    %Create jitter. 
    i = 1; 
    c = 1; 
    for g = grpNums
        %Number of elements corresponding to that group. 
        nInGrp = sum(grps==g);
        
        %Jitter!
        jitters(c:c+nInGrp-1) = i - (sf*randn(nInGrp,1));
        
        %Step. 
        i = i+1;
        c = c+nInGrp; 
    end
    
    %Figure here. 
    figure('Position',position); hold on;
    scat = scatter(jitters,x,circleSize,circleColors,'filled');
    alpha(scat,transparency);
    boxplot(x,grps,'color',boxColor,'symbol','k','labels',xLabels);
    ylabel(yLabel);
    set(gca,'tickdir','out');
    
end