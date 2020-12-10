%{
EEG_Plot_Spectrogram_Topos_Bars
Author: Tom Bullock
Date: 12.10.20

Plot Spectrogram from 4-20 Hz, topos, barplots

Note - sj350 (idx=3) has a different freq SSVEP, so exclude from SSVEP plots?

%}

clear
close all

% set directories
sourceDir = '/home/bullock/CBF_Attention/Data_Compiled';
destDir = '/home/bullock/CBF_Attention/Plots';

% load data
load([sourceDir '/' 'EEG_Spectra.mat'])

%allSpectra(3,:,:,:,:) = [];
% % dowsample spectra for plotting
% idx = downsample(1:length(freqs),21);
% freqs = freqs(idx);



% set channels for plotting
theseChans = 10:15;

% define colors for lines
thisGreen = [0 100 0];
thisRed = [255 0 0 ];
thisBlue = [30 144 255];
thisMagenta = [153 50 204];

h=figure('OuterPosition',[676   680   577   322]);

for iPhase=1:2
    subplot(1,2,iPhase)
    for iPlot=1:4
        
        if      iPlot==1; thisColor = thisGreen;
        elseif  iPlot==2; thisColor = thisRed;
        elseif  iPlot==3; thisColor = thisBlue;
        elseif  iPlot==4; thisColor = thisMagenta;
        end
        
        meanData = smooth(squeeze(mean(mean(allSpectra(:,iPlot,iPhase,theseChans,:),1),4)),8);
        
        plot(freqs,meanData,...
            'color',thisColor./255,...
            'LineWidth',3); hold on
        
        set(gca,...
            'xlim',[4,20],...
            'ylim',[0,.6],...
            'ytick',0:.1:.6,...
            'box','off',...
            'fontsize',18,...
            'LineWidth',1.5);
        
        pbaspect([1,1,1]);
        
        
    end
end

% save image
saveas(h,[destDir '/' 'EEG_Spectrograms.eps'],'epsc');


% generate topos

% load channel data
load([sourceDir '/' 'chanlocs.mat'])

h2=figure('OuterPosition',[676   640   577   362]);

cnt=0;
for iPhase=1:2
    
    for iPlot=1:4
        
        cnt=cnt+1;
        subplot(2,4,cnt)
 
        chans = 1:15;
        freqIdx = find(freqs==8):find(freqs==12);
        meanData = squeeze(mean(mean(allSpectra(:,iPlot,iPhase,chans,freqIdx),1),5));
        
        topoplot(meanData,chanlocs(1:15),...
            'maplimits',[0,.3]);
        
        %cbar
    end
end

saveas(h2,[destDir '/' 'EEG_Topos_Alpha.eps'],'epsc');

% generate bar plot for alpha
h3=figure('OuterPosition',[676   640   368   417]);

cnt=0;
for iPhase=1:2
    for iPlot=1:4
        
        cnt=cnt+1;
        
        if      iPlot==1; thisColor = thisGreen;
        elseif  iPlot==2; thisColor = thisRed;
        elseif  iPlot==3; thisColor = thisBlue;
        elseif  iPlot==4; thisColor = thisMagenta;
        end
       
        data = squeeze(mean(mean(allSpectra(:,iPlot,iPhase,theseChans,find(freqs==8):find(freqs==12)),4),5));
        meanData = squeeze(mean(mean(mean(allSpectra(:,iPlot,iPhase,theseChans,find(freqs==8):find(freqs==12)),1),4),5));
        stdData = std(squeeze(mean(mean(allSpectra(:,iPlot,iPhase,theseChans,find(freqs==8):find(freqs==12)),4),5)))./sqrt(size(allSpectra,1));
        
        dataForPlotSpread(:,cnt) = data;
        
        % plot bars
        bar(cnt,meanData, 'FaceColor',thisColor./255); hold on
        

        
        % plot error bars
        errorbar(cnt+.25,meanData,stdData,...
            'Color','k','LineStyle','none','LineWidth',2.5,'CapSize',10); %
        
        % edit plot characteristics
        set(gca,'FontSize',24,...
            'xlim',[.5,8.5],...
            'LineWidth',1.5,...
            'xticklabels',{' ',' ',' ',' '},...
            'xtick',[],...
            'ylim',[0 .4],....
            'box','off');
        
        pbaspect([1,1,1])
        
    end
end

% plot individual data points using plotSpread
plotSpread(dataForPlotSpread,'distributionMarkers',{'.'},'distributionColors',{'k'});
set(findall(h3,'type','line','color','k'),'markerSize',16) %Change marker size
clear dataForPlotSpread

% save
saveas(h3,[destDir '/' 'EEG_Bars_Alpha.eps'],'epsc');


% generate topo plots for SSVEP [REMEMBER SJ350 [idx3]]

h4=figure('OuterPosition',[676   640   577   362]);

cnt=0;
    
for iPlot=1:4
    
    cnt=cnt+1;
    subplot(1,4,cnt)
    
    chans = 1:15;
    
    % option to try and get max freq rather than using actual flicker
    % [16.6667 Hz]...not using this here for plotting yet
    [maxVal,maxIdx] = max(squeeze(mean(allSpectra(:,iPlot,2,10:15,463:589),4)),[],2);
    maxIdx = 463+maxIdx;
    maxFreqsList = freqs(maxIdx);
    
    
    freqIdx = 533; % freq - 16.6667
    meanData = squeeze(mean(mean(allSpectra(:,iPlot,iPhase,chans,freqIdx),1),5)); 
    topoplot(meanData,chanlocs(1:15),...
        'maplimits',[0,1]);
    
    %cbar
end

saveas(h4,[destDir '/' 'EEG_Topos_SSVEP.eps'],'epsc');




% generate SSVEP Bar plots

h5=figure('OuterPosition',[676   640   368   417]);

cnt=0;
for iPlot=1:4
    
    cnt=cnt+1;
    
    if      iPlot==1; thisColor = thisGreen;
    elseif  iPlot==2; thisColor = thisRed;
    elseif  iPlot==3; thisColor = thisBlue;
    elseif  iPlot==4; thisColor = thisMagenta;
    end
    
    
    chans = 10:15;
    freqIdx = 533; % freq - 16.6667
    
    data = squeeze(mean(allSpectra(:,iPlot,2,chans,freqIdx),4)); 
    meanData = squeeze(mean(mean(allSpectra(:,iPlot,2,chans,freqIdx),1),4));
    stdData = std(squeeze(mean(allSpectra(:,iPlot,2,chans,freqIdx),4)))./sqrt(size(data,1)); 

    
    dataForPlotSpread(:,cnt) = data;
    
    % plot bars
    bar(cnt,meanData, 'FaceColor',thisColor./255); hold on
    
    
    
    % plot error bars
    errorbar(cnt+.25,meanData,stdData,...
        'Color','k','LineStyle','none','LineWidth',2.5,'CapSize',10); %
    
    % edit plot characteristics
    set(gca,'FontSize',24,...
        'xlim',[.5,4.5],...
        'LineWidth',1.5,...
        'xticklabels',{' ',' ',' ',' '},...
        'xtick',[],...
        'ylim',[0 1.1],....
        'box','off');
    
    pbaspect([1,1,1])
    
end

% plot individual data points using plotSpread
plotSpread(dataForPlotSpread,'distributionMarkers',{'.'},'distributionColors',{'k'});
set(findall(h5,'type','line','color','k'),'markerSize',16) %Change marker size

% save
saveas(h5,[destDir '/' 'EEG_Bars_SSVEP.eps'],'epsc');



