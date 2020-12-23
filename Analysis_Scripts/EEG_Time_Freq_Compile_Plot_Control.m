%{
EEG_Time_Freq_Compile_Plot_Control
Author:Tom
Date: 12.10.20
%}

clear
close all

% set dirs
sourceDir = '/home/bullock/CBF_Attention/EEG_ERSPs';
destDir = '/home/bullock/CBF_Attention/Data_Compiled';
destDirPlot = '/home/bullock/CBF_Attention/Plots';

% subjects
subjects = [134,237,576,578,588,592,249,997:999];

% loop
for iSub=1:length(subjects)
    sjNum=subjects(iSub);
    for iCond=1:2
        
        if       iCond==1; thisCond='hyperair';
        elseif   iCond==2; thisCond='hypocapnia';
        end
        
        load([sourceDir '/' sprintf('sj%d_%s_ERSP.mat',sjNum,thisCond)])
        
        allERSP(iSub,iCond,:,:,:) = ersp;
                
    end
end

save([destDir '/' 'ERSP_Master_Control.mat'],'allERSP','times','freqs','subjects')


% plot data on heatmaps
for iChan=1;%1:4
    h=figure('Units','normalized','OuterPosition',[0.0956612650287506         0.392614188532556         0.462624150548876         0.422740524781341]);
    for iPlot=1:2
        
%         if      iChan==1; theseChans = 1:3; thisRegion = 'frontal';
%         elseif  iChan==2; theseChans = 4:6; thisRegion = 'central';
%         elseif  iChan==3; theseChans = 7:9; thisRegion = 'parietal';
%         elseif  iChan==4; theseChans = 10:15; thisRegion = 'parieto-occipital';
%         end
        thisRegion = 'backOfHead';
        theseChans = 7:15;
        
        subplot(1,2,iPlot);
        imagesc(squeeze(mean(mean(allERSP(:,iPlot,theseChans,:,:),1),3)),[-.3,.3]); hold on
        %line([26,26],[1,30],'color','k','linestyle',':','linewidth',2);
        pbaspect([1,1,1])
        set(gca,...
            'YDir','normal',...
            'xTick',[26,52,101,151],...
            'xticklabel',[0,100,300,500],...
            'YTick',[1,4,8,12,16,20,24,28]*1,...
            'YTickLabel',[1,4,8,12,16,20,24,28],...
            'FontSize',24,...
            'LineWidth',1.5);
        
        colormap jet
        %cbar
        
    
    
    % draw rectangle to indicate sig theta (150-250ms)
    rectangle('Position',[77,4,36,4],'LineWidth',3,'LineStyle','--'); % indicates sig. theta from 150-300ms
    rectangle('Position',[127,8,24,4],'LineWidth',3,'LineStyle','--'); % indicates sig. alpha from 400-500ms
    
    
    end
    
    saveas(h,[destDirPlot '/' 'ERSP_' thisRegion '_Control.eps'],'epsc')
end




% % plot bars [need to figure out time/freq bounds first]
% h4=figure('OuterPosition',[676   640   577   362]);
% 
% cnt=0;
%     
% for iPlot=1:4
%     
%     cnt=cnt+1;
%     subplot(1,4,cnt)
%     
%     chans = 1:15;
%     
%     % option to try and get max freq rather than using actual flicker
%     % [16.6667 Hz]...not using this here for plotting yet
%     [maxVal,maxIdx] = max(squeeze(mean(allSpectra(:,iPlot,2,10:15,463:589),4)),[],2);
%     maxIdx = 463+maxIdx;
%     maxFreqsList = freqs(maxIdx);
%     
%     
%     freqIdx = 533; % freq - 16.6667
%     meanData = squeeze(mean(mean(allSpectra(:,iPlot,iPhase,chans,freqIdx),1),5)); 
%     topoplot(meanData,chanlocs(1:15),...
%         'maplimits',[0,1]);
%     
%     %cbar
% end



        