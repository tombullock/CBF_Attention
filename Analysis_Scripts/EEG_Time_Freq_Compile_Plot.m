%{
EEG_Time_Freq_Compile_Mats
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
subjects = [134,237,350,576,577,578,588,592,249,997:999];

% loop
for iSub=1:length(subjects)
    sjNum=subjects(iSub);
    for iCond=1:4
        
        if       iCond==1; thisCond='air';
        elseif   iCond==2; thisCond='hypercapnia';
        elseif   iCond==3; thisCond='hypocapnia';
        elseif   iCond==4; thisCond='hypoxia';
        end
        
        load([sourceDir '/' sprintf('sj%d_%s_ERSP.mat',sjNum,thisCond)])
        
        allERSP(iSub,iCond,:,:,:) = ersp;
                
    end
end

save([destDir '/' 'ERSP_Master.mat'],'allERSP','times','freqs','subjects')


% plot data on heatmaps
for iChan=5;%1:4
    h=figure('Units','normalized','OuterPosition',[0.0956612650287506         0.392614188532556         0.792995295347621         0.422740524781341]);
    for iPlot=1:4
        
        if      iChan==1; theseChans = 1:3; thisRegion = 'frontal';
        elseif  iChan==2; theseChans = 4:6; thisRegion = 'central';
        elseif  iChan==3; theseChans = 7:9; thisRegion = 'parietal';
        elseif  iChan==4; theseChans = 10:15; thisRegion = 'parieto-occipital';
        elseif  iChan==5; theseChans = 7:15; thisRegion = 'backOfHead';
        end
        
        subplot(1,4,iPlot);
        imagesc(squeeze(mean(mean(allERSP(:,iPlot,theseChans,:,:),1),3)),[-.3,.3]); hold on
        %line([26,26],[1,30],'color','k','linestyle',':','linewidth',2);
        pbaspect([1,1,1])
        set(gca,...
            'YDir','normal',...
            'xTick',[26,52,101,151],...
            'xticklabel',[0,100,300,500],...
            'YTick',[1,4,8,12,16,20,24,28]*1,...
            'YTickLabel',[1,4,8,12,16,20,24,28],...
            'FontSize',24,'LineWidth',1.5);
        
        colormap jet
        %cbar
        
            % draw rectangle to indicate sig theta (150-250ms)
    rectangle('Position',[64,4,36,4],'LineWidth',3,'LineStyle','--'); % indicates sig. theta from 150-300ms
    rectangle('Position',[139,9,12,3],'LineWidth',3,'LineStyle','--'); % indicates sig. alpha from 450-500ms
    %rectangle('Position',[101,13,12,17],'LineWidth',3,'LineStyle','--'); %
    %indicates sig. beta from 300-350ms [non longer comes out when remove
    %ssvep activity from beta]
        
    end
    
    saveas(h,[destDirPlot '/' 'ERSP_' thisRegion '.eps'],'epsc')
end


% create bar plots for sig different regions
h=figure('OuterPosition',[4         512        1743         489]);
%h=figure('OuterPosition',[0.5272         0    0.4167    1.0000],'Units','normalized');

for iPlot=1:2
    subplot(1,2,iPlot);
    if iPlot==1; theseFreqs=4:8; theseTimes = 64:100;
    elseif iPlot==2; theseFreqs=9:12; theseTimes = 139:151;
    elseif iPlot==3; theseFreqs=18:30; theseTimes = 101:113; % was 13:30 originally because forgot to exclude lower beta due to ssvep
    end
    
    % generate data
    theseData = mean(mean(mean(allERSP(:,:,7:15,theseFreqs,theseTimes),3),4),5);
    mean_theseData = mean(theseData,1);
    sem_theseData = std(theseData,0,1)/sqrt(size(theseData,1));
    
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
        
        bar(i,mean_theseData(i),'FaceColor',thisColor./255); hold on
        
    end
    
    
    % plot error bars
    errorbar(1.25:1:4.25,mean_theseData,sem_theseData,...
        'Color','k','LineStyle','none','LineWidth',2.5,'CapSize',10); %
    
    set(gca,'box','off','xticklabels',{' ',' ',' ',' '},'xtick',[],'FontSize',34,'linewidth',1.5,'xlim',[.5,4.5])
    
    pbaspect([2,1,1])
    
    % plot individual data points using plotSpread
    dataForPlotSpread = theseData;
    plotSpread(dataForPlotSpread,'distributionMarkers',{'.'},'distributionColors',{'k'});
    set(findall(h,'type','line','color','k'),'markerSize',20) %Change marker size
    clear dataForPlotSpread
    
    
end

saveas(h,[destDirPlot '/' 'ERSP_Bar_Plots_Theta_Alpha_Beta' '.eps'],'epsc')



%% SAVE PLOT MANUALLY!!! %%%




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



        