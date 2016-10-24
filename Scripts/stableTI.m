%Full data set.
fulldataset = [MD(215:2:221) MD(253:256) MD(274:278) MD(287:291)];
nAnimals = length(unique({fulldataset.Animal})); 
colors = parula(nAnimals);

%Partition temporal information scores into stable vs unstable based on
%time field or place field correlation.
[stblTimeI,stblTimeN] = COMPILETIs(fulldataset,'time'); 
[stblPlaceI,stblPlaceN] = COMPILETIs(fulldataset,'place'); 

%Stable time fields.
sI_t = cell2mat(stblTimeI.stable')';
usI_t = cell2mat(stblTimeI.unstable')';
grps_t = [zeros(1,length(sI_t)), ones(1,length(usI_t))];
animalColors_t_stable = nan(length(sI_t),3);
animalColors_t_unstable = nan(length(usI_t),3); 
s = 1;
u = 1;
for a = 1:nAnimals
    animalColors_t_stable(s:s+stblTimeN.stable(a)-1,:) = repmat(colors(a,:),...
        stblTimeN.stable(a),1);
    animalColors_t_unstable(u:u+stblTimeN.unstable(a)-1,:) = repmat(colors(a,:),...
        stblTimeN.unstable(a),1); 
    
    s = s+stblTimeN.stable(a);
    u = u+stblTimeN.unstable(a);
end
    
%Stable place fields.
sI_p = cell2mat(stblPlaceI.stable')';
usI_p = cell2mat(stblPlaceI.unstable')';
grps_p = [zeros(1,length(sI_p)), ones(1,length(usI_p))];
animalColors_p_stable = nan(length(sI_p),3);
animalColors_p_unstable = nan(length(usI_p),3); 
s = 1; 
u = 1;
for a = 1:nAnimals
    animalColors_p_stable(s:s+stblPlaceN.stable(a)-1,:) = repmat(colors(a,:),...
        stblPlaceN.stable(a),1);
    animalColors_p_unstable(u:u+stblPlaceN.unstable(a)-1,:) = repmat(colors(a,:),...
        stblPlaceN.unstable(a),1); 
    
    s = s+stblPlaceN.stable(a);
    u = u+stblPlaceN.unstable(a);
end

fPos = [520 350 300 450];
boxScatterplot([sI_t,usI_t],grps_t,'xLabels',{'Stable','Unstable'},...
    'yLabel','Temporal Information [bits/sec]','position',fPos,...
    'circleColors',[animalColors_t_stable;animalColors_t_unstable]);
 
boxScatterplot([sI_p,usI_p],grps_p,'xLabels',{'Stable','Unstable'},...
    'yLabel','Temporal Information [bits/sec]','position',fPos,...
    'circleColors',[animalColors_p_stable;animalColors_p_unstable]);
