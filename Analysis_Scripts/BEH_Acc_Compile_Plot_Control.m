%{
Behavior_Acc_Compile_Plot_Control

Author: Tom Bullock, UCSB Attention Lab
Date: 7.23.17 (revisited 12.13.20)

Plot and analyze behavioral decline over the course of the blocks.  

Make sure I do this before any threshold based artifact rej!!!!! Create new
no-AR folder for these files.

%}

clear 
close all

%thisDir = '/home/bullock/Calgary/Data_Task/A_Epochs_45';
thisDir = '/home/bullock/CBF_Attention/EEG_Ep_Task';
plotDir = '/home/bullock/CBF_Attention/Plots';
compiledDir = '/home/bullock/CBF_Attention/Data_Compiled';

%subjects = [134 237 350 576 577 588 592];
%subjects = [134,237,350,576,577,588,592,249,997:999]; % no 578 coz missing resps
subjects = [134,237,576,588,592,249,997:999]; % no 578 coz missing resps

% missing subs 350,577,578


% loop through conditions
for iCond=1:2
    
    if      iCond==1; thisCond = 'hyperair';
    elseif  iCond==2; thisCond = 'hypocapnia';
    end
    
    
    
    
    for iSub=1:length(subjects)
        
        sjNum = subjects(iSub)
        
        % load example file
      %  EEG = pop_loadset([thisDir '/'    'sj' num2str(sjNum) '_' num2str(thisCond) '_ft_bl_ep_ar_TASK.set']); 
        load([thisDir '/' sprintf('sj%02d_',sjNum) thisCond '_task45_ft_ep.mat']); 
        
        % loop through epoch
        for i=1:length(EEG.epoch)
            
            nTargs=0; nHits=0;
            
            cnt1=0;
            cnt2=0;
            
            % find total targets and hits only
            for j=1:length(EEG.epoch(i).eventbini) % loop through all epochs
                
                % find total number of targets in epoch
                if EEG.epoch(i).eventbini{j}==2 || EEG.epoch(i).eventbini{j}==3
                    
                    cnt1=cnt1+1;
                    nTargs = cnt1;
                    
                end
                
                % find total number of hits in epoch
                if EEG.epoch(i).eventbini{j}==2
                    
                    cnt2=cnt2+1;
                    nHits = cnt2;
                    
                end
                
            end
            
            % create an epochs x subs x conds 3D matrix
            pCorrect(i,iSub,iCond) = nHits/nTargs;
            
        end
        
    end
    
end



h=figure('Units','normalized','Position',[0.2588    0.5340    0.1850    0.3327]);%('Position',[353 614 724 313]);

%% plot accuracy

% subplot(1,2,1);

% compute average performance
barAccMat = squeeze(nanmean(pCorrect,1));

% define colors for lines
thisBlue = [30 144 255];
thisGray = [128,128,128];

% plot bars
for i=1:2
    if      i==1; thisColor = thisGray;
    elseif  i==2; thisColor = thisBlue;
    end
    bar(i,mean(barAccMat(:,i),1), 'FaceColor',thisColor./255); hold on
end

% plot individual data points using plotSpread
plotSpread(barAccMat,'distributionMarkers',{'.'},'distributionColors',{'k'});
set(findall(1,'type','line','color','k'),'markerSize',24) %Change marker size

% plot error bars
errorbar(1.25:1:2.25,mean(barAccMat,1),std(barAccMat,0,1)/sqrt(size(barAccMat,1)),...
    'Color','k','LineStyle','none','LineWidth',2.5,'CapSize',10); %

% edit plot characteristics
box('off')
%plotNames = {'Att. Ind/IC','Attend Pacman, No Kanizsa', 'Attend RSVP, Kanizsa', 'Attend RSVP, No Kanizsa'}
%plotNames = {'AI/IC','AI/NIC', 'AL/IC', 'AL/NIC'};
%set(gca,'xticklabel',plotNames,'FontSize',24,'xlim',[.5,4.5],'LineWidth',1.5)
set(gca,'FontSize',36,'xlim',[.5,2.5],'LineWidth',1.5,'xticklabels',{' ',' ',' ',' '},'xtick',[],'ytick',0:.2:.8,'ylim',[0,.8])
pbaspect([1,1,1])


% save figure
saveas(h,[plotDir '/' 'Behavior_Acc_Control.eps'],'epsc')

% save bar accuracy matrix
save([compiledDir '/' 'BEH_Acc_Master_Control.mat'],'barAccMat','subjects')

% run descriptives and stats
meanAcc = mean(barAccMat)
semAcc = std(barAccMat,0,1)./sqrt(size(barAccMat,1))

observedData = barAccMat;
[H,P,CI,STATS] = ttest(observedData(:,1),observedData(:,2))
cohens_d=computeCohen_d(observedData(:,1),observedData(:,2),'paired')



% for plotting across blocks (not needed)
% 
% % average over subjects for plotting
% avgData = squeeze(nanmean(pCorrect,2));
% 
% avgDataT1 = squeeze(mean(mean(pCorrect(1:4,:,:),1),2));
% avgDataT2 = squeeze(mean(mean(pCorrect(5:8,:,:),1),2));
% 
% plot(avgData(:,1),'g'); hold on
% plot(avgData(:,2),'r');
% plot(avgData(:,3),'c');
% plot(avgData(:,4),'m');
% 
% % do t-tests comparing first half and last half
% behDataT1 = squeeze(mean(pCorrect(1:4,:,:),1));
% behDataT2 = squeeze(mean(pCorrect(5:8,:,:),1));
% 
% [h,p,ci,stats] = ttest(behDataT1(:,1),behDataT2(:,1))
% [h,p,ci,stats] = ttest(behDataT1(:,2),behDataT2(:,2))
% [h,p,ci,stats] = ttest(behDataT1(:,3),behDataT2(:,3))
% [h,p,ci,stats] = ttest(behDataT1(:,4),behDataT2(:,4))
