%{
EEG_Spectra_Stats_ALPHA
Author: Tom Bullock
Date: 12.14.20

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
load([sourceDir '/' 'EEG_Spectra_Global.mat'])

% create a chan x freq x subs x phase
for iChan=1:4
    
    if      iChan==1; theseChans=1:3;
    elseif  iChan==2; theseChans=4:6;
    elseif  iChan==3; theseChans=7:9;
    elseif  iChan==4; theseChans=10:15;
    end
    
    for iFreq=1:3
        
        if      iFreq==1; theseFreqs = find(freqs==4):find(freqs==8)-1;
        elseif  iFreq==2; theseFreqs = find(freqs==8):find(freqs==12)-1;
        elseif  iFreq==3; theseFreqs = find(freqs==12):find(freqs==20)-1;
        end
        
        for iPhase=1:2
            
            % observed data is 4[chan] x 4[freq] x 2[phase] x 12[subs] x [gas]
            observedData(iChan,iFreq,iPhase,:,:) = mean(mean(allSpectra(:,:,iPhase,theseChans,theseFreqs),4),5);
        
        end
    end
end

%% run a quick ANOVA to confirm there is an interaction (4 way)

% manual order check
  observedDataAllManual =  [
    squeeze(observedData(1,1,1,:,:)),...
    squeeze(observedData(2,1,1,:,:)),...
    squeeze(observedData(3,1,1,:,:)),...
    squeeze(observedData(4,1,1,:,:)),...
    squeeze(observedData(1,2,1,:,:)),...
    squeeze(observedData(2,2,1,:,:)),...
    squeeze(observedData(3,2,1,:,:)),...
    squeeze(observedData(4,2,1,:,:)),...
    squeeze(observedData(1,3,1,:,:)),...
    squeeze(observedData(2,3,1,:,:)),...
    squeeze(observedData(3,3,1,:,:)),...
    squeeze(observedData(4,3,1,:,:)),...
    squeeze(observedData(1,1,2,:,:)),...
    squeeze(observedData(2,1,2,:,:)),...
    squeeze(observedData(3,1,2,:,:)),...
    squeeze(observedData(4,1,2,:,:)),...
    squeeze(observedData(1,2,2,:,:)),...
    squeeze(observedData(2,2,2,:,:)),...
    squeeze(observedData(3,2,2,:,:)),...
    squeeze(observedData(4,2,2,:,:)),...
    squeeze(observedData(1,3,2,:,:)),...
    squeeze(observedData(2,3,2,:,:)),...
    squeeze(observedData(3,3,2,:,:)),...
    squeeze(observedData(4,3,2,:,:))];


%observedDataAll = reshape(observedData,[12,96]);

%     % remove sj idx 12 from all conditions (missing data in some)
%     if length(observedData)==12
%         observedData(12,:) = [];
%     end

% name variables
% var1_name = 'chan'; 
% var1_levels = 4;
% var2_name = 'freq'; 
% var2_levels = 3;
% var3_name = 'phase';
% var3_levels = 2;
% var4_name = 'gas';
% var4_levels = 4;

% name vars
var1_name = 'phase'; 
var1_levels = 2;
var2_name = 'freqs'; 
var2_levels = 3;
var3_name = 'chans';
var3_levels = 4;
var4_name = 'gas';
var4_levels = 4;

statOutput = teg_repeated_measures_ANOVA(observedDataAllManual,[var1_levels,var2_levels,var3_levels,var4_levels],{var1_name, var2_name, var3_name, var4_name});


%% run pairwise tests to investigate phase x freqs x gas interaction [average across channel locs]
for iFreq=1:3
    for iPhase=1:2
        
        [H,P,CI,STATS] = ttest(squeeze(mean(observedData(:,iFreq,iPhase,:,1),1)),squeeze(mean(observedData(:,iFreq,iPhase,:,2),1)));
        all_H(iFreq,iPhase,1) = H;
        [H,P,CI,STATS] = ttest(squeeze(mean(observedData(:,iFreq,iPhase,:,1),1)),squeeze(mean(observedData(:,iFreq,iPhase,:,3),1)));
        all_H(iFreq,iPhase,2) = H;
        [H,P,CI,STATS] = ttest(squeeze(mean(observedData(:,iFreq,iPhase,:,1),1)),squeeze(mean(observedData(:,iFreq,iPhase,:,4),1)));
        all_H(iFreq,iPhase,3) = H;
        
    end
end

% this tells us that the changes are being driven by air vs. hypocap in the
% alpha band [PUT RESULTS IN TABLE]



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5






% 
% % observed data is 4[chan] x 4[freq] x 2[phase] x 12[subs] x [gas]
% for iChan=1:4
%     for iFreq=1:3
%         for iPhase=1:2
%             
%             [H,P,CI,STATS] = ttest(squeeze(observedData(iChan,iFreq,iPhase,:,1)),squeeze(observedData(iChan,iFreq,iPhase,:,2)));
%             all_H(iChan,iFreq,iPhase,1) = H;
%             [H,P,CI,STATS] = ttest(squeeze(observedData(iChan,iFreq,iPhase,:,1)),squeeze(observedData(iChan,iFreq,iPhase,:,3)));
%             all_H(iChan,iFreq,iPhase,2) = H;
%             [H,P,CI,STATS] = ttest(squeeze(observedData(iChan,iFreq,iPhase,:,1)),squeeze(observedData(iChan,iFreq,iPhase,:,4)));
%             all_H(iChan,iFreq,iPhase,3) = H;
%             
%         end
%     end
% end
% 




%%%%%%%%%%%%%%%%%%%%%%%%%%%%





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
if ismember(iData,[1,2])

    % do t-tests on observed data
    for iTest=1:6
        if       iTest==1; thisPair=[1,2]; % hcap rest
        elseif   iTest==2; thisPair=[1,3]; % hpo rest
        elseif   iTest==3; thisPair=[1,4]; % hpox rest
        elseif   iTest==4; thisPair=[5,6]; % hcap task
        elseif   iTest==5; thisPair=[5,7]; % hpo task
        elseif   iTest==6; thisPair=[5,8]; % hpox task
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
    [c tValueIndex(4)] = min(abs(tValsNull - tValsObs(1,4)));
    [c tValueIndex(5)] = min(abs(tValsNull - tValsObs(1,5)));
    [c tValueIndex(6)] = min(abs(tValsNull - tValsObs(1,6)));

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
    for i=1:6
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
    Alpha_Stats.ANOVA.var1 = var1;
    Alpha_Stats.ANOVA.var2 = var2;
    Alpha_Stats.ANOVA.varInt = varInt;
    Alpha_Stats.Pairwise.t = tValsObs;
    Alpha_Stats.pairPcDescriptives = pairPcDescriptives;
elseif iData==2
    Alpha_Stats_BLC.ANOVA.var1 = var1;
    Alpha_Stats_BLC.ANOVA.var2 = var2;
    Alpha_Stats_BLC.ANOVA.varInt = varInt;
    Alpha_Stats_BLC.Pairwise.t = tValsObs;
    Alpha_Stats_BLC.pairPcDescriptives = pairPcDescriptives;
elseif iData==3
    SSV_Stats.ANOVA.var1 = var1;
    SSV_Stats.ANOVA.var2 = var2;
    SSV_Stats.ANOVA.varInt = varInt;
    SSV_Stats.Pairwise.t = tValsObs;
    SSV_Stats.pairPcDescriptives = pairPcDescriptives;
end

clear nullDataMat observedData pValuesPairwise thisPerm tValsNull tValsObs tValueIndex var1 var2 varInt cohens_d




% save important stats info
save([destDir '/' 'EEG_Spectra_STATS.mat'],'Alpha_Stats','Alpha_Stats_BLC','SSV_Stats');
