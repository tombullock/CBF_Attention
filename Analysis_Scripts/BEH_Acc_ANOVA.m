%{
BEH_Acc_ANOVA
Author: Tom Bullock
Date: 08.07.20

%}

clear
close all

% set dirs
sourceDir = '/home/bullock/CBF_Attention/Data_Compiled';

% seed rng
rng('shuffle')

% original datafile (without .mat extension)
dataFile = 'BEH_Acc_Master';

% name variables
var1_name = 'gas';
var1_levels = 4;

% load stuff
load([sourceDir '/' dataFile '.mat'])

% set observed data matrix
observedData = barAccMat;


% iterate 1000 times for resampling stats
for j=1:1000
    
    for i=1:size(observedData,1)    % for each row of the observed data
        
        thisPerm = randperm(size(observedData,2)); % shuffle colums for each row
        
        for k=1:length(thisPerm)
            
            nullDataMat(i,k,j) = observedData(i,thisPerm(k));

        end
        
    end
    
    % do ANOVA on permuted data for each new iteration
    statOutput = teg_repeated_measures_ANOVA(nullDataMat(:,:,j),[var1_levels],{var1_name});  % do ANOVA
    var1.fValsNull(j,1) = statOutput(1,1);   % create column vector of null F-values
    
    clear statOutput
    
    % get post-hoc null t value distribution (only makes sense to create
    % one null distribution for all combinations of tests, given within
    % subjects column shuffling method)
    [H,P,CI,STATS] = ttest(nullDataMat(:,1,j),nullDataMat(:,2,j)); 
    tValsNull(j,1) = STATS.tstat;
    clear STATS
    
end


%%DO THIS FOR BOTH MAIN EFFECTS AND INTERACTION (JUST CHANGE THE VALUE FROM
%%STAT OUTPUT>

% do ANOVA on observed data
statOutput = teg_repeated_measures_ANOVA(observedData,[var1_levels],{var1_name});
var1.fValObserved = statOutput(1,1);   % exercise

clear statOutput


% sort null f-values, get index value and convert to percentile (VAR_1)
var1.NAME = var1_name;
var1.LEVELS = var1_levels;
var1.fValsNull = sort(var1.fValsNull(:,1),1,'descend');
[c var1.fValueIndex] = min(abs(var1.fValsNull - var1.fValObserved)); 
var1.fValueIndex = var1.fValueIndex/1000;
var1.pValueANOVA = var1.fValueIndex;

% plots histogram of null F-values (VAR1, VAR2, VAR INTERACTION)
h1=figure;
[N X] = hist(var1.fValsNull,100);    % get histogram values
hist(var1.fValsNull,100);    % plot histogram
line(var1.fValObserved,0:max(N),'Color','r','LineWidth',4)  % plot observed value in RED
line(var1.fValsNull(50),0:max(N),'Color','g','LineWidth',4) % plot critical F in GREEN
text(var1.fValObserved,max(N)-5,['obs=' num2str(var1.fValObserved) '   pValue=' num2str(var1.fValueIndex) ]);
text(var1.fValsNull(50),max(N)-10,['crit=' num2str(var1.fValsNull(50)) '   pValue=.05']);
title(var1_name);

%saveas(h1,[dataFile '_PLOTS' '/' 'VAR_1.fig'],'fig');


% do t-tests on observed data (test against AIR only)
[H,P,CI,STATS] = ttest(observedData(:,1),observedData(:,2)); 
tValsObs(1,1) = STATS.tstat;
clear STATS

[H,P,CI,STATS] = ttest(observedData(:,1),observedData(:,3)); 
tValsObs(1,2) = STATS.tstat;
clear STATS

[H,P,CI,STATS] = ttest(observedData(:,1),observedData(:,4)); 
tValsObs(1,3) = STATS.tstat;
clear STATS


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
tValsObs(2,:) = pValuesPairwise;

% critical t score
tCriticalNeg = tValsNull(25);
tCriticalPos = tValsNull(975);

% save important stats info
save([sourceDir '/' dataFile '_STATS.mat'],'var1','observedData','nullDataMat');