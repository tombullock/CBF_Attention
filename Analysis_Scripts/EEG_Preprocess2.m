%{ 
EEG_Preprocess2
Author: Tom Bullock, UCSB Attention Lab
Date: 06.08.19

Epoch data for various analyses

%}

%load eeglab into path
cd '/home/bullock/matlab_2016b/TOOLBOXES/eeglab14_1_1b'
eeglab
clear 
close all
cd /home/bullock/CBF_Attention/Analysis_Scripts

%subjectNumbers = [134,237,350,576,577,578,588,592]; %pre2019
subjects = [134,237,350,576,577,578,588,592,249,997:999];

% set dirs (remove redundant ones)
analysisDir = '/home/bullock/CBF_Attention/Analysis_Scripts';
binListDir = '/home/bullock/CBF_Attention/EEG_Bin_List_Logs';
eegFtDir = '/home/bullock/CBF_Attention/EEG_Ft';
eegEpTaskDir = '/home/bullock/CBF_Attention/EEG_Ep_Task';

% loop through data and pre-process
for iSub=1:length(subjects)
    sjNum=subjects(iSub);
    % loop through gas challenges
    for j=1:5
        
        clear EEG
        
        if      j==1; thisCond='air';
        elseif  j==2; thisCond='hypercapnia';
        elseif  j==3; thisCond='hypocapnia';
        elseif  j==4; thisCond='hypoxia';
        elseif  j==5; thisCond='hyperair';
        end
        
        try
        
        % load data
        load([eegFtDir '/' sprintf('sj%d_',sjNum) thisCond '_ft.mat'])
        
        % create event list using ERPLAB functions 
        % Bin1=std, Bin2=targ_hit, Bin3=targ_miss, Bin4=resploc?
        EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString',{ 'boundary' } );
        
        if sjNum~=578
            thisBinList = '/bin_lister_calgary_data.txt';
        else
            thisBinList = '/bin_lister_calgary_data_special_578.txt';
        end
        
        EEG  = pop_binlister( EEG , 'BDF', [analysisDir '/' thisBinList],...
                'ExportEL', [binListDir '/' 'bin_lister_log_sj' num2str(sjNum) '_' thisCond '.txt'],...
                'IndexEL',  1, 'SendEL2','EEG&Text', 'UpdateEEG', 'on', 'Voutput', 'EEG' );
            
        EEG = pop_overwritevent( EEG, 'binlabel'); 
        
        % epoch data for various analyses 
        clear EEG_ERP_std EEG_ERP_tar_hit EEG_ERP_tar_miss
        EEG_ERP_std = pop_epoch(EEG,{'B1(102)'},[-1,2]); % for ERP/ERSP [EPOCH SIZE WAS ORIG [-1 3]]
        EEG_ERP_tar_hit = pop_epoch(EEG,{'B2(101)'},[-1,2]); % for ERP/ERSP [EPOCH SIZE WAS ORIG [-1 3]]
        try
            EEG_ERP_tar_miss = pop_epoch(EEG,{'B3(101)'},[-1,2]); % for ERP/ERSP
        catch
            disp('NO MISS TRIALS!')
        end
        EEG_90sec = pop_epoch(EEG,{'200'},[1,89]); % 90 sec x6  fix>task cycle [going out 0,90 means epochs geet cut out]
        EEG_45sec_task = pop_epoch(EEG,{'100'},[1,44]); % 45 sec task 
        EEG_45sec_fix = pop_epoch(EEG,{'200'},[1,44]); % 45 sec fix
        
        % additional Alpha hit/miss analyses
        EEG_alpha_hit = pop_epoch(EEG,{'B2(101)'},[-4,4]);
        try
            EEG_alpha_miss = pop_epoch(EEG,{'B3(101)'},[-4,4]);
        catch
            disp('NO ALPHA MISS TRIALS!')
        end
        
        % add threshold based art. rejection here if needed! (see prev
        % process script)
        
%                 % threshold AR
%                 chans = 1:17;   % 16/17 are mastoids, for now just do P, POz and Oz elects
%                 minAmp = -75;
%                 maxAmp = 75;
%                 minTime = epochRej(1);
%                 maxTime = epochRej(2);
%                 
%                 %%EEG = pop_eegthresh(EEG,1,chans,minAmp,maxAmp,minTime,maxTime,0,0);    % final zero marks for rej but doesn't rej
%                 %%pop_summary_AR_eeg_detection(EEG, [cdTmp '/AR_summary_EEGLAB_REGULAR_EPOCHS/' eeg_file '_' epochName '_AR_sum.txt']);  % creates summary
%                 EEG = pop_eegthresh(EEG,1,chans,minAmp,maxAmp,minTime,maxTime,0,1);    % final '1' rejects marked trials immediately
        
        
        % add subject exception for sj578
        if sjNum==578
            theseAnalyses = [1,2,4:6];
        else
            theseAnalyses = 1:8;
        end
        
        % remove baseline if needed and save data
        for iEpoch = theseAnalyses;
            clear EEG
            if      iEpoch==1; EEG = EEG_ERP_std; thisBaseline = [-100,0]; epochType = 'erp_std'; artRejWindow = [-.1,.5];
            elseif  iEpoch==2; EEG = EEG_ERP_tar_hit; thisBaseline = [-100,0]; epochType = 'erp_tar_hit'; artRejWindow = [.4,1.2];
            elseif  iEpoch==3; EEG = EEG_ERP_tar_miss; thisBaseline = [-100,0]; epochType = 'erp_tar_miss'; artRejWindow = [.4,1.2];
            elseif  iEpoch==4; EEG = EEG_90sec; thisBaseline = []; epochType = 'fixTask90';
            elseif  iEpoch==5; EEG = EEG_45sec_task; thisBaseline = []; epochType = 'task45'; % check this baseline
            elseif  iEpoch==6; EEG = EEG_45sec_fix; thisBaseline = []; epochType = 'fix45'; % check this baseline
                
            elseif  iEpoch==7; EEG = EEG_alpha_hit; thisBaseline = []; epochType = 'alpha_tar_hit'; artRejWindow = [-4,4];
            elseif  iEpoch==8; EEG = EEG_alpha_miss; thisBaseline = []; epochType = 'alpha_tar_miss'; artRejWindow = [-4,4];
                
            end
            
            EEG = pop_rmbase( EEG, thisBaseline); % remove baseline
            
            % do threshold based artifact rejection on short epoch data
            pcRejTrials = [];
            if ismember(iEpoch,[1:3,7:8])
                EEG = pop_eegthresh(EEG,1,1:17,-75,75,artRejWindow(1),artRejWindow(2),0,1);
                pcRejTrials = (sum(EEG.reject.rejthresh)/length(EEG.reject.rejthresh))*100;
            end
            
            
            
            save([eegEpTaskDir '/' sprintf('sj%d_',sjNum) thisCond '_' epochType '_ft_ep.mat'],'EEG','pcRejTrials')
            
        end
        
        catch
            disp(['Skipping sj ' num2str(sjNum) ' cond ' thisCond])  
        end
        
    end
end

clear 
close all


% %% plot P3 for sanity check
% sjNum=249;
% sourceDir = '/home/bullock/CBF_Attention/EEG_Ep_Task';
% for j=1:5
%     %subplot(1,5,j)
%     if      j==1; thisCond='air';
%     elseif  j==2; thisCond='hypercapnia';
%     elseif  j==3; thisCond='hypocapnia';
%     elseif  j==4; thisCond='hypoxia';
%     elseif  j==5; thisCond='hyperair';
%     end
%     
%     %load([sourceDir '/' sprintf('sj%d_',sjNum) thisCond '_erp_std_ft_ep.mat'])
%     %plot(mean(EEG.data(11,1:176,:),3),'color','k','linewidth',3);hold on
%     load([sourceDir '/' sprintf('sj%d_',sjNum) thisCond '_erp_tar_hit_ft_ep.mat'])
%     plot(linspace(500,1000,126),mean(EEG.data(8,376:501,:),3),'linewidth',3,'color','g');hold on
%     
%    load([sourceDir '/' sprintf('sj%d_',sjNum) thisCond '_erp_tar_miss_ft_ep.mat'])
%     plot(linspace(500,1000,126),mean(EEG.data(8,376:501,:),3),'linewidth',3,'color','r');hold on
%     
% end


%%% UP TO HERE %%%
        
        
        
        
        
%         
%         
%              % define names of bins (not sure if all needed)
%                 if m==1; binName='B1(102)'; epochName='STD'; epochSize=[-1 2]; epochRej=[-.1 .5];  % non-target frequent (ORIG = [-1.
%                 elseif m==2; binName='B2(101)'; epochName='TARG'; epochSize=[-1 3]; epochRej=[-.1 2];   % TARGET RESPONSE (Epochs are response locked) (ORIG = [-.1 2])
%                 %elseif m==3; binName='B3(101)'; epochName='TARG_MISSED'; epochSize=[-1 3]; epochRej=[-.1 2];   % TARGET RESPONSE (Epochs are response locked)
%                 %elseif m==4; binName='B4(120)'; epochName='TARG_RESP_LOCKED'; epochSize=[-.5 .5]; epochRej=[-.5 .5];
%                 elseif m==5; binName='202'; epochName='FIX_GLOBAL';epochSize=[0 .5]; epochRej=[0 .5];
%                 elseif m==6; binName='B1(102)'; epochName='TASK_GLOBAL'; epochSize=[0 .5]; epochRej=[0 .5];  
%                 end
%                 
%                 % create bin based epochs and do artifact rej (ext. values)
%                 EEG = pop_loadset([eegFtDir '/' eeg_file '_ft_bl.set']); %Re-Loads the dataset
%                 EEG = pop_epoch( EEG, {  binName  }, epochSize, 'newname', [sprintf('sj%02d',iSub) 'epochs_' epochName], 'epochinfo', 'yes');
%                 
%                 if m<5  % if normal epoching
%                     EEG = pop_rmbase( EEG, [-100 0]);
%                 else % if creating peochs for global analysis
%                     EEG = pop_rmbase(EEG,[]);
%                 end
% 
%         
%         
% 
%         
%         % epoch for ERP analyses
%         EEG = pop_epoch(EEG,{'101','102'},[-.2,1]);
%         
%         %EEG1 = pop_epoch(EEG,{'101'},[-.2,1]) % 101=tar
%         %EEG2 = pop_epoch(EEG,{'102'},[-.2,1]) % 102=std
%         
% 
%         
%     end
% end

% %Draw the data.(adhoc)
% eegplot(EEG.data,...
%     'eloc_file',EEG.chanlocs, ...
%     'srate',EEG.srate,...
%     'events',EEG.event);