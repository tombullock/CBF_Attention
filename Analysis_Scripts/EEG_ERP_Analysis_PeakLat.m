%{
EEG_Create_ERPs
Author: Tom Bullock
Date: 12.11.20

%}

clear
close all

% set dirs
sourceDir = '/home/bullock/CBF_Attention/EEG_Ep_Task';
destDir = '/home/bullock/CBF_Attention/Data_Compiled';
destDirPlot = '/home/bullock/CBF_Attention/Plots';

% subjects
subjects = [134,237,350,576,577,578,588,592,249,997:999];
%subjects = [134,237,350,576,577,588,592,249,997:999]; %remove 578 coz no
%resps [doesn't change outcome)

%% create ERP Mats
for iSub=1:length(subjects)
    sjNum=subjects(iSub);
    for iCond=1:4
        
        if       iCond==1; thisCond='air';
        elseif   iCond==2; thisCond='hypercapnia';
        elseif   iCond==3; thisCond='hypocapnia';
        elseif   iCond==4; thisCond='hypoxia';
        end
        
        load([sourceDir '/' sprintf('sj%d_%s_erp_std_ft_ep.mat',sjNum,thisCond)])
        
        % get number of trials
        ERP_Std_nTrials(iSub,iCond) = EEG.trials;
        
        ERP_Std(iSub,iCond,:,:) = mean(EEG.data,3);
        
        % load EEG target data
        load([sourceDir '/' sprintf('sj%d_%s_erp_tar_hit_ft_ep.mat',sjNum,thisCond)])
        
        % baseline correct target data to prestim critical target period
        EEG = pop_rmbase(EEG,400:500);
        
        % get number of trials
        ERP_Tar_nTrials(iSub,iCond) = EEG.trials;
        
        % create ERPs
        ERP_Tar(iSub,iCond,:,:) = mean(EEG.data,3);
        
        % load EEG target miss data
        %?
                
    end
end

save([destDir '/' 'ERPs_Master.mat'],'ERP_Tar_nTrials','ERP_Tar','ERP_Std_nTrials','ERP_Std')


%% crop ERPs between -100 to 700 ms around target onset
thisERP = squeeze(mean(ERP_Tar(:,:,4:12,351:551),3));
thisERP_times = -100:4:700; % set up real time index relative to targ onset

% find peak latencies
for i=1:size(thisERP,1)
   for j=1:size(thisERP,2)
    
       [M,I] = max(thisERP(i,j,101:end),[],3);
       peakLatIdx(i,j) = I;
       
   end
end

% relative to window i found peak times in
peakLatTimes = 300:4:700;

% get mean peak latencies
meanPeakLatIdx = round(mean(peakLatIdx));

% get peak latency SEMs
semPeakLat = std(peakLatIdx,0,1)./sqrt(size(peakLatIdx,1))

% get mean peaks in real time values
meanPeakLats = peakLatTimes(meanPeakLatIdx)

% run a quick ANOVA to test for differences
var1_name = 'gas'; % gas cond
var1_levels = 4;

observedData = peakLatIdx;
peakLatStats = teg_repeated_measures_ANOVA(observedData,[var1_levels],{var1_name})