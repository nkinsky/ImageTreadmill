function bounds = sections_treadmill(x,y,direction)
%bounds = sections_treadmill(x,y,direction)
%
%

%%
    xmax = max(x); xmin = min(x);
    ymax = max(y); ymin = min(y); 
    
    w = (xmax-xmin)/7;          %Width of arms.
    cx = 1.3;                   %Constant.
    cy = 1.8;
    
    switch direction
    case 'left'
        centerY =       [ymin+cy*w      ymin+cy*w       ymin+cy*1.5*w   ymin+cy*1.5*w];
        choiceY =       [centerY(1)     centerY(1)      centerY(3)      centerY(3)];     
        approachY =     [ymin           ymin            choiceY(1)      choiceY(1)];
    end
    
    %Center arm. 
    center.x =          [xmin+w         xmax-cx*w       xmax-cx*w       xmin+w];
    center.y =          centerY; 
    
    %Choice. 
    choice.x =          [xmin           center.x(1)     center.x(1)     xmin];
    choice.y =          choiceY; 
        
    %Base.
    base.x =            [center.x(2)    xmax            xmax            center.x(2)];
    base.y =            center.y;
    
    switch direction
    case 'left'
        left.x =        center.x;
        left.y =        [ymin           ymin            ymin+w         ymin+w];
        return_l.x =    [center.x(2)    xmax            xmax            center.x(2)];
        return_l.y =    [ymin           ymin            center.y(1)     center.y(1)];

        %Approach.
        approach_l.x =  choice.x; 
        approach_l.y =  approachY;
    end
    
    %Plot trajectory. 
    plot(x,y); 
    hold on;
    
        %Plot common sections. 
        plot(   [center.x center.x(1)],         [center.y center.y(1)],         'k-',...
                [choice.x choice.x(1)],         [choice.y choice.y(1)],         'k-',...
                [approach_l.x,approach_l.x(1)], [approach_l.y approach_l.y(1)], 'k-',...
                [base.x,base.x(1)],             [base.y,base.y(1)],             'k-');
     
    %Plot sections specific to left/right.        
    switch direction
    case 'left'
        plot(   [left.x,left.x(1)],             [left.y,left.y(1)],             'k-',...
                [return_l.x,return_l.x(1)],     [return_l.y,return_l.y(1)],     'k-');

        %Build struct.
        bounds.approach_l = approach_l;
        bounds.left = left; 
        bounds.return_l = return_l;
        
        %Zeros for right arm. 
        bounds.approach_r.x = zeros(1,4);       bounds.approach_r.y = zeros(1,4); 
        bounds.right.x = zeros(1,4);            bounds.right.y = zeros(1,4);
        bounds.return_r.x = zeros(1,4);         bounds.return_r.y = zeros(1,4);
    end
    
    %Build struct. 
    bounds.base = base;
    bounds.center = center;
    bounds.choice = choice;
    bounds.direction = direction; 
    
end