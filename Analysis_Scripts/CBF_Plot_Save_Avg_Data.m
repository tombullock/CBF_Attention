%{
CBF_Plot_Avg_Data
Author: Tom Bullock
Date: 08.07.20

Create plot for Figure 5 of MS

%}

clear
close

% set dirs
sourceDir = '/home/bullock/CBF_Attention/Data_Compiled';
destDir = '/home/bullock/CBF_Attention/Plots';

addpath(genpath('/home/bullock/CBF_Attention/Dependencies'))

% define colors for lines
thisGreen = [0 100 0];
thisRed = [255 0 0 ];
thisBlue = [30 144 255];
thisMagenta = [153 50 204];

% load CBF data
load([sourceDir '/' 'BBT_Master.mat'])

% load CVC data
load([sourceDir '/' 'BBT_CVC_Updated_Dec_2020.mat'])


% set up figure
h=figure('Units','normalized','Position',[0    0.0301    0.7496    0.8970]);
%h.Renderer = 'painters';


%% compute raw MCAv and PCAv (Figs 5a, 5b)

% select subject index (final subject, 999, is missing HPO PCAv measures)
sjIdx=1:11;

mean_MCAv = [
    mean(MCA_BBT_AIR_NEW(31:45,sjIdx),1);...
    mean(MCA_BBT_AIR_NEW(76:90,sjIdx),1);...
    mean(MCA_BBT_HYPERCAP_NEW(31:45,sjIdx),1);...
    mean(MCA_BBT_HYPERCAP_NEW(76:90,sjIdx),1);...
    mean(MCA_BBT_HYPOCAP_NEW(31:45,sjIdx),1);...
    mean(MCA_BBT_HYPOCAP_NEW(76:90,sjIdx),1);...
    mean(MCA_BBT_HYPOXIA_NEW(31:45,sjIdx),1);...
    mean(MCA_BBT_HYPOXIA_NEW(76:90,sjIdx),1);...
    ];

mean_PCAv = [
    mean(PCA_BBT_AIR_NEW(31:45,sjIdx),1);...
    mean(PCA_BBT_AIR_NEW(76:90,sjIdx),1);...
    mean(PCA_BBT_HYPERCAP_NEW(31:45,sjIdx),1);...
    mean(PCA_BBT_HYPERCAP_NEW(76:90,sjIdx),1);...
    mean(PCA_BBT_HYPOCAP_NEW(31:45,sjIdx),1);...
    mean(PCA_BBT_HYPOCAP_NEW(76:90,sjIdx),1);...
    mean(PCA_BBT_HYPOXIA_NEW(31:45,sjIdx),1);...
    mean(PCA_BBT_HYPOXIA_NEW(76:90,sjIdx),1);...
    ];

% transpose matrices so sjs = rows
mean_MCAv = mean_MCAv';
mean_PCAv = mean_PCAv';



%% compute %change in both MCA and PCA from rest to task (Fig 5c)
mean_CBFv_MCA = ((mean_MCAv(:,[2,4,6,8]) - mean_MCAv(:,[1,3,5,7]))./mean_MCAv(:,[1,3,5,7]))*100; 
mean_CBFv_PCA = ((mean_PCAv(:,[2,4,6,8]) - mean_PCAv(:,[1,3,5,7]))./mean_PCAv(:,[1,3,5,7]))*100; 

% combine into one mat for plotting
mean_pc_CBFv_PCA_MCA = [
    mean_CBFv_PCA(:,1), mean_CBFv_MCA(:,1),...
    mean_CBFv_PCA(:,2), mean_CBFv_MCA(:,2),...
    mean_CBFv_PCA(:,3), mean_CBFv_MCA(:,3),...
    mean_CBFv_PCA(:,4), mean_CBFv_MCA(:,4)];


%% rearrange CVC for plotting
mean_MCA_CVC = MCA_CVC(:,[1,5,2,6,3,7,4,8]);
mean_PCA_CVC = PCA_CVC(:,[1,5,2,6,3,7,4,8]);

%% compute %change in CVCs
pc_CVC_MCA = ((mean_MCA_CVC(:,[2,4,6,8]) - mean_MCA_CVC(:,[1,3,5,7]))./mean_MCA_CVC(:,[1,3,5,7]))*100; 
pc_CVC_PCA = ((mean_PCA_CVC(:,[2,4,6,8]) - mean_PCA_CVC(:,[1,3,5,7]))./mean_PCA_CVC(:,[1,3,5,7]))*100; 

% combine into one mat for plotting
mean_pc_CVC_PCA_MCA = [
    pc_CVC_PCA(:,1), pc_CVC_MCA(:,1),...
    pc_CVC_PCA(:,2), pc_CVC_MCA(:,2),...
    pc_CVC_PCA(:,3), pc_CVC_MCA(:,3),...
    pc_CVC_PCA(:,4), pc_CVC_MCA(:,4)];

% remove sjIdx12 from cvc_pca measures
mean_PCA_CVC(12,:) = [];
mean_pc_CVC_PCA_MCA(12,:) = [];

mean_MCA_CVC(12,:) = [];
%mean_pc_CVC_PCA_MCA(12,:) = [];



%% plot 1) MCA, 2) PCA, 3) %change, 4)...
for iPlot=1:6
    
    subplot(2,3,iPlot)
    
    data = [];
    if iPlot==1; data = mean_MCAv; this_yLim = [30,100]; %[30,100];
    elseif iPlot==2; data = mean_PCAv; this_yLim = [10,80]; %[10,80];
    elseif iPlot==3; data = mean_pc_CBFv_PCA_MCA; this_yLim = [-5,25];% [-5,22];
    elseif iPlot==4; data = mean_MCA_CVC; this_yLim = [.3,1.2];% [.1,1.1];
    elseif iPlot==5; data = mean_PCA_CVC; this_yLim = [.1,.9];% [.1,1.1];
    elseif iPlot==6; data = mean_pc_CVC_PCA_MCA; this_yLim = [-5,25];% [-5,25];
    end
    
    % define colors for lines
    thisGreen = [0 100 0];
    thisRed = [255 0 0 ];
    thisBlue = [30 144 255];
    thisMagenta = [153 50 204];
    
    % plot bars
    for i=1:8
        if i==1||i==2; thisColor = thisGreen;
        elseif i==3||i==4; thisColor = thisRed;
        elseif i==5||i==6; thisColor = thisBlue;
        elseif i==7||i==8; thisColor = thisMagenta;
        end
        
        bar(i,mean(data(:,i),1), 'FaceColor',thisColor./255); hold on
    end
    
    % plot individual data points using plotSpread
    plotSpread(data,'distributionMarkers',{'.'},'distributionColors',{'k'});
    set(findall(1,'type','line','color','k'),'markerSize',16) %Change marker size
    
    % plot error bars
    errorbar(1.25:1:8.25,mean(data,1),std(data,0,1)/sqrt(size(data,1)),...
        'Color','k','LineStyle','none','LineWidth',2.5,'CapSize',10); %
    
    % edit plot characteristics
    set(gca,'FontSize',24,...
        'xlim',[.5,8.5],...
        'LineWidth',1.5,...
        'xticklabels',{' ',' ',' ',' '},...
        'xtick',[],...
        'ylim',this_yLim,...
        'box','off'); %        
    
    pbaspect([1,1,1])
    
end

% save averaged BBT data
save(['/home/bullock/CBF_Attention/Data_Compiled' '/' 'BBT_Master_Averaged_Data.mat'],'mean_MCAv','mean_PCAv','mean_pc_CBFv_PCA_MCA','mean_MCA_CVC','mean_PCA_CVC','mean_pc_CVC_PCA_MCA')

% save fig
saveas(h,['/home/bullock/CBF_Attention/Plots' '/' 'CBF_Mean_Plots.eps'],'epsc')


