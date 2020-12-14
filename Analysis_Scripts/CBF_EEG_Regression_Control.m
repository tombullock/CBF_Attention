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
load([sourceDir '/' 'Hilbert_Alpha_Master_Control.mat'])

% regress hilbert alpha against MCA/PCA on point by point basis
    
m=0;

% remove final subject because missing data [confirm this later]

% remove final sub for hypocapnia stuff

% REMOVE FINAL SUBJECT TO BRING TOTAL TO 9
downsampledHilbert(10,:,:) = [];

%PCA_BBT_AIR_NEW(:,12) = [];
%PCA_BBT_HYPERCAP_NEW(:,12) = [];
%PCA_BBT_HYPOCAP_NEW(:,12) = [];
%PCA_BBT_HYPOXIA_NEW(:,12) = [];

%MCA_BBT_AIR_NEW(:,12) = [];
%MCA_BBT_HYPERCAP_NEW(:,12) = [];
MCA_BBT_HYPOCAP_NEW(:,12) = [];
%MCA_BBT_HYPOXIA_NEW(:,12) = [];


% remove sjs 350 and 577 from Hypocap to match hyperair
MCA_BBT_HYPOCAP_NEW(:,[3,5]) = [];
PCA_BBT_HYPOCAP_NEW(:,[3,5]) = [];

% remove final subjects from HYPERAIR
MCA_BBT_HYPERAIR_NEW(:,10) = [];
PCA_BBT_HYPERAIR_NEW(:,10) = [];

% subjectsFull = [134,237,576,578,588,592,249,997:999]; %350,577
% 
% subjects = [134,237,576,578,588,592,249,997:999]; %350,577
% 
% subjectsAll = [134,237,350,576,577,578,588,592,249,997:999];


% run regressions point by point
for i=1:length(downsampledHilbert)
    
    [B,BINT,R,RINT,REG_STATS_HYPERAIR(i,:)] =  regress(downsampledHilbert(:,1,i+m),[PCA_BBT_HYPERAIR_NEW(i,:)', MCA_BBT_HYPERAIR_NEW(i,:)', ones(9,1) ]);
    [B,BINT,R,RINT,REG_STATS_HYPOCAP(i,:)] =  regress(downsampledHilbert(:,2,i+m),[PCA_BBT_HYPOCAP_NEW(i,:)', MCA_BBT_HYPOCAP_NEW(i,:)', ones(9,1) ]);
    
end

% generate plot
h=figure('OuterPosition',[1   354   722   347]);

thisGreen = [0 100 0]./255;
thisRed = [255 0 0 ]./255;
thisBlue = [30 144 255]./255;
thisMagenta = [153 50 204]./255;
thisGray = [128,128,128]./255;

% plot the R-square and p-values from the pbp correlation
for iPlot=1:2
    
    if      iPlot==1; theseData = REG_STATS_HYPERAIR(:,1); thisColor = thisGray;
    elseif  iPlot==2; theseData = REG_STATS_HYPOCAP(:,1); thisColor = thisBlue;
    end
    
    subplot(1,2,iPlot);
    plot(theseData,...
        'color',thisColor,...
        'LineWidth',3); hold on
    
    line([45,45],[0,.8],'color','k','linestyle','--','linewidth',2); % critical R value
    line([0,90],[.55,.55],'color','k','linestyle','--','linewidth',2)

    
    set(gca,...
        'xlim',[0,90],...
        'ylim',[0,.8],...
        'box','off',...
        'LineWidth',1.5,...
        'fontsize',18,...
        'XTick',0:15:90,...
        'YTick',0:.1:.8)

    pbaspect([1,1,1])
    
end

saveas(h,[destDir '/' 'CBF_EEG_Regression_Control.eps'],'epsc')




