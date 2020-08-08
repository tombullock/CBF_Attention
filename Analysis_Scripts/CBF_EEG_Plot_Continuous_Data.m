%{
CBF_EEG_Plot_Continuous_Data
Author: Tom Bullock
Date: 08.07.20

Create plot for Figure 4 of MS

%}

clear
close

% set dirs
sourceDir = '/home/bullock/CBF_Attention/Data_Compiled';
destDir = '/home/bullock/CBF_Attention/Plots';

% define colors for lines
thisGreen = [0 100 0];
thisRed = [255 0 0 ];
thisBlue = [30 144 255];
thisMagenta = [153 50 204];

% load CBF data
load([sourceDir '/' 'BBT_Master.mat'])

% set up figure
h=figure('Units','normalized','Position',[0,0,.4,1]);
h.Renderer = 'painters';

% generate plots for MCA and PCA separately
subplot(3,1,1);
for iPlot=1:4
    
    if      iPlot==1; theseData = MCA_BBT_AIR_NEW; thisColor = thisGreen;
    elseif  iPlot==2; theseData = MCA_BBT_HYPERCAP_NEW; thisColor = thisRed;
    elseif  iPlot==3; theseData = MCA_BBT_HYPOCAP_NEW; thisColor = thisBlue;
    elseif  iPlot==4; theseData = MCA_BBT_HYPOXIA_NEW; thisColor = thisMagenta;
    end
        
    thisMean = mean(theseData,2);
    thisSEM = std(theseData,0,2)./sqrt(size(theseData,2));
  
    shadedErrorBar(1:90,thisMean,thisSEM,{'color',thisColor./255,'linewidth',2},1); hold on
    
    clear thisMean thisSEM theseData
    
end

set(gca,'LineWidth',1.5,...
    'FontSize',20,...
    'Box','off',...
    'xTick',0:10:90,...
    'xLim',[0,90],...
    'yTick',30:10:80,...
    'yLim',[30,80]);
pbaspect([3,1,1]);
line([45,45],[30,80],'linestyle','--','color','k','linewidth',2);
set(gcf,'Renderer','painters');

subplot(3,1,2)
for iPlot=1:4
    
    if      iPlot==1; theseData = PCA_BBT_AIR_NEW; thisColor = thisGreen;
    elseif  iPlot==2; theseData = PCA_BBT_HYPERCAP_NEW; thisColor = thisRed;
    elseif  iPlot==3; theseData = PCA_BBT_HYPOCAP_NEW; thisColor = thisBlue;
    elseif  iPlot==4; theseData = PCA_BBT_HYPOXIA_NEW; thisColor = thisMagenta;
    end
        
    thisMean = mean(theseData,2);
    thisSEM = std(theseData,0,2)./sqrt(size(theseData,2));
  
    shadedErrorBar(1:90,thisMean,thisSEM,{'color',thisColor./255,'linewidth',2},1); hold on
    
    clear thisMean thisSEM theseData

end

set(gca,'LineWidth',1.5,...
    'FontSize',20,...
    'Box','off',...
    'xTick',0:10:90,...
    'xLim',[0,90],...
    'yTick',20:10:60,...
    'yLim',[20,60]);
pbaspect([3,1,1]);
line([45,45],[20,60],'linestyle','--','color','k','linewidth',2);
set(gcf,'Renderer','painters');


% load Alpha Power data
load([sourceDir '/' 'Hilbert_Alpha_Master.mat'])

subplot(3,1,3)
for iPlot=1:4
    
    if      iPlot==1; thisColor = thisGreen;
    elseif  iPlot==2; thisColor = thisRed;
    elseif  iPlot==3; thisColor = thisBlue;
    elseif  iPlot==4; thisColor = thisMagenta;
    end
    
    theseData = downsampledHilbert;
    
    thisMean = squeeze(mean(theseData(:,iPlot,:),1));
    thisSEM = squeeze(std(theseData(:,iPlot,:),0,1))./sqrt(size(theseData,1));
    
    shadedErrorBar(1:88,thisMean,thisSEM,{'color',thisColor./255,'linewidth',2},1); hold on
    
    clear thisMean thisSEM theseData
    
end

set(gca,'LineWidth',1.5,...
    'FontSize',20,...
    'Box','off',...
    'xTick',0:10:90,...
    'xLim',[0,90],...
    'yTick',2:7,...
    'yLim',[2,7]);
pbaspect([3,1,1]);
line([45,45],[2,7],'linestyle','--','color','k','linewidth',2);
set(gcf,'Renderer','painters');

% save figure
saveas(h,[destDir '/' 'CBF_EEG_Continuous_Plots.eps'],'epsc')
saveas(h,[destDir '/' 'CBF_EEG_Continuous_Plots.eps'],'epsc')