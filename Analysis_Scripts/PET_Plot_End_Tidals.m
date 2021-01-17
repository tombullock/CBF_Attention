%{
PET_Plot_End_Tidals
Author: Tom Bullock
Date: 12.14.20

%}

clear
close all

sourceDir = '/home/bullock/CBF_Attention/Data_Compiled';
destDir = '/home/bullock/CBF_Attention/Plots';

% load PET means, SEMs
load([sourceDir '/' 'PET_Master.mat']);

% plot main experimental PET
h=figure('OuterPosition',[280    26   562   976]);
for iPlot=1:4
    
    subplot(4,1,iPlot);
    
    if      iPlot==1; thisMean = Air_PET(:,[1,4]); thisSEM = Air_PET(:,[3,6]);
    elseif  iPlot==2; thisMean = Hcap_PET(:,[1,4]); thisSEM = Hcap_PET(:,[3,6]);
    elseif  iPlot==3; thisMean = Hpo_PET(:,[1,4]); thisSEM = Hpo_PET(:,[3,6]);
    elseif  iPlot==4; thisMean = Hpox_PET(:,[1,4]); thisSEM = Hpox_PET(:,[3,6]);
    end
    
    % plot O2
    yyaxis left
    shadedErrorBar(1:90,thisMean(:,2),thisSEM(:,2),{'color','b','linestyle','-'}); hold on
    set(gca,'ylim',[40,100],'LineWidth',1.5,'YColor','b','box','off','fontsize',18,'xlim',[1,90],'xtick',[1:10:90,90],'XTickLabel',[0,10:10:90]);
   
    
    % plot CO2
    yyaxis right
    shadedErrorBar(1:90,thisMean(:,1),thisSEM(:,1),{'color','r','linestyle','-'});
    set(gca,'ylim',[20,60],'ytick',[20:10:60],'LineWidth',1.5,'YColor','r','box','off','fontsize',18,'xlim',[1,90],'XTick',[1:10:90,90],'XTickLabel',[0,10:10:90]);
    
    line([45,45],[20,60],'linestyle','--','color','k','linewidth',2);

end

saveas(h,[destDir '/' 'PET_Traces.jpg'],'jpeg')

% plot control PET
h2=figure('OuterPosition',[829   686   562   269]);
for iPlot=1
    
    %subplot(2,1,iPlot);
    
    if      iPlot==1; thisMean = Hv_PET(:,[1,4]); thisSEM = Hv_PET(:,[3,6]);
    end
    
    % plot O2
    yyaxis left
    shadedErrorBar(1:90,thisMean(:,2),thisSEM(:,2),{'color','b','linestyle','-'}); hold on
    set(gca,'ylim',[40,100],'LineWidth',1.5,'YColor','b','box','off','fontsize',18,'xlim',[1,90],'xtick',[1:10:90,90],'XTickLabel',[0,10:10:90]);
    
    % plot CO2
    yyaxis right
    shadedErrorBar(1:90,thisMean(:,1),thisSEM(:,1),{'color','r','linestyle','-'});
    set(gca,'ylim',[20,60],'ytick',[20:10:60],'LineWidth',1.5,'YColor','r','box','off','fontsize',18,'xlim',[1,90],'XTick',[1:10:90,90],'XTickLabel',[0,10:10:90]);
    
    line([45,45],[20,60],'linestyle','--','color','k','linewidth',2);
    
end

saveas(h2,[destDir '/' 'PET_Traces_Control.jpg'],'jpeg')
    
    