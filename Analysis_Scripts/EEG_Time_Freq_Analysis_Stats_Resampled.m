%{
EEG_ERSP_Stats_Resampled
Author: Tom Bullock
Date: 12.15.20

Run stats on ERSPs

%}

clear
%close all

% seed rng
rng('shuffle')

% set dirs
sourceDir = '/home/bullock/CBF_Attention/Data_Compiled';
destDir = sourceDir;
destDirPlot = '/home/bullock/CBF_Attention/Plots';

% load data
load([sourceDir '/' 'ERSP_Master.mat'])

% name variables
var1_name = 'gas';
var1_levels = 4;

% loop through freqs and times
for iTimes = 1:12
    
   for iFreqs = 1:4 
       
       for iChans = 1:4
           
           theseTimes = [1,13; 14,25; 26,38; 39,50; 51,63; 64,76; 77,88; 89,100; 101,113; 114,126; 127,138; 139,151];
           
           theseFreqs = [1,3; 4,7; 8,12; 13,30];
           
           theseChans = [1,3; 4,6; 7,9; 10,15];
           
           % grab times, freqs and chans
           observedData = mean(mean(mean(allERSP(:,:,theseChans(iChans,1):theseChans(iChans,2),theseFreqs(iFreqs,1):theseFreqs(iFreqs,2),theseTimes(iTimes,1):theseTimes(iTimes,2)),3),4),5);
           
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
           
           pValMat(iTimes,iFreqs,iChans) = var1.pValueANOVA;  %statOutput(4);
           fValMat(iTimes,iFreqs,iChans) = var1.fValObserved;
           
           clear var1
           
           
           
           %% do t-tests on observed data
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
           
           % create a pairwise t-test mat for plotting
           pairwiseMat(iTimes,iFreqs,iChans,:) = tValsObs(3,:);
           
           
           
           
           
           
           
       end
       
%            % run ANOVA on observed data
%            statOutput = teg_repeated_measures_ANOVA(observedData,[var1_levels],{var1_name});
%            
%            pValMat(iTimes,iFreqs,iChans) = statOutput(4);
           
       
   end
    
end














% generate plots for ANOVA effects
pValMatBinary = pValMat<0.05;

h=figure('OuterPosition',[672    52   424   950]);
for iChan=1:4
   subplot(4,1,iChan);
    imagesc(pValMatBinary(:,:,iChan)');
    set(gca,'YDir','normal');
    pbaspect([1,1,1])
    colormap jet
    
    if      iChan==1; thisTitle = 'frontal';
    elseif  iChan==2; thisTitle = 'central';
    elseif  iChan==3; thisTitle = 'pareital';
    elseif  iChan==4; thisTitle = 'parieto-occipital';
    end
  
   title(thisTitle,'FontSize',18)
    
    set(gca,'xtick',0:2:12,'xTickLabel',-100:100:500,'ytick',1:4,'YTickLabel',{'Delta','Theta','Alpha','Beta '})
end

saveas(h,[destDirPlot '/' 'ERSP_Stats_Resampled.eps'],'epsc')


% generate plots for PAIRWISE EFFECTS
pValMatBinary = pairwiseMat<0.05;

for pairwiseComp=1:3
    h=figure('OuterPosition',[672    52   424   950]);
    for iChan=1:4
        subplot(4,1,iChan);
        imagesc(pValMatBinary(:,:,iChan,pairwiseComp)');
        set(gca,'YDir','normal');
        pbaspect([1,1,1])
        colormap jet
        
        if      iChan==1; thisTitle = 'frontal';
        elseif  iChan==2; thisTitle = 'central';
        elseif  iChan==3; thisTitle = 'pareital';
        elseif  iChan==4; thisTitle = 'parieto-occipital';
        end
        
        title(thisTitle,'FontSize',18)
        
        set(gca,'xtick',0:2:12,'xTickLabel',-100:100:500,'ytick',1:4,'YTickLabel',{'Delta','Theta','Alpha','Beta '})
    end
    
    saveas(h,[destDirPlot '/' 'ERSP_Stats_Resampled_Pair' num2str(pairwiseComp) '.eps'],'epsc')
    
end









% 
% pValMatBinary = pValMat<0.05;
% 
% h=figure;
% for iChan=1:4
%    subplot(1,4,iChan);
%     imagesc(pValMatBinary(:,:,iChan)');
%     set(gca,'YDir','normal');
%     pbaspect([1,1,1])
%     colormap jet
% end



% 
% 
% %imagesc(pValMat(:,:,1))
% 
% 
% 
% 
% 
% 
% 
% 
% % loop through different datasets and run analyses
% for iData=1:2
%     
%     % which data?
%     if iData==1 % regular SSVEP
%         
%         freqIdx = 533; % freq - 16.6667
%         observedData = mean(mean(allSpectra(:,:,2,10:15,freqIdx),4),5);
%         
%     elseif iData==2 % baseline corrected SSVEP (1Hz either side)
%         
%         freqIdx = 533; % freq - 16.6667
%         
%         surrFreqs = mean(mean(allSpectra(:,:,2,10:15,[find(freqs==15):find(freqs==16),find(freqs==17):find(freqs==18)]),4),5);
%         ssvFreq = mean(mean(allSpectra(:,:,2,10:15,freqIdx),4),5);
%         observedData = ssvFreq - surrFreqs;
%         
%     end
%     
% %     % remove sj idx 12 from all conditions (missing data in some)
% %     if length(observedData)==12
% %         observedData(12,:) = [];
% %     end
%     
%     
%     % name variables
%     var1_name = 'gas'; % gas cond
%     var1_levels = 4;
% 
%     
%     % generate resampled iterations for ANOVA/t-tests
%     for j=1:1000
%         
%         for i=1:size(observedData,1)    % for each row of the observed data
%             thisPerm = randperm(size(observedData,2)); % shuffle colums for each row
%             for k=1:length(thisPerm)
%                 nullDataMat(i,k,j) = observedData(i,thisPerm(k));
%             end
%         end
%         
%         % do ANOVA on permuted data for each new iteration
%         statOutput = teg_repeated_measures_ANOVA(nullDataMat(:,:,j),[var1_levels],{var1_name});  % run ANOVA
%         var1.fValsNull(j,1) = statOutput(1,1);   % create column vectors of null F-values
%         clear statOutput
%         
%         % get post-hoc null t value distribution (only makes sense to create
%         % one null distribution for all combinations of tests, given within
%         % subjects column shuffling method)
%         [H,P,CI,STATS] = ttest(nullDataMat(:,1,j),nullDataMat(:,2,j));
%         tValsNull(j,1) = STATS.tstat;
%         clear STATS
%         
%     end
%     
%     % run ANOVA on observed data
%     statOutput = teg_repeated_measures_ANOVA(observedData,[var1_levels],{var1_name});
%     % get fvalues
%     var1.fValObserved = statOutput(1,1);
%     % get effect sizes
%     var1.partialEtaSq = statOutput(1,7);
%     % get dfs
%     var1.df = statOutput(1,[2,3]);
%     
%     clear statOutput
%     
%     % sort null f-values, get index value and convert to percentile (VAR_1)
%     var1.NAME = var1_name;
%     var1.LEVELS = var1_levels;
%     var1.fValsNull = sort(var1.fValsNull(:,1),1,'descend');
%     [c var1.fValueIndex] = min(abs(var1.fValsNull - var1.fValObserved));
%     var1.fValueIndex = var1.fValueIndex/1000;
%     var1.pValueANOVA = var1.fValueIndex;
%     
%     clear cohens_d
%     
%     
%     
%     
%     % only to t-tests on certain datasets
%     if ismember(iData,[1,2])
%         
%         % do t-tests on observed data
%         for iTest=1:3
%             if       iTest==1; thisPair=[1,2]; % hcap rest
%             elseif   iTest==2; thisPair=[1,3]; % hpo rest
%             elseif   iTest==3; thisPair=[1,4]; % hpox rest
%             end
%             
%             [H,P,CI,STATS] = ttest(observedData(:,thisPair(1)),observedData(:,thisPair(2)));
%             tValsObs(1,iTest) = STATS.tstat;
%             cohens_d(iTest)=computeCohen_d(observedData(:,thisPair(1)),observedData(:,thisPair(2)),'paired');
%             
%             
%             % compute descriptives for % change
%             pairPc = ((observedData(:,thisPair(2)) - observedData(:,thisPair(1)))./observedData(:,thisPair(1)))*100;
%             pairPcDescriptives(iTest,1) = mean(pairPc);
%             pairPcDescriptives(iTest,2) = std(pairPc)/sqrt(size(pairPc,1));
%             
%             % compute dfs
%             tValsObs(2,iTest) = STATS.df;
%             clear STATS
%         end
%         
%         % sort null f-values, get index value and convert to percentile
%         tValsNull = sort(tValsNull(:,1),1,'descend');
%         
%         % compare observed t values with the distribution of null t values
%         [c tValueIndex(1)] = min(abs(tValsNull - tValsObs(1,1)));
%         [c tValueIndex(2)] = min(abs(tValsNull - tValsObs(1,2)));
%         [c tValueIndex(3)] = min(abs(tValsNull - tValsObs(1,3)));
%         
%         % convert to percentiles
%         tValueIndex = tValueIndex./1000;
%         pValuesPairwise = tValueIndex;
%         
%         % add pnull values to tValsObs for easy viewing
%         tValsObs(3,:) = pValuesPairwise;
%         
%         % critical t score
%         tmpA = tValsNull(25);
%         tmpB = tValsNull(975);
%         
%         if tmpA<0
%             tCriticalNeg = tmpA;
%             tCriticalPos = tmpB;
%         else
%             tCriticalNeg = tmpB;
%             tCriticalPos = tmpA;
%         end
%         
%         
%         % compare critical t score to distribution and present 0 (ns) or 1(sig)
%         % values in output
%         for i=1:3
%             if tValsObs(1,i)<0 && tValsObs(1,i)<tCriticalNeg
%                 tValsObs(4,i)=1;
%             elseif tValsObs(1,i)>0 && tValsObs(1,i)>tCriticalPos
%                 tValsObs(4,i)=1;
%             else
%                 tValsObs(4,i)=0;
%             end
%         end
%         
%         % add cohens d effect sizes into tValsObs matrix
%         tValsObs(5,:) = cohens_d;
%         
%     else
%         
%         % compute 1 sample t-tests against zero for both arteries vols
%         [H,P,CI,STATS] = ttest(observedData);
%         tValsObs = H;
%         
%     end
%     
%     
%     % save data
%     if iData==1
%         SSV_Stats.ANOVA.var1 = var1;
%         SSV_Stats.Pairwise.t = tValsObs;
%         SSV_Stats.pairPcDescriptives = pairPcDescriptives;
%     elseif iData==2
%         SSV_Stats_BLC.ANOVA.var1 = var1;
%         SSV_Stats_BLC.Pairwise.t = tValsObs;
%         SSV_Stats_BLC.pairPcDescriptives = pairPcDescriptives;
%     end
%     
%     clear nullDataMat observedData pValuesPairwise thisPerm tValsNull tValsObs tValueIndex var1 var2 varInt cohens_d
%     
% end
% 
% 
% % save important stats info
% save([destDir '/' 'EEG_Spectra_STATS.mat'],'SSV_Stats','SSV_Stats_BLC');