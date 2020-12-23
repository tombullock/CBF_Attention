%{
EEG_Alpha_Hits_Misses
Author: Tom Bullock, UCSB Attention Lab
Date: 12.20.20

Alpha on hit vs miss target trials  &&&RUN ME&&&

%}

clear
close all

%% dir
sourceDir = '/home/bullock/CBF_Attention/EEG_Ep_Task';
destDir = '/home/bullock/CBF_Attention/Data_Compiled';
destDirPlot= '/home/bullock/CBF_Attention/Plots';

%psList = [134 237  576 577 578 592 588 350];
%psList = [134 576 577 578 592 237 350 588]; % matches OLD bloodflow order

subjects = [134,350,576,577,592,237,588,249,998,997,999]; % matches new bloodflow order (08.07.20) [REMOVED sj578 coz no misses]

% loop through subs
for iSub=1:length(subjects)
    sjNum=subjects(iSub);
    
    % loop through gas challenge conditions
    for iCond=1:4
        
        clear hilbertEEG
        
        if iCond==1
            thisCond = 'air';
        elseif iCond==2
            thisCond = 'hypercapnia';
        elseif iCond==3
            thisCond = 'hypocapnia';
        elseif iCond==4
            thisCond = 'hypoxia';
        end
        
        hilbertEEG = [];
        
        for iHitMiss=1:2
            
            if iHitMiss==1; thisPerf='hit';
            elseif iHitMiss==2; thisPerf='miss';
            end
            
            % load hits data
            load([sourceDir '/' sprintf('sj%d_%s_alpha_tar_%s_ft_ep.mat',sjNum,thisCond,thisPerf)])
            
            % get RT for this trials
            if iHitMiss==1
                thisRT=[];
                for iEpoch=1:length(EEG.epoch)
                    for iEvent=1:length(EEG.epoch(iEpoch).eventbini)
                        if EEG.epoch(iEpoch).eventbini{iEvent}==4
                            thisRT(iEpoch) = EEG.epoch(iEpoch).eventlatency{iEvent};
                        end
                    end
                end
                %allRTs(iSub,iCond,:) = {thisRT};
            end
            
            
            
            
            % apply Butterworth Filter (better alternative to try)
            filterorder = 3;
            type = 'bandpass';
            [z1,p1] = butter(filterorder, [8,12]./(EEG.srate/2),type);
            data = double(EEG.data);
            tempEEG = NaN(size(data,1),EEG.pnts,size(data,3));
            for x = 1:size(data,1) % loop through chans
                for y = 1:size(data,3) % loop through trials
                    dataFilt1 = filtfilt(z1,p1,data(x,:,y)); % was filtfilt
                    tempEEG(x,:,y) = dataFilt1; % tymp = chans x times x trials
                end
            end
            
            eegBand = [];
            eegBand = tempEEG;
            
            
            
            % apply Hilbert to each channel and trial
            hilberEEG = [];
            for j=1:size(tempEEG,1) % chans
                for i=1:size(tempEEG,3) % trials
                    hilbertEEG(j,:,i) = hilbert(squeeze(tempEEG(j,:,i)));
                end
            end
            
            % convert to amp or power
            hilbertEEG = [abs(hilbertEEG).^2];
            disp('Calculating Power!')
            
            
            % correlate hit trial RTs with alpha power

%             for iTime=1:size(hilbertEEG,2)
%                 myAlpha = squeeze(mean(hilbertEEG(10:15,iTime,:),1));
%                 [rho,pVal] = corr(thisRT',myAlpha);
%                 allCorr(iSub,iCond,iTime) = pVal;
%             end

            % correlate RTs within subs  ???? WHAT CORRELATION???
            corrRT(iSub,iCond) = corr(
            
            
            %average over electrodes and epochs
            if iHitMiss==1
                allHilbertHit(iSub,iCond,:) = mean(mean(hilbertEEG(10:15,:,:),1),3); % do 10:15 for average of all O and PO elects
            else
                allHilbertMiss(iSub,iCond,:) = mean(mean(hilbertEEG(10:15,:,:),1),3); % do 10:15 for average of all O and PO elects
            end
        end
        
    end
end

theseTimes = EEG.times;





% % downsample to 1 Hz
% for i=1:88 % 88 points coz lost edges!
%     j=i*250;
%     downsampledHilbert(:,:,i) = mean(allHilbert(:,:,(j-249):j),3);  
% end

save([destDir '/' 'EEG_Alpha_HitMiss_Master.mat'],'allHilbertHit','allHilbertMiss','subjects','theseTimes','allCorr');

% QUICK PLOT

% define colors for lines
thisGreen = [0 100 0];
thisRed = [255 0 0 ];
thisBlue = [30 144 255];
thisMagenta = [153 50 204];


h=figure('Units','normalized','OuterPosition',[0,0,1,1]);
for iCond=1:4
    
    subplot(1,4,iCond);
    
    if iCond==1; thisColor = thisGreen; thisCond = 'Air';
    elseif iCond==2; thisColor = thisRed; thisCond = 'Hcap';
    elseif iCond==3; thisColor = thisBlue; thisCond = 'Hpo';
    elseif iCond==4; thisColor = thisMagenta; thisCond = 'Hpox';
    end
    
    meanHit = squeeze(mean(allHilbertHit(:,iCond,:),1));
    stdHit = squeeze(std(allHilbertHit(:,iCond,:),0,1));
    
    meanMiss = squeeze(mean(allHilbertMiss(:,iCond,:),1));
    stdMiss = squeeze(std(allHilbertMiss(:,iCond,:),0,1));
    
    shadedErrorBar(theseTimes,meanHit,stdHit,{'Color','g','LineWidth',3,'LineStyle','-'},1); hold on
    shadedErrorBar(theseTimes,meanMiss,stdMiss,{'Color','r','LineWidth',3,'LineStyle','-'},1);
    
    %     plot(theseTimes,squeeze(nanmean(allHilbertHit(:,iCond,:),1)),'Color',thisColor./255,'LineWidth',3,'LineStyle','-'); hold on
    %     plot(theseTimes,squeeze(nanmean(allHilbertMiss(:,iCond,:),1)),'Color',thisColor./255,'LineWidth',3,'LineStyle','-');
    

    
    % do quick stats
    for iTimes=1:size(allHilbertHit,3)
        [H,P] = ttest(squeeze(allHilbertHit(:,iCond,iTimes)),squeeze(allHilbertMiss(:,iCond,iTimes)));
        pVals(iTimes) = P;
    end
    
    for iTimes=1:size(allHilbertHit,3)
        if pVals(iTimes)<.05
            line([theseTimes(iTimes),theseTimes(iTimes+1)],[-75,-75],'linewidth',5)
        end
    end
    
    set(gca,'ylim',[-500,1500],'xlim',[400,3000]);
    pbaspect([1,1,1]);
    
    title(thisCond,'FontSize',24);
    
    line([500,500],[-500,1500],'linewidth',3,'linestyle','--','color','k');
    
    set(gca,'XTick',500:500:3000,'XTickLabel',0:500:2500);
    
    ylabel('Power','FontSize',24)
    xlabel('Time (ms)','FontSize',24)
    
end

saveas(h,[destDirPlot '/' 'EEG_Alpha_Hit_Miss.eps'],'epsc')



% % quick plot averaged across conditons
% 
% downsampledHilbert = squeeze(mean(downsampledHilbert,1));
% plot(downsampledHilbert(1,:),'g');hold on % air
% plot(downsampledHilbert(2,:),'r') % hypercap
% plot(downsampledHilbert(3,:),'b') % hypocap
% plot(downsampledHilbert(4,:),'m') % hypoxia
% 
% %ylim([0,100])
% ylabel('alpha power')
% xlabel('secs')
% 
% legend('air','hcap','hpo','hpox')