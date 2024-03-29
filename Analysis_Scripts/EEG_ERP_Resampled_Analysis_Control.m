%{
EEG_ERP_Resampled_Analysis
Author:Tom Bullock, UCSB Attention Lab
Date: 12.15.20

%}

clear
close all

% set dirs
sourceDir = '/home/bullock/CBF_Attention/Data_Compiled';
destDir = sourceDir;

% load data
load([sourceDir '/' 'ERPs_Master_Control.mat'])

% name ANOVA factors
var1_name = 'gas';
var1_levels = 2;

% set ERP channels (for P3)
theseChans = 4:12;

% loop through times and run ANOVAs and Pairwise Comps
for iTimes = 1:size(ERP_Tar,4)
    
    disp(['Time ' num2str(iTimes)]);
    
    observedData = squeeze(mean(ERP_Tar(:,:,theseChans,iTimes),3));
    
    % generate resampled iterations for ANOVA/t-tests
    for j=1:1000
        
        for i=1:size(observedData,1)    % for each row of the observed data
            thisPerm = randperm(size(observedData,2)); % shuffle colums for each row
            for k=1:length(thisPerm)
                nullDataMat(i,k,j) = observedData(i,thisPerm(k));
            end
        end
        
        % do ANOVA on permuted data for each new iteration
        statOutput = teg_repeated_measures_ANOVA(nullDataMat(:,:,j),[var1_levels],{var1_name});  % run ANOVA
        var1.fValsNull(j,1) = statOutput(1,1);   % create column vectors of null F-values
        clear statOutput
        
        % get post-hoc null t value distribution (only makes sense to create
        % one null distribution for all combinations of tests, given within
        % subjects column shuffling method)
        [H,P,CI,STATS] = ttest(nullDataMat(:,1,j),nullDataMat(:,2,j));
        tValsNull(j,1) = STATS.tstat;
        clear STATS
        
    end
    
    % run ANOVA on observed data
    statOutput = teg_repeated_measures_ANOVA(observedData,[var1_levels],{var1_name});
    % get fvalues
    var1.fValObserved = statOutput(1,1);
    % get effect sizes
    var1.partialEtaSq = statOutput(1,7);
    % get dfs
    var1.df = statOutput(1,[2,3]);
    
    clear statOutput
    
    % sort null f-values, get index value and convert to percentile (VAR_1)
    var1.NAME = var1_name;
    var1.LEVELS = var1_levels;
    var1.fValsNull = sort(var1.fValsNull(:,1),1,'descend');
    [c var1.fValueIndex] = min(abs(var1.fValsNull - var1.fValObserved));
    var1.fValueIndex = var1.fValueIndex/1000;
    var1.pValueANOVA = var1.fValueIndex;
    
    clear cohens_d
    
    pValMat(iTimes) = var1.pValueANOVA;  %statOutput(4);
    fValMat(iTimes) = var1.fValObserved;
    
    clear var1
    
    
    
    %% do t-tests on observed data
    for iTest=1
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
%     [c tValueIndex(2)] = min(abs(tValsNull - tValsObs(1,2)));
%     [c tValueIndex(3)] = min(abs(tValsNull - tValsObs(1,3)));
    
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
    for i=1
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
    
    % create a pairwise t-test mat for plotting
    pairwiseMat(iTimes,:) = tValsObs(3,:);
    
    
end

save([destDir '/' 'ERP_Stats_Resampled_Control.mat'],'pairwiseMat','pValMat','fValMat');


plot(pValMat(351:551))

figure;
plot(fValMat(351:551))



