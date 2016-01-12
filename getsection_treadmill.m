function [sect,x,y] = getsection_treadmill(x,y,bounds)
%function [sect, goal] = getsection(x,y,...)
%   This function takes position data and transforms it into section
%   number. 
%
%   X and Y are vectors indicating the mouse position.
%
%   OUTPUTS 
%   SECT is X x 2 vector where col1 is the frame # and col2 is section #: 
%       1. Base
%       2. Center
%       3. Choice
%       4. Left approach
%       5. Left
%       6. Left return
%       7. Right approach
%       8. Right
%       9. Right return

    
%% Get relevant section coordinates.
    xmin = [bounds.base.x(1);               
            bounds.center.x(1);
            bounds.choice.x(1);
            bounds.approach_l.x(1);
            bounds.left.x(1); 
            bounds.return_l.x(1); 
            bounds.approach_r.x(1);
            bounds.right.x(1); 
            bounds.return_r.x(1)]; 
        
    xmax = [bounds.base.x(3);
            bounds.center.x(3);
            bounds.choice.x(3);
            bounds.approach_l.x(3);
            bounds.left.x(3); 
            bounds.return_l.x(3); 
            bounds.approach_r.x(3);
            bounds.right.x(3); 
            bounds.return_r.x(3)]; 
        
    ymin = [bounds.base.y(1);               
            bounds.center.y(1);
            bounds.choice.y(1);
            bounds.approach_l.y(1);
            bounds.left.y(1); 
            bounds.return_l.y(1); 
            bounds.approach_r.y(1);
            bounds.right.y(1); 
            bounds.return_r.y(1)]; 
        
    ymax = [bounds.base.y(3);               
            bounds.center.y(3);
            bounds.choice.y(3);
            bounds.approach_l.y(3);
            bounds.left.y(3); 
            bounds.return_l.y(3); 
            bounds.approach_r.y(3);
            bounds.right.y(3); 
            bounds.return_r.y(3)]; 
        
%% Find mouse's current section. 
    %Preallocate section column. 
    sect = nan(length(x),1); 
    
    for this_section = 1:9
        ind =   x >= xmin(this_section)  &   x <= xmax(this_section)    & ...
                y >= ymin(this_section)  &   y <= ymax(this_section);
        sect(ind) = this_section; 
    end
    
end