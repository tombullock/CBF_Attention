%{
Behavior_Performance_RT

Author: Tom Bullock, UCSB Attention Lab
Date: 7.23.17 (revisited 07.19.20)

Plot and analyze behavioral decline over the course of the blocks.

Make sure I do this before any threshold based artifact rej!

%}

clear
close all

%thisDir = '/home/bullock/Calgary/Data_Task/A_Epochs_45';
thisDir = '/home/bullock/CBF_Attention/EEG_Ep_Task';
plotDir = '/home/bullock/CBF_Attention/Plots';
compiledDir = '/home/bullock/CBF_Attention/Data_Compiled';

%subjects = [134 237 350 576 577 588 592];
subjects = [134,237,350,576,577,588,592,249,997:999]; % no 578 coz missing resps

% loop through conditions
for iCond=1:4
    if iCond==1; thisCond='air';
    elseif iCond==2; thisCond='hypercapnia';
    elseif iCond==3; thisCond='hypocapnia';
    elseif iCond==4; thisCond='hypoxia';
    end
    
    for iSub=1:length(subjects)
        
        sjNum = subjects(iSub)
        
        % load example file
        %  EEG = pop_loadset([thisDir '/'    'sj' num2str(sjNum) '_' num2str(thisCond) '_ft_bl_ep_ar_TASK.set']);
        load([thisDir '/' sprintf('sj%02d_',sjNum) thisCond '_erp_tar_hit_ft_ep.mat']);
        
        
        % loop through epoch and get RTs
        for iEpochs=1:length(EEG.epoch)
            
            try
                % finds position index of response trigger (120) in epoch
                rtLatencyIndex = find(strcmp(EEG.epoch(iEpochs).eventtype,'B4(120)'));
                
                % if there are two RTs in the epoch then take the
                % first press if the latency of that press >700ms,
                % and the second press if latency <700ms (becoz length of
                % targ = 750ms and std = 500, so anything <700ms
                % ain't right)
                if size(rtLatencyIndex,2)>1;
                    if cell2mat(EEG.epoch(iEpochs).eventlatency(rtLatencyIndex(1)))<=700
                        rtLatencyIndex = rtLatencyIndex(2); % probably a carry-over resp
                    elseif cell2mat(EEG.epoch(iEpochs).eventlatency(rtLatencyIndex(1)))>700
                        rtLatencyIndex = rtLatencyIndex(1); % probably 2nd press is a double click
                    end
                end
                
%                 % matches to appropriate latency value (response RT) then adds respTime to
%                 % EEG structure (appends a matrix to end of EEG structure)
%                 rtAll(iEpochs,iSub,iCond) = cell2mat(EEG.epoch(iEpochs).eventlatency(rtLatencyIndex));
                allRT(iEpochs) = cell2mat(EEG.epoch(iEpochs).eventlatency(rtLatencyIndex));

            catch
                disp('skip epoch')
            end
        end
        
        rtAll(iSub,iCond) = nanmean(allRT);
        
        clear allRT
        
    end
end






%% plot reaction time

h=figure;
%subplot(1,2,2);

barRTmat = rtAll;

plot(nanmean(barRTmat,1))


% define colors for lines
thisGreen = [0 100 0];
thisRed = [255 0 0 ];
thisBlue = [30 144 255];
thisMagenta = [153 50 204];

% plot bars
for i=1:4
    if i==1; thisColor = thisGreen;
    elseif i==2; thisColor = thisRed;
    elseif i==3; thisColor = thisBlue;
    elseif i==4; thisColor = thisMagenta;
    end
    
    bar(i,mean(barRTmat(:,i),1), 'FaceColor',thisColor./255); hold on
end

% plot individual data points using plotSpread
plotSpread(barRTmat,'distributionMarkers',{'.'},'distributionColors',{'k'});
set(findall(1,'type','line','color','k'),'markerSize',16) %Change marker size

% plot error bars
errorbar(1.25:1:4.25,mean(barRTmat,1),std(barRTmat,0,1)/sqrt(size(barRTmat,1)),...
    'Color','k','LineStyle','none','LineWidth',2.5,'CapSize',10); %

% edit plot characteristics
box('off')
%plotNames = {'Att. Ind/IC','Attend Pacman, No Kanizsa', 'Attend RSVP, Kanizsa', 'Attend RSVP, No Kanizsa'}
%plotNames = {'AI/IC','AI/NIC', 'AL/IC', 'AL/NIC'};
%set(gca,'xticklabel',plotNames,'FontSize',24,'xlim',[.5,4.5],'LineWidth',1.5)
set(gca,'FontSize',24,'xlim',[.5,4.5],'LineWidth',1.5,'xticklabels',{' ',' ',' ',' '},'xtick',[],'ytick',[900:100:1300],'ylim',[900,1300])
pbaspect([1,1,1])

% save figure
saveas(h,[plotDir '/' 'Behavior_RT.eps'],'epsc')

% save bar accuracy matrix
save([compiledDir '/' 'BEH_RT_Master.mat'],'barRTmat','subjects')