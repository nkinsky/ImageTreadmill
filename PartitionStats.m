function [STATS,nNeurons,stable,unstable] = PartitionStats(mds,stabilityCriterion,statType)
%[AllI,nNeurons,stable,unstable] = PartitionStats(mds,celltype,infotype)
%
%   Partitions an arbitrary neuron statistic based on stability in the
%   domain specified by stabilityCriterion.
%
%   INPUTS
%       mds: Session entries which you want the information content for.
%
%       celltype: 'time' or 'space' to select which criterion you want to
%       use for stability. 
%
%       infotype: Information in either the 'time' or 'space' dimension.
%
%   OUTPUTS
%       AllI: Struct with fields stable or unstable each being a cell array
%       with entries for each session containing the information content of
%       cells that are either stable or unstable. 
%
%       nNeurons:
%
%       stable & unstable: NEED TO FIX. GETS OVERWRITTEN IN FOR LOOP.

%% Set up.
    animals = unique({mds.Animal});
    nAnimals = length(animals); 

%% Compile
    STATS.stable = cell(1,nAnimals);
    STATS.unstable = cell(1,nAnimals);
    nNeurons.stable = zeros(1,nAnimals); 
    nNeurons.unstable = zeros(1,nAnimals);
    for a = 1:nAnimals
        nStable = 0; 
        nUnstable = 0;
        STATS.stable{a} = [];
        STATS.unstable{a} = [];
        
        %Get all the sessions for this animal.
        ssns = find(strcmp(animals{a},{mds.Animal})); 
        for s = ssns(1:end-1)
            cd(mds(s).Location);
            
            if strcmp(statType,'TI')
                load('TemporalInfo.mat','MI','Ispk','Isec');
                stat = MI; 
            elseif strcmp(statType,'SI')
                load('SpatialInfo.mat','MI','Ispk','Isec');
                stat = MI;
            elseif strcmp(statType,'FR')
%                 load('Pos_align.mat','FT');
%                 [n,f] = size(FT);
%                 d = diff([zeros(n,1) FT],1,2);
%                 d(d<0) = 0;
%                 stat = sum(d,2)./f; 
                load(fullfile(pwd,'TimeCells.mat'),'TodayTreadmillLog','T');
                load(fullfile(pwd,'Pos_align.mat'),'FT');
                inds = TrimTrdmllInds(TodayTreadmillLog,T);
                n = size(FT,1);
                rasters = cell(1,n);
                stat = zeros(n,1);
                for nn=1:n
                    rasters{nn} = buildRaster(inds,FT,nn,'onsets',false);
                    stat(nn) = sum(rasters{nn}(:))./numel(rasters{nn});
                end
            end
            load('TimeCells.mat','TimeCells');
            load('PlaceMaps.mat','pval');
            load('PFstats.mat','PFnumhits','PFpcthits','MaxPF');
            
            pval = 1 - pval;
            %[~,crit] = fdr_bh(pval(pval~=1));
            crit = .01;
            
            %Get all time cells with a viable place field. 
            idx = sub2ind(size(PFnumhits), 1:size(PFnumhits,1), MaxPF);
            noi = intersect(TimeCells,find(pval<crit & PFnumhits(idx) > 4));
            %noi = find(pval>.95 & PFnumhits(idx) > 4 & PFpcthits(idx) > .1);
            
            if strcmp(stabilityCriterion,'time')
                %Get correlation coefficients and p-values. 
                corrStats = CorrTrdmllTrace(mds(s),mds(s+1),noi);
                tuningStatus = TCRemap(mds(s),mds(s+1));

                %Stable time cells based on correlation and non-shifting time
                %field.
                stable = find(corrStats(:,2) < .05 & tuningStatus(:,2) > 0);
                unstable = find(corrStats(:,2) > .05 | tuningStatus(:,2) < 1);
         
            elseif strcmp(stabilityCriterion,'place')
                %Get the correlation coefficients and p-values.
                corrStats = CorrPlaceFields(mds(s),mds(s+1),noi);

                %Stable place cells based on correlation p-value.
                stable = find(corrStats(:,2) <= .05); 
                unstable = find(corrStats(:,2) > .05);     
            end
           
            %Get number of stable and unstable cells. Add this one per
            %session but track the number per animal. 
            nStable = nStable + length(stable); 
            nUnstable = nUnstable + length(unstable); 
            
            %Get the temporal information values. 
            STATS.stable{a} = [STATS.stable{a}; stat(stable)];
            STATS.unstable{a} = [STATS.unstable{a}; stat(unstable)];
        end
        
        %Get number of neurons that are (un)stable per animal. 
        nNeurons.stable(a) = nStable; 
        nNeurons.unstable(a) = nUnstable;
    end
    
end
        
        