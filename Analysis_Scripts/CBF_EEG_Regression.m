%{
CBF_EEG_Regression
Author: Tom Bullock, UCSB Attention Lab
Date: 12.10.20

% DOUBLE CHECK SUBJECT ORDERS ALWAYS THE SAME!

%}

clear
close all

sourceDir = '/home/bullock/CBF_Attention/Data_Compiled';
destDir = '/home/bullock/CBF_Attention/Plots';

% load BBT data
load([sourceDir '/' 'BBT_Master.mat']);

% load Hilbert alpha data
load([sourceDir '/' 'Hilbert_Alpha_Master.mat'])

% regress hilbert alpha against MCA/PCA on point by point basis
    
m=0;

% remove final subject because missing data [confirm this later]

% remove final sub for hypocapnia stuff

%downsampledHilbert(12,:,:) = [];

%PCA_BBT_AIR_NEW(:,12) = [];
%PCA_BBT_HYPERCAP_NEW(:,12) = [];
%PCA_BBT_HYPOCAP_NEW(:,12) = [];
%PCA_BBT_HYPOXIA_NEW(:,12) = [];

%MCA_BBT_AIR_NEW(:,12) = [];
%MCA_BBT_HYPERCAP_NEW(:,12) = [];
MCA_BBT_HYPOCAP_NEW(:,12) = [];
%MCA_BBT_HYPOXIA_NEW(:,12) = [];

% run regressions point by point
for i=1:length(downsampledHilbert)
    
    [B,BINT,R,RINT,REG_STATS_AIR(i,:)] =  regress(downsampledHilbert(:,1,i+m),[PCA_BBT_AIR_NEW(i,:)', MCA_BBT_AIR_NEW(i,:)', ones(12,1) ]);
    [B,BINT,R,RINT,REG_STATS_HYPERCAP(i,:)] =  regress(downsampledHilbert(:,2,i+m),[PCA_BBT_HYPERCAP_NEW(i,:)', MCA_BBT_HYPERCAP_NEW(i,:)', ones(12,1) ]);
    [B,BINT,R,RINT,REG_STATS_HYPOCAP(i,:)] =  regress(downsampledHilbert(1:11,3,i+m),[PCA_BBT_HYPOCAP_NEW(i,:)', MCA_BBT_HYPOCAP_NEW(i,:)', ones(11,1) ]);
    [B,BINT,R,RINT,REG_STATS_HYPOXIA(i,:)] =  regress(downsampledHilbert(:,4,i+m),[PCA_BBT_HYPOXIA_NEW(i,:)', MCA_BBT_HYPOXIA_NEW(i,:)', ones(12,1) ]);
    
end

% generate plot
h=figure('OuterPosition',[1         354        1239         347]);

thisGreen = [0 100 0]./255;
thisRed = [255 0 0 ]./255;
thisBlue = [30 144 255]./255;
thisMagenta = [153 50 204]./255;

% plot the R-square and p-values from the pbp correlation
for iPlot=1:4
    if      iPlot==1; theseData = REG_STATS_AIR(:,1); thisColor = thisGreen;
    elseif  iPlot==2; theseData = REG_STATS_HYPERCAP(:,1); thisColor = thisRed;
    elseif  iPlot==3; theseData = REG_STATS_HYPOCAP(:,1); thisColor = thisBlue;
    elseif  iPlot==4; theseData = REG_STATS_HYPOXIA(:,1); thisColor = thisMagenta;
    end
    
    subplot(1,4,iPlot);
    plot(theseData,...
        'color',thisColor,...
        'LineWidth',3); hold on
    
    line([45,45],[0,.8],'color','k','linestyle','--','linewidth',2); % critical R value
    line([0,90],[.49,.49],'color','k','linestyle','--','linewidth',2)

    
    set(gca,...
        'xlim',[0,90],...
        'ylim',[0,.6],...
        'box','off',...
        'LineWidth',1.5,...
        'fontsize',18,...
        'XTick',0:15:90,...
        'YTick',0:.1:.6)

    pbaspect([1,1,1])
    
end

saveas(h,[destDir '/' 'CBF_EEG_Regression.eps'],'epsc')




