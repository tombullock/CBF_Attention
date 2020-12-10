%{
CBF_Stats_PCAcvc_Averaged_Stats
Author: Tom Bullock
Date: 12.09.20

Run stats on averaged PCAcvc data


%}

clear
close all

% seed rng
rng('shuffle')

% set dirs
sourceDir = '/home/bullock/CBF_Attention/Data_Compiled';
destDir = sourceDir;

% load data
load([sourceDir '/' 'BBT_Master_Averaged_Data.mat'])

% just PCAcvc
for iData=5
    
    % which data?
    if iData==1
        observedData = mean_MCAv;
    elseif iData==2
        observedData = mean_PCAv;
    elseif iData==4
        observedData = mean_MCA_CVC;
    elseif iData==5
        observedData = mean_PCA_CVC;
    elseif iData==3
        observedData = mean_pc_CBFv_PCA_MCA;
    elseif iData==6
        observedData = mean_pc_CVC_PCA_MCA;
    end
    
    % remove sj idx 12 from all conditions (missing data in some)
    if length(observedData)==12
        observedData(12,:) = [];
    end
    
    % average across rest/task
    observedData = [
        mean(observedData(:,[1,2]),2),...
        mean(observedData(:,[3,4]),2),...
        mean(observedData(:,[5,6]),2),...
        mean(observedData(:,[7,8]),2)];
    
    
    % generate resampled iterations for ANOVA/t-tests
    for j=1:1000
        
        for i=1:size(observedData,1)    % for each row of the observed data
            thisPerm = randperm(size(observedData,2)); % shuffle colums for each row
            for k=1:length(thisPerm)
                nullDataMat(i,k,j) = observedData(i,thisPerm(k));
            end
        end
        
        
        % get post-hoc null t value distribution (only makes sense to create
        % one null distribution for all combinations of tests, given within
        % subjects column shuffling method)
        [H,P,CI,STATS] = ttest(nullDataMat(:,1,j),nullDataMat(:,2,j));
        tValsNull(j,1) = STATS.tstat;
        clear STATS
        
    end
    
    
    
    % only to t-tests on certain datasets
    if ismember(iData,[1,2,4,5])
        
        % do t-tests on observed data
        for iTest=1:3
            if       iTest==1; thisPair=[1,2]; % hcap rest
            elseif   iTest==2; thisPair=[1,3]; % hpo rest
            elseif   iTest==3; thisPair=[1,4]; % hpox rest
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
        [c tValueIndex(3)] = min(abs(tValsNull - tValsObs(1,3)));
        
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
        for i=1:3
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
    elseif iData==5 % JUST THIS ONE WORKS!
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
save([destDir '/' 'BBT_STATS_PCAcvc_Only.mat'],'PCAc_Stats');
