%{
CBF_EEG_Plot_Continuous_Data
Author: Tom Bullock
Date: 08.07.20

Create plot for Figure 4 of MS

Note - need to account for sj999 missing data in one condition (

Swap shaded error bar plots for regular plots if i can't get them to output
good.

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
thisGray = [128,128,128];


% load CBF data
load([sourceDir '/' 'BBT_Master.mat'])

% set up figure
%h=figure('Units','normalized','Position',[0,0,.4,1]);
h=figure('Position',[676   695   607   307]);
%h.Renderer = 'painters';

% generate plots for MCA and PCA separately
%subplot(3,1,1);
for iPlot=1:2
    
    if  iPlot==1; theseData = MCA_BBT_HYPERAIR_NEW; thisColor = thisGray;
    elseif  iPlot==2; theseData = MCA_BBT_HYPOCAP_NEW; thisColor = thisBlue;
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
    'yTick',30:10:70,...
    'yLim',[30,70]);
pbaspect([3,1,1]);
line([45,45],[30,70],'linestyle','--','color','k','linewidth',2);
%set(gcf,'Renderer','painters');

saveas(h,[destDir '/' 'CBF_MCA_Continuous_Plot_Control.jpeg'],'jpeg')

h=figure('Position',[676   695   607   307]);

%subplot(3,1,2)
for iPlot=1:2
    
    
    if  iPlot==1; theseData = MCA_BBT_HYPERAIR_NEW; thisColor = thisGray;
    elseif  iPlot==2; theseData = MCA_BBT_HYPOCAP_NEW; thisColor = thisBlue;
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
    'yTick',20:10:70,...
    'yLim',[20,70]);
pbaspect([3,1,1]);
line([45,45],[20,70],'linestyle','--','color','k','linewidth',2);
%set(gcf,'Renderer','painters');

saveas(h,[destDir '/' 'CBF_PCA_Continuous_Plot_Control.jpeg'],'jpeg')



% load Alpha Power data [NEED CONTROL DATA]
load([sourceDir '/' 'Hilbert_Alpha_Master_Control.mat'])
h=figure('Position',[676   695   607   307]);

%subplot(3,1,3)
for iPlot=1:2
    
    if  iPlot==1; theseData = MCA_BBT_HYPERAIR_NEW; thisColor = thisGray;
    elseif  iPlot==2; theseData = MCA_BBT_HYPOCAP_NEW; thisColor = thisBlue;
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
    'yTick',0:20:80,...
    'yLim',[0,80]);
pbaspect([3,1,1]);
line([45,45],[0,80],'linestyle','--','color','k','linewidth',2);
%set(gcf,'Renderer','painters');

saveas(h,[destDir '/' 'Alpha_Continuous_Plot_Control.jpeg'],'jpeg')


% % save figure
% saveas(h,[destDir '/' 'CBF_EEG_Continuous_Plots_Control.eps'],'epsc')
% saveas(h,[destDir '/' 'CBF_EEG_Continuous_Plots_Control.tiff'],'tiff')
% saveas(h,[destDir '/' 'CBF_EEG_Continuous_Plots_Control.jpeg'],'jpeg')
