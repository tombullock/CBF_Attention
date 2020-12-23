%{
EEG_Plot_ERPs
Author: Tom Bullock
Date: 12.16.20

%}

clear
close all

% set dirs
sourceDir = '/home/bullock/CBF_Attention/Data_Compiled';
destDirPlot = '/home/bullock/CBF_Attention/Plots';

% load ERP data
load([sourceDir '/' 'ERPs_Master.mat'])

% load ERP stats data
load([sourceDir '/' 'ERP_Stats_Resampled.mat'])

% load chanlocs
load([sourceDir '/' 'chanlocs.mat'])

% plot ERPs

% define colors for lines
thisGreen = [0 100 0];
thisRed = [255 0 0 ];
thisBlue = [30 144 255];
thisMagenta = [153 50 204];

h1=figure;
for iChan=5;%1:4
    
    %subplot(1,4,iChan)
    
    if iChan==1; theseChans=1:3;
    elseif iChan==2; theseChans=4:6;
    elseif iChan==3; theseChans=7:9;
    elseif iChan==4; theseChans=10:15;
    elseif iChan==5; theseChans=4:12; % P3 is centered around Pz and includes all these locs
    end
    
    line([500,500],[-4,10],'color','k','linewidth',1.5,'linestyle','--'); hold on
    line([400,1200],[0,0],'color','k','linewidth',1.5,'linestyle','-');
    
    for i=1:4
        
        if i==1; thisColor = thisGreen;
        elseif i==2; thisColor = thisRed;
        elseif i==3; thisColor = thisBlue;
        elseif i==4; thisColor = thisMagenta;
        end
        
        %     plot(EEG.times,squeeze(mean(mean(ERP_Tar(:,i,7:9,:),1),3)),'color',thisColor./255);hold on
        
        meanData = smooth(squeeze(mean(mean(ERP_Tar(:,i,theseChans,:),1),3)),10); % SMOOTHED FOR PLOTTING PURPOSES?
        semData = squeeze(std(mean(ERP_Tar(:,i,theseChans,:),3),0,1))./(sqrt(size(ERP_Tar,1)));
        %shadedErrorBar(EEG.times(351:551),meanData(351:551),semData(351:551),{'color',thisColor./255});hold on
        plot(eegTimes(351:551),meanData(351:551),'color',thisColor./255,'LineWidth',3);hold on
        
        allErps(i,:,:) = squeeze(mean(ERP_Tar(:,i,theseChans,:),3))
        
    end
    
end


set(gca,...
'linewidth',1.5,...
'fontsize',18,...
'XTick',[400,500,600,800,1000,1200],...
'XTickLabel',[-100,0,100,300,500,700],...
'Ylim',[-4,10],...
'YTick',-4:2:10,...
'box','off');

pbaspect([2,1,1]);
    
    

% Plot stats

% % name variables
% var1_name = 'gas'; % gas cond
% var1_levels = 4;
% 
% for iIter=1:750
%     
%     observedData = allErps(:,:,iIter)';
%     
%     statOutput = teg_repeated_measures_ANOVA(observedData,[var1_levels],{var1_name});
% 
%     pMat(iIter) = statOutput(4);
%     
%     H1=ttest(observedData(:,1),observedData(2));
%     H2=ttest(observedData(:,1),observedData(3));
%     H3=ttest(observedData(:,1),observedData(4));
%     
%     allPairwise(1,iIter)=H1;
%     allPairwise(2,iIter)=H2;
%     allPairwise(3,iIter)=H3;
%     
%      
% end

pMat = pValMat(351:551);
allPairwise = pairwiseMat(351:551,:)';
theseTimes = eegTimes(351:551);

% pMat = pMat(351:551);
% allPairwise = allPairwise(:,351:551);
%theseTimes = EEG.times(351:551);

for iIter=1:length(pMat)
    
    if iIter>1 % skip first point (erroneous)
        if pMat(iIter)<.05
            line([theseTimes(iIter), theseTimes(iIter+1)],[-2.5 -2.5],'linewidth',10,'color','k')
            
            if allPairwise(1,iIter)<.05
                line([theseTimes(iIter), theseTimes(iIter+1)],[-5 -5],'linewidth',5,'color',thisRed./255)
            end
            
            if allPairwise(2,iIter)<.05
                line([theseTimes(iIter), theseTimes(iIter+1)],[-3.5 -3.5],'linewidth',10,'color',thisBlue./255)
            end
            
            if allPairwise(3,iIter)<.05
                line([theseTimes(iIter), theseTimes(iIter+1)],[-6 -6],'linewidth',5,'color',thisMagenta./255)
            end
            
        end
    end
    
end

saveas(h1,[destDirPlot '/' 'EEG_ERP_P3.eps'],'epsc');



%h=figure;
%plot(EEG.times(351:551),pMat(351:551))


h2=figure('OuterPosition',[676   640   577   362]);

EEG.times = eegTimes;

for iPlot=1:4
    
    subplot(1,4,iPlot)
    
    theseChans = 1:15;
    theseTimes = find(EEG.times==900):find(EEG.times==1100);
    
    meanData = squeeze(mean(mean(ERP_Tar(:,iPlot,theseChans,theseTimes),1),4));
    
    
    %meanData = squeeze(mean(mean(allSpectra(:,iPlot,iPhase,chans,freqIdx),1),5));
    
    topoplot(meanData,chanlocs(1:15),...
        'maplimits',[0,10]);
    
    %cbar
end

saveas(h2,[destDirPlot '/' 'EEG_ERP_P3_Topos.eps'],'epsc');


















% 
% 
% % PLOT STD DATA [From front to back]
% h=figure;
% for iChan=1:4
%     
%     subplot(1,4,iChan)
%     
%     if iChan==1; theseChans=1:3;
%     elseif iChan==2; theseChans=4:6;
%     elseif iChan==3; theseChans=7:9;
%     elseif iChan==4; theseChans=10:15; % COULD GROUP PO with Parietals? LOOK AT TOPOS!
%     end
%     
%     for i=1:4
%         
%         if i==1; thisColor = thisGreen;
%         elseif i==2; thisColor = thisRed;
%         elseif i==3; thisColor = thisBlue;
%         elseif i==4; thisColor = thisMagenta;
%         end
%         
%         %     plot(EEG.times,squeeze(mean(mean(ERP_Tar(:,i,7:9,:),1),3)),'color',thisColor./255);hold on
%         
%         meanData = squeeze(mean(mean(ERP_Std(:,i,theseChans,:),1),3));
%         semData = squeeze(std(mean(ERP_Std(:,i,theseChans,:),3),0,1))./(sqrt(size(ERP_Std,1)));
%         %shadedErrorBar(EEG.times,meanData,semData,{'color',thisColor./255});hold on
%         plot(EEG.times(226:376),meanData(226:376),'color',thisColor./255,'LineWidth',3);hold on
%         
%     end
%     
% end





%save([destDir '/' 'ERSP_Master.mat'],'allERSP','times','freqs','subjects')

% %% test for differences in number of trials between conditions
% var1_name = 'gas'; % gas cond
% var1_levels = 4;
% 
% observedData = ERP_Tar_nTrials;
% statOutput_ERP_Tar_nTrials = teg_repeated_measures_ANOVA(observedData,[var1_levels],{var1_name});
%     
% observedData = ERP_Std_nTrials;
% statOutput_ERP_Std_nTrials = teg_repeated_measures_ANOVA(observedData,[var1_levels],{var1_name});