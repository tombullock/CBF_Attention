%{
CBF_Stats_Control
Author: Tom Bullock
Date: 12.09.20

Run stats on averaged CBF data

All data condition order is the same as in updated Fig. 5 plots

%}

clear
close all

% seed rng
rng('shuffle')

% set dirs
sourceDir = '/home/bullock/CBF_Attention/Data_Compiled';
destDir = sourceDir;

% load data
load([sourceDir '/' 'BBT_Master_Averaged_Data_Control.mat'])



% loop through different datasets and run analyses
for iData=[1,2,4,5,3,6]
    
    % which data?
    if iData==1
        observedData = mean_MCAv(1:9,:);
    elseif iData==2
        observedData = mean_PCAv(1:9,:);
    elseif iData==4
        observedData = mean_MCA_CVC;
    elseif iData==5
        observedData = mean_PCA_CVC;
    elseif iData==3
        observedData = mean_pc_CBFv_PCA_MCA(1:9,:);
    elseif iData==6
        observedData = mean_pc_CVC_PCA_MCA;
    end
    
%     % remove sj idx 12 from all conditions (missing data in some)
%     if length(observedData)==12
%         observedData(12,:) = [];
%     end
    
    
    % name variables
    if ismember(iData,[1,2,4,5])
        var1_name = 'gas'; % gas cond
        var1_levels = 2;
        var2_name = 'phase'; % rest or task phase
        var2_levels = 2;
    elseif ismember(iData,[3,6])
        var1_name = 'gas'; % gas cond
        var1_levels = 2;
        var2_name = 'artery'; % artery 
        var2_levels = 2;
    end
    
        
    
    
    % generate resampled iterations for ANOVA/t-tests
    for j=1:1000
        
        for i=1:size(observedData,1)    % for each row of the observed data
            thisPerm = randperm(size(observedData,2)); % shuffle colums for each row
            for k=1:length(thisPerm)
                nullDataMat(i,k,j) = observedData(i,thisPerm(k));
            end
        end
        
        % do ANOVA on permuted data for each new iteration
        statOutput = teg_repeated_measures_ANOVA(nullDataMat(:,:,j),[var1_levels var2_levels],{var1_name, var2_name});  % run ANOVA
        var1.fValsNull(j,1) = statOutput(1,1);   % create column vectors of null F-values
        var2.fValsNull(j,1) = statOutput(2,1);
        varInt.fValsNull(j,1) = statOutput(3,1);
        
        clear statOutput
        
        % get post-hoc null t value distribution (only makes sense to create
        % one null distribution for all combinations of tests, given within
        % subjects column shuffling method)
        [H,P,CI,STATS] = ttest(nullDataMat(:,1,j),nullDataMat(:,2,j));
        tValsNull(j,1) = STATS.tstat;
        clear STATS
        
    end
    
    % run ANOVA on observed data
    statOutput = teg_repeated_measures_ANOVA(observedData,[var1_levels var2_levels],{var1_name, var2_name});
    % get fvalues
    var1.fValObserved = statOutput(1,1);
    var2.fValObserved = statOutput(2,1);
    varInt.fValObserved = statOutput(3,1);
    % get effect sizes
    var1.partialEtaSq = statOutput(1,7);
    var2.partialEtaSq = statOutput(2,7);
    varInt.partialEtaSq = statOutput(3,7);
    % get dfs
    var1.df = statOutput(1,[2,3]);
    var2.df = statOutput(2,[2,3]);
    varInt.df = statOutput(3,[2,3]);
    
    clear statOutput
    
    % sort null f-values, get index value and convert to percentile (VAR_1)
    var1.NAME = var1_name;
    var1.LEVELS = var1_levels;
    var1.fValsNull = sort(var1.fValsNull(:,1),1,'descend');
    [c var1.fValueIndex] = min(abs(var1.fValsNull - var1.fValObserved));
    var1.fValueIndex = var1.fValueIndex/1000;
    var1.pValueANOVA = var1.fValueIndex;
    
    % sort null f-values, get index value and convert to percentile (VAR_2)
    var2.NAME = var2_name;
    var2.LEVELS = var2_levels;
    var2.fValsNull = sort(var2.fValsNull(:,1),1,'descend');
    [c var2.fValueIndex] = min(abs(var2.fValsNull - var2.fValObserved));
    var2.fValueIndex = var2.fValueIndex/1000;
    var2.pValueANOVA = var2.fValueIndex;
    
    % sort null f-values, get index value and convert to percentile (VAR INTER)
    varInt.NAME = 'INTERACTION';
    varInt.LEVELS = [num2str(var1_levels) '-by-' num2str(var2_levels)];
    varInt.fValsNull = sort(varInt.fValsNull(:,1),1,'descend');
    [c varInt.fValueIndex] = min(abs(varInt.fValsNull - varInt.fValObserved));
    varInt.fValueIndex = varInt.fValueIndex/1000;
    varInt.pValueANOVA = varInt.fValueIndex;
    
    clear cohens_d
    
    % only to t-tests on certain datasets
    if ismember(iData,[1,2,4,5])
        
        % do t-tests on observed data
        for iTest=1:2
            if       iTest==1; thisPair=[1,3]; % hv RvT
            elseif   iTest==2; thisPair=[2,4]; % hpo RvT
            end
            
            [H,P,CI,STATS] = ttest(observedData(:,thisPair(1)),observedData(:,thisPair(2)));
            tValsObs(1,iTest) = STATS.tstat;
            cohens_d(iTest)=computeCohen_d(observedData(:,thisPair(1)),observedData(:,thisPair(2)),'paired');
            
            
            % compute descriptives for % change
            pairPc = ((observedData(:,thisPair(2)) - observedData(:,thisPair(1)))./observedData(:,thisPair(1)))*100;
            pairPcDescriptives(iTest,1) = mean(pairPc);
            pairPcDescriptives(iTest,2) = std(pairPc)/sqrt(size(pairPc,1));
            
            % compute dfs
            tValsObs(2,iTest) = STATS.df;
            clear STATS
        end
        
        % sort null f-values, get index value and convert to percentile
        tValsNull = sort(tValsNull(:,1),1,'descend');
        
        % compare observed t values with the distribution of null t values
        [c tValueIndex(1)] = min(abs(tValsNull - tValsObs(1,1)));
        [c tValueIndex(2)] = min(abs(tValsNull - tValsObs(1,2)));
        
        % convert to percentiles
        tValueIndex = tValueIndex./1000;
        pValuesPairwise = tValueIndex;
        
        % add pnull values to tValsObs for easy viewing
        tValsObs(3,:) = pValuesPairwise;
        
        % critical t score
        tmpA = tValsNull(25);
        tmpB = tValsNull(975);
        
        if tmpA<0
            tCriticalNeg = tmpA;
            tCriticalPos = tmpB;
        else
            tCriticalNeg = tmpB;
            tCriticalPos = tmpA;
        end
        
        
        % compare critical t score to distribution and present 0 (ns) or 1(sig)
        % values in output
        for i=1:2
            if tValsObs(1,i)<0 && tValsObs(1,i)<tCriticalNeg
                tValsObs(4,i)=1;
            elseif tValsObs(1,i)>0 && tValsObs(1,i)>tCriticalPos
                tValsObs(4,i)=1;
            else
                tValsObs(4,i)=0;
            end
        end
        
        % add cohens d effect sizes into tValsObs matrix
        tValsObs(5,:) = cohens_d;
        
    else
        
        % compute 1 sample t-tests against zero for both arteries vols
        [H,P,CI,STATS] = ttest(observedData);
        tValsObs = H;
        
    end
    
    
    % save data
    if iData==1
        MCAv_Stats.ANOVA.var1 = var1;
        MCAv_Stats.ANOVA.var2 = var2;
        MCAv_Stats.ANOVA.varInt = varInt;
        MCAv_Stats.Pairwise.t = tValsObs;
        MCAv_Stats.pairPcDescriptives = pairPcDescriptives;
    elseif iData==2
        PCAv_Stats.ANOVA.var1 = var1;
        PCAv_Stats.ANOVA.var2 = var2;
        PCAv_Stats.ANOVA.varInt = varInt;
        PCAv_Stats.Pairwise.t = tValsObs;
        PCAv_Stats.pairPcDescriptives = pairPcDescriptives;
    elseif iData==4
        MCAc_Stats.ANOVA.var1 = var1;
        MCAc_Stats.ANOVA.var2 = var2;
        MCAc_Stats.ANOVA.varInt = varInt;
        MCAc_Stats.Pairwise.t = tValsObs;
        MCAc_Stats.pairPcDescriptives = pairPcDescriptives;
    elseif iData==5
        PCAc_Stats.ANOVA.var1 = var1;
        PCAc_Stats.ANOVA.var2 = var2;
        PCAc_Stats.ANOVA.varInt = varInt;
        PCAc_Stats.Pairwise.t = tValsObs;
        PCAc_Stats.pairPcDescriptives = pairPcDescriptives;
    elseif iData==3
        pcCBFv_Stats.ANOVA.var1 = var1;
        pcCBFv_Stats.ANOVA.var2 = var2;
        pcCBFv_Stats.ANOVA.varInt = varInt;
        pcCBFv_Stats.Pairwise_One_Sample = tValsObs;
    elseif iData==6
        pcCBFc_Stats.ANOVA.var1 = var1;
        pcCBFc_Stats.ANOVA.var2 = var2;
        pcCBFc_Stats.ANOVA.varInt = varInt;
        pcCBFc_Stats.Pairwise_One_Sample = tValsObs;
    end
    
    clear nullDataMat observedData pValuesPairwise thisPerm tValsNull tValsObs tValueIndex var1 var2 varInt cohens_d
    
end


% save important stats info
save([destDir '/' 'BBT_STATS_Control.mat'],'MCAv_Stats','PCAv_Stats','MCAc_Stats','PCAc_Stats','pcCBFc_Stats','pcCBFv_Stats');
