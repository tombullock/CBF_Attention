%{
CBF_Plot_Avg_Data
Author: Tom Bullock
Date: 08.07.20

Create plot for Figure 5 of MS

%}

clear
close all

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
%load([sourceDir '/' 'BBT_CVC_Updated_Dec_2020.mat'])
load([sourceDir '/' 'BBT_Master_Control.mat'])


% set up figure
%h=figure('Units','normalized','Position',[0         0.124392614188533         0.367485624673288         0.848396501457726]);
%h.Renderer = 'painters';


%% compute raw MCAv and PCAv (Figs 5a, 5b)

% select subject index (final subject, 999, is missing HPO PCAv measures)
sjIdx=1:10;

mean_MCAv = [
    mean(MCA_BBT_HYPERAIR_NEW(31:45,sjIdx),1);...
    mean(MCA_BBT_HYPERAIR_NEW(76:90,sjIdx),1);...
    mean(MCA_BBT_HYPOCAP_NEW(31:45,sjIdx),1);...
    mean(MCA_BBT_HYPOCAP_NEW(76:90,sjIdx),1);...
    ];

mean_PCAv = [
    mean(PCA_BBT_HYPERAIR_NEW(31:45,sjIdx),1);...
    mean(PCA_BBT_HYPERAIR_NEW(76:90,sjIdx),1);...
    mean(PCA_BBT_HYPOCAP_NEW(31:45,sjIdx),1);...
    mean(PCA_BBT_HYPOCAP_NEW(76:90,sjIdx),1);...
    ];

% transpose matrices so sjs = rows
mean_MCAv = mean_MCAv'; %[Hv_mca_rest,HV_mca_task,Hpo_pca_rest,Hpo_pca_task]
mean_PCAv = mean_PCAv';



%% compute %change in both MCA and PCA from rest to task (Fig 5c)
mean_CBFv_MCA = ((mean_MCAv(:,[2,4]) - mean_MCAv(:,[1,3]))./mean_MCAv(:,[1,3]))*100; 
mean_CBFv_PCA = ((mean_PCAv(:,[2,4]) - mean_PCAv(:,[1,3]))./mean_PCAv(:,[1,3]))*100; 

% combine into one mat for plotting
mean_pc_CBFv_PCA_MCA = [
    mean_CBFv_PCA(:,1), mean_CBFv_MCA(:,1),...
    mean_CBFv_PCA(:,2), mean_CBFv_MCA(:,2)];


%% Change labels of CVC Data ...already in plotting order [HVrest,HVTask,HpoRest,HpoTask]
mean_MCA_CVC = MCA_CVC_Control(1:9,:);%%%(:,[1,3,2,4]);
mean_PCA_CVC = PCA_CVC_Control%%(:,[1,3,2,4]);

%% compute %change in CVCs
pc_CVC_MCA = ((mean_MCA_CVC(:,[2,4]) - mean_MCA_CVC(:,[1,3]))./mean_MCA_CVC(:,[1,3]))*100; 
pc_CVC_PCA = ((mean_PCA_CVC(:,[2,4]) - mean_PCA_CVC(:,[1,3]))./mean_PCA_CVC(:,[1,3]))*100; 

% combine into one mat for plotting
mean_pc_CVC_PCA_MCA = [
    pc_CVC_PCA(:,1), pc_CVC_MCA(:,1),...
    pc_CVC_PCA(:,2), pc_CVC_MCA(:,2)];

% % remove sjIdx12 from cvc_pca measures
% mean_pc_CVC_PCA_MCA(12,:) = [];


%% plot 1) MCA, 2) PCA, 3) %change, 4)...
%h=figure('units','normalized','OuterPosition',[0.534263458060926        0.0824071303381353         0.409653637501739         0.250844269653315]);

for iPlot=1:6
    
    h=figure;
    %subplot(3,2,iPlot)
    
    data = [];
    if iPlot==1; data = mean_MCAv; this_yLim = [20,80]; thisTitle = 'mean_MCAv'; this_yTick = 20:20:80; %[30,100];
    elseif iPlot==3; data = mean_PCAv; this_yLim = [10,70]; thisTitle = 'mean_PCAv'; this_yTick = 10:20:70; %[10,80];
    elseif iPlot==5; data = mean_pc_CBFv_PCA_MCA; this_yLim = [-5,25]; thisTitle = 'mean_pc_CBFv'; this_yTick = -5:5:25;% [-5,22];
    elseif iPlot==2; data = mean_MCA_CVC; this_yLim = [.2,1.2]; thisTitle = 'mean_MCAcvc'; this_yTick = .2:.2:1.2; % [.1,1.1];
    elseif iPlot==4; data = mean_PCA_CVC; this_yLim = [.2,.8]; thisTitle = 'mean_PCAcvc'; this_yTick = .2:.2:.8; % [.1,1.1];
    elseif iPlot==6; data = mean_pc_CVC_PCA_MCA; this_yLim = [-5,30]; thisTitle = 'mean_pc_CVC'; this_yTick = -5:5:30;% [-5,25];
    end
    
    % define colors for lines
    thisBlue = [30 144 255];
    thisGray = [128,128,128];
    
    % plot bars
    for i=1:4
        if i==1||i==2; thisColor = thisGray;
        elseif i==3||i==4; thisColor = thisBlue;
        end
        
        bar(i,mean(data(:,i),1), 'FaceColor',thisColor./255); hold on
    end
    
    % plot individual data points using plotSpread
    plotSpread(data,'distributionMarkers',{'.'},'distributionColors',{'k'});
    set(findall(iPlot,'type','line','color','k'),'markerSize',24) %Change marker size
    
    % plot error bars
    errorbar(1.25:1:4.25,mean(data,1),std(data,0,1)/sqrt(size(data,1)),...
        'Color','k','LineStyle','none','LineWidth',2.5,'CapSize',10); %
    
    % edit plot characteristics
    set(gca,'FontSize',36,...
        'xlim',[.5,4.5],...
        'LineWidth',1.5,...
        'xticklabels',{' ',' ',' ',' '},...
        'xtick',[],...
        'ylim',this_yLim,...
        'YTick',this_yTick,...
        'box','off'); %        
    
    pbaspect([1,1,1])
    
    % save fig
    saveas(h,['/home/bullock/CBF_Attention/Plots' '/' 'CBF_Control_' thisTitle '.eps'],'epsc')
    
end

% save averaged BBT data
save(['/home/bullock/CBF_Attention/Data_Compiled' '/' 'BBT_Master_Averaged_Data_Control.mat'],'mean_MCAv','mean_PCAv','mean_pc_CBFv_PCA_MCA','mean_MCA_CVC','mean_PCA_CVC','mean_pc_CVC_PCA_MCA')




