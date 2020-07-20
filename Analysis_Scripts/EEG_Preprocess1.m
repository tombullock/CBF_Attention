%{
EEG_Preprocess1
Author: Tom Bullock, UCSB Attention Lab
Date: 06.08.19 (last updated 06.24.20)

Notes:
If we need to re-extract data from behavior, see previous version of
this script in 2018 data revisit file.
May want to revisit P3 analyses now I have more data?
See 2018 script for info on splitting data into various epoch lengths...
See README.md file for info on subjects!

Make script flexible for importing CNTs or MATs (split)

%}

%load eeglab into path
cd '/home/bullock/matlab_2016b/TOOLBOXES/eeglab14_1_1b'
eeglab
clear 
close all
cd /home/bullock/CBF_Attention/Analysis_Scripts

%subjectNumbers = [134,237,350,576,577,578,588,592]; %pre2019
subjects = [134,237,350,576,577,578,588,592]; %999%998%997;% 249;

% set dirs (remove redundant ones)
eegRawDir = '/home/bullock/CBF_Attention/EEG_Raw';
behRawDir = '/home/bullock/CBF_Attention/BEH_Raw';
eegFtDir = '/home/bullock/CBF_Attention/EEG_Ft';

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
        if sjNum==249
            load([eegRawDir '/' sprintf('sj%d_',sjNum) thisCond '.mat'])
        else
            EEG = pop_loadcnt([eegRawDir '/' sprintf('sj%d_',sjNum) thisCond '.cnt'] ,'dataformat', 'auto', 'memmapfile', ''); % import cnt 
        end
        
        EEG = pop_reref( EEG, [16 17] ,'keepref','on');% ref to channels 16 and 17 (mastoids 1&2)
        EEG=pop_chanedit(EEG, 'lookup','/home/bullock/matlab_2016b/TOOLBOXES/eeglab14_1_1b/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp'); % add channel data
        EEG = pop_eegfiltnew(EEG, 0.1, 30); % filter
        
        % remove unnecessary channels
        if ismember(sjNum,[249,997,998,999])
            EEG = pop_select(EEG,'nochannel',[18,19,20,23]); % remove extra unnecessary chans
            disp('Removing Channels 18,19,20,23 - is this correct?')
        end
        
        % remove eye-blinks using AAR toolbox
        EEG = pop_crls_regression( EEG, [18 19], 1, 0.9999, 0.01,[]);
        
%         % add study/behavioral data to EEG struct (not necessary)
%         if sjNum==249
%             EEG.studyInfo = load([behRawDir '/' sprintf('sj%d_',sjNum) thisCond '_beh.mat']);
%         else
%             EEG.studyInfo = load([behRawDir '/' sprintf('sj%d_',sjNum) thisCond '.mat']);
%         end
        
        % save data
        save([eegFtDir '/' sprintf('sj%d_',sjNum) thisCond '_ft.mat'],'EEG')
        
        catch
           disp(['Skipping sj ' num2str(sjNum) ' cond ' thisCond]) 
        end
    
    end
end

%%% REMOVE FROM HERE ONWARDS






%%%%%%%%%%%%%%%%%%%%%%% tom comment on 062420 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% 
% 
% 
% %Draw the data.(adhoc)
% eegplot(EEG.data,...
%     'eloc_file',EEG.chanlocs, ...
%     'srate',EEG.srate,...
%     'events',EEG.event);
% 
% 
% 
% 
% 
% %% import and preprocess data
% for i=1:size(subjectNumbers,2)
%     iSub = subjectNumbers(i);
%     dirTmp = [];
%     dirTmp = dir(sprintf('%02d*.cnt',iSub));    % find all the files with that sjNum in the dir and the .cnt file extension
%     
%     %% loop through each of the subject files
%     for j=1:size(dirTmp,1)
%         eeg_file = dirTmp(j).name;   % pulls out string name
%         eeg_file = strrep(eeg_file,'.cnt',''); % gets rid of .bdf file extension
%         
%         % import neuroscan files and preprocess
%         if importFilterCNTs == 1         
%             
%             % preprocessing
%             EEG = pop_loadcnt([eegRawDir '/' eeg_file '.cnt'] ,'dataformat', 'auto', 'memmapfile', '');% imports neuroscan (.cnt) file  
%             EEG = pop_reref( EEG, [16 17] ,'keepref','on');% references to channels 16 and 17 (mastoids 1&2)
%             EEG=pop_chanedit(EEG, 'lookup','/home/bullock/matlab_2011b/TOOLBOXES/eeglab13_0_1b/plugins/dipfit2.2/standard_BESA/standard-10-5-cap385.elp'); % add channel data    
%             EEG = pop_eegfiltnew(EEG, 0.1, 30); % filter data
%             
%             % add binlist and overwrites EEG event list with bin labels 
%             EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString',{ 'boundary' } );       
%             if iSub~=578% applies binlist for all subs EXCEPT 578 (no resps logged)    
%                 %Apply binlist (needs to be from a set loc + need to create logfiles props)
%                 EEG  = pop_binlister( EEG , 'BDF', ['/home/bullock/Calgary/Data_Revisit_2018/Analysis' '/bin_lister_calgary_data.txt'],...
%                 'ExportEL', ['/home/bullock/Calgary/Data_Revisit_2018/EEG_Bin_Lister_Logs' '/' 'bin_lister_log_' eeg_file '.txt'], 'IndexEL',  1, 'SendEL2',...
%                 'EEG&Text', 'UpdateEEG', 'on', 'Voutput', 'EEG' );
%             elseif iSub==578   
%                 %Apply binlist (needs to be from a set loc + need to create logfiles props)
%                 EEG  = pop_binlister( EEG , 'BDF', ['/home/bullock/Calgary/Data_Revisit_2018/Analysis' '/bin_lister_calgary_data_special_578.txt'],...
%                 'ExportEL', ['/home/bullock/Calgary/Data_Revisit_2018/EEG_Bin_Lister_Logs' '/' 'bin_lister_log_' eeg_file '.txt'], 'IndexEL',  1, 'SendEL2',...
%                 'EEG&Text', 'UpdateEEG', 'on', 'Voutput', 'EEG' );
%             end             
%             EEG = pop_overwritevent( EEG, 'binlabel'); 
%             
%             % correct for eyeblinks using crls
%             EEG = pop_crls_regression( EEG, [18 19], 1, 0.9999, 0.01,[]);%Corrects for blinks using regression (Conventional RLS) 
%             
%             % save data
%             EEG = pop_saveset(EEG,'filename', [eeg_file '_ft_bl.set'],'filepath',eegFtDir);
%             
%         end
%     end
% end
% 
% 
% %% Generate regular length epochs
% for i=1:size(subjectNumbers,2)
%     iSub = subjectNumbers(i);
%     dirTmp = [];
%     dirTmp = dir(sprintf('sj%02d*.cnt',iSub));    % find all the files with that sjNum in the dir and the .cnt file extension
%     
%     %% loop through each of the subject files
%     for j=1:size(dirTmp,1)
%         eeg_file = dirTmp(j).name;   % pulls out string name
%         eeg_file = strrep(eeg_file,'.cnt',''); % gets rid of .bdf file extension
%         
%         %% do epoching
%         if epochDataAR==1
%             
%             % slightly different bin epoching for sub 578 coz no responses
%             % logged.  This allows them to be processed normally...
%             if iSub~=578
%                 nBinTypes=1:6;
%             elseif iSub==578
%                 nBinTypes=[1 2 5 6];
%             end
%             
%             % extract epochs from different subjects/conditions
%             for m=nBinTypes
% 
%                 % define names of bins (not sure if all needed)
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
%                 % saves each bin epoched dataset separately
%                 %EEG = pop_saveset(EEG, 'filename', ['x' eeg_file '_ft_bl_ep' epochName '.set'],'filepath',eegEpDir);
%                 
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
%                 
%                 % create "rejection matrix" (easy AR total viewing)
%                 if m==1                
%                     newRejMatrix.std(i,1) = iSub;
%                     newRejMatrix.std(i,j+1) = sum(EEG.reject.rejthresh);
%                     newRejMatrix.stdntrials(i,1) = iSub;
%                     newRejMatrix.stdntrials(i,j+1) = size(EEG.epoch,2);               
%                 elseif m==2 
%                     newRejMatrix.hit(i,1) = iSub;
%                     newRejMatrix.hit(i,j+1) = sum(EEG.reject.rejthresh);
%                     newRejMatrix.hitntrials(i,1) = iSub;
%                     newRejMatrix.hitntrials(i,j+1) = size(EEG.epoch,2); 
% %                 elseif m==3
% %                     newRejMatrix.miss(i,1) = iSub;
% %                     newRejMatrix.miss(i,j+1) = sum(EEG.reject.rejthresh);
% %                     newRejMatrix.missntrials(i,1) = iSub;
% %                     newRejMatrix.missntrials(i,j+1) = size(EEG.epoch,2);  
%                 end  
%                 save([dataCompiled '/' 'newRejMatrix.mat'],'newRejMatrix');
%                 
%                 %% save the epoched datasets
%                 EEG = pop_saveset(EEG, 'filename', ['x' eeg_file '_ft_bl_ep_ar_' epochName '.set'],'filepath',eegEpDir);
% 
% %                 if m~=4
% %                     EEG = pop_saveset(EEG, 'filename', ['x' eeg_file '_ft_bl_ep_ar_' epochName '.set'],'filepath',[cdTmp '/A_REGULAR_EPOCHS/']);
% %                 elseif m==4
% %                     EEG = pop_saveset(EEG, 'filename', ['x' eeg_file '_ft_bl_ep_ar_' epochName '.set'],'filepath',[cdTmp '/A_REGULAR_EPOCHS/']);
% %                     EEG = pop_saveset(EEG, 'filename', ['x' eeg_file '_ft_bl_ep_ar_' epochName '.set'],'filepath',[cdTmp '/A_STUDY_RESP_LOCKED/']);    % save a version in separate folder for separate STUDY
% %                 end
%             end    
%         end
%     end
% end
% 
% %% generate large (45s) epochs for standards/targets
% %% Generate regular length epochs
% for i=1:size(subjectNumbers,2)
%     iSub = subjectNumbers(i);
%     dirTmp = [];
%     dirTmp = dir(sprintf('sj%02d*.cnt',iSub));    % find all the files with that sjNum in the dir and the .cnt file extension
%     
%     %% loop through each of the subject files
%     for j=1:size(dirTmp,1)
%         eeg_file = dirTmp(j).name;   % pulls out string name
%         eeg_file = strrep(eeg_file,'.cnt',''); % gets rid of .bdf file extension
%         if epochDataLong==1
%             
%             % loop extracts 3 main types of epoch from each
%             % subject/condition
%             for m=1:2
%                 
%                 % define names of bins
%                 if m==1; binName='100'; epochName='TASK';  % task block
%                 elseif m==2; binName='200'; epochName='FIX';  % fixation block
%                 end
%                 
%                 %Re-Loads the dataset
%                 EEG = pop_loadset([eegFtDir '/' eeg_file '_ft_bl.set']); %Re-Loads the dataset
% 
%                 %%%EEG = pop_loadset([eeg_file '_ft_bl.set']);
%                 
%                 % epochs bins
%                 EEG = pop_epoch( EEG, {  binName  }, [0 45], 'newname', [sprintf('sj%02d',iSub) 'long_epochs_' epochName], 'epochinfo', 'yes');
%                 
%                 % removes pre-stim baseline (WHOLE BASELINE LATENCY)
%                 EEG = pop_rmbase( EEG, [30 44]);
%                 
%                 %                     % corrects for blinks using regression (AAR
%                 %                     % Conventional RLS)
%                 %                     EEG = pop_crls_regression( EEG, [18 19], 1, 0.9999, 0.01,[]);
%                 
%                 %                     % threshold AR - CAN'T DO THIS COZ ALL EPOCHS
%                 %                     REJECTED BECAUSE THEY'RE SO LONG*
%                 %                     chans = [7:15 18 19];   % 16/17 are mastoids
%                 %                     minAmp = -100;
%                 %                     maxAmp = 100;
%                 %                     minTime = -.1;
%                 %                     maxTime = .5;
%                 %
%                 %                     EEG = pop_eegthresh(EEG,1,chans,minAmp,maxAmp,minTime,maxTime,0,0);    % final zero marks for rej but doesn't rej
%                 %                     pop_summary_AR_eeg_detection(EEG, [cdTmp '/AR_summary_EEGLAB_LONG_EPOCHS/' eeg_file '_' epochName '_AR_sum.txt']);  % creates summary
%                 %                     EEG = pop_eegthresh(EEG,1,chans,minAmp,maxAmp,minTime,maxTime,0,1);    % final '1' rejects
%                 
%                 % saves each bin epoched dataset separately
%                 EEG = pop_saveset(EEG, 'filename', ['x' eeg_file '_ft_bl_ep_ar_' epochName '.set'],'filepath',eegEpLongDir);
%                 
%             end
%         end
%     end
% end
% 
% %% Generate 90s data for Hilbert Transform
% for i=1:size(subjectNumbers,2)
%     iSub = subjectNumbers(i);
%     dirTmp = [];
%     dirTmp = dir(sprintf('sj%02d*.cnt',iSub));    % find all the files with that sjNum in the dir and the .cnt file extension
%     
%     %% loop through each of the subject files
%     for j=1:size(dirTmp,1)
%         eeg_file = dirTmp(j).name;   % pulls out string name
%         eeg_file = strrep(eeg_file,'.cnt',''); % gets rid of .bdf file extension
%         if epochData90s==1
%             
%             % loop extracts 3 main types of epoch from each
%             % subject/condition
%             for m=2
%                 
%                 %define names of bins
%                 if m==1; binName='300'; epochName='TASK';  % task block * was 100 originally
%                 elseif m==2; binName='200'; epochName='FIX_TASK';  % fixation block  
%                 end
%                 
%                 %Re-Loads the dataset
%                 EEG = pop_loadset([eegFtDir '/' eeg_file '_ft_bl.set']); %Re-Loads the dataset
% 
%                 % FIX event code latency so that we are actually
%                 % epoching from the FIRST flickering stimulus, not the
%                 % 100 that signals the start of the block.
%                 for i=1:length(EEG.event)                 
%                     if strcmp(EEG.event(i).type,'100')   % if event code is '100'
%                         EEG.event(i+1).type = '300'; % label i+1 event as '300' (this is the real start of the flickering)
%                     end            
%                 end
%                 
%                 % do 90 s epochs
%                 EEG = pop_epoch( EEG, {  binName  }, [0 90], 'newname', [sprintf('sj%02d',iSub) 'long_epochs_' epochName], 'epochinfo', 'yes');
%                 
%                 % remove whole baseline
%                 EEG = pop_rmbase( EEG, []);
%                 
%                 
%                 %                     % corrects for blinks using regression (AAR
%                 %                     % Conventional RLS)
%                 %                     EEG = pop_crls_regression( EEG, [18 19], 1, 0.9999, 0.01,[]);
%                 
%                 %                     % threshold AR - CAN'T DO THIS COZ ALL EPOCHS
%                 %                     REJECTED BECAUSE THEY'RE SO LONG*
%                 %                     chans = [7:15 18 19];   % 16/17 are mastoids
%                 %                     minAmp = -100;
%                 %                     maxAmp = 100;
%                 %                     minTime = -.1;
%                 %                     maxTime = .5;
%                 %
%                 %                     EEG = pop_eegthresh(EEG,1,chans,minAmp,maxAmp,minTime,maxTime,0,0);    % final zero marks for rej but doesn't rej
%                 %                     pop_summary_AR_eeg_detection(EEG, [cdTmp '/AR_summary_EEGLAB_LONG_EPOCHS/' eeg_file '_' epochName '_AR_sum.txt']);  % creates summary
%                 %                     EEG = pop_eegthresh(EEG,1,chans,minAmp,maxAmp,minTime,maxTime,0,1);    % final '1' rejects
%                 
%                 % saves each bin epoched dataset separately
%                 EEG = pop_saveset(EEG, 'filename', ['x' eeg_file '_ft_bl_ep_ar_' epochName '.set'],'filepath',eegEpLongDir);
%                 
%             end
%         end
%     end
% end
% 
% clear 
% close all
% 

%%%%%%%%%%%%%%%%%%%%%%% tom comment on 062420 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%





% % %         % splits the files into large (90s) epochs for blocks of standards
% % %         % and targets
% % %         if LONG_EPOCH_PROCESSING==1
% % %             
% % %             % loop extracts 3 main types of epoch from each
% % %             % subject/condition
% % %             for m=2
% % % 
% % %                 % define names of bins
% % %                 if m==1; binName='300'; epochName='TASK';  % task block * was 100 originally
% % %                 elseif m==2; binName='200'; epochName='FIX_TASK';  % fixation block  
% % %                 end
% % %                                
% % %                     %Re-Loads the dataset
% % %                     EEG = pop_loadset([eeg_file '_ft_bl.set']);
% % %                     
% % %                     
% % %                     % FIX event code latency so that we are actually
% % %                     % epoching from the FIRST flickering stimulus, not the
% % %                     % 100 that signals the start of the block.
% % %                     for i=1:length(EEG.event)
% % %                         
% % %                        if strcmp(EEG.event(i).type,'100')   % if event code is '100' 
% % %                            EEG.event(i+1).type = '300'; % label i+1 event as '300' (this is the real start of the flickering)
% % %                        end
% % %                         
% % %                     end
% % %                     
% % % 
% % %                     % epochs bins (change this to [0 90] if I want to do
% % %                     % the point by point corr stuff
% % %                     EEG = pop_epoch( EEG, {  binName  }, [0 90], 'newname', [sprintf('sj%02d',iSub) 'long_epochs_' epochName], 'epochinfo', 'yes');
% % %                     
% % %                     % removes pre-stim baseline (WHOLE BASELINE LATENCY)
% % %                     % ****NOT SURE ABOUT THIS***
% % %                     EEG = pop_rmbase( EEG, []);
% % %                     
% % % %                     % does the complex demodulation (10Hz +/- 2Hz)
% % % %                     %(ACTIVATE THIS TO DO THE POINT BY POINT CORR)
% % % %                     [EEG, com] = eeg_cdemod(EEG,'freq', 16.67, 'lowpass', 2); % was 10/2
% % % %                     
% % % %                     
% % % %                     
% % % % %                     % corrects for blinks using regression (AAR
% % % % %                     % Conventional RLS) 
% % % % %                     EEG = pop_crls_regression( EEG, [18 19], 1, 0.9999, 0.01,[]);
% % % %  
% % % % %                     % threshold AR - CAN'T DO THIS COZ ALL EPOCHS
% % % % %                     REJECTED BECAUSE THEY'RE SO LONG*
% % % % %                     chans = [7:15 18 19];   % 16/17 are mastoids
% % % % %                     minAmp = -100;
% % % % %                     maxAmp = 100;
% % % % %                     minTime = -.1;
% % % % %                     maxTime = .5;
% % % % %                     
% % % % %                     EEG = pop_eegthresh(EEG,1,chans,minAmp,maxAmp,minTime,maxTime,0,0);    % final zero marks for rej but doesn't rej 
% % % % %                     pop_summary_AR_eeg_detection(EEG, [cdTmp '/AR_summary_EEGLAB_LONG_EPOCHS/' eeg_file '_' epochName '_AR_sum.txt']);  % creates summary
% % % % %                     EEG = pop_eegthresh(EEG,1,chans,minAmp,maxAmp,minTime,maxTime,0,1);    % final '1' rejects 
% % % % 
% % % %                     % saves each bin epoched dataset separately
% % % %                     EEG = pop_saveset(EEG, 'filename', ['x' eeg_file '_ft_bl_ep_ar_' epochName '.set'],'filepath',[cdTmp '/A_CDEMOD_SSVEP/']);  
% % %                     
% % %                     
% % %                      % DO HILBERT TRANFORMATION TO GET INS. AMP/PHASE
% % %                     hilbertFreqs = [9 12];
% % %                     
% % %                     % filter between specified freqs
% % %                     filtEEG = pop_eegfiltnew(EEG,hilbertFreqs(1),hilbertFreqs(2));
% % %                     
% % %                     %loop through scalp chans and do hilbert;
% % %                     for i=1:19
% % %                         i
% % %                         hilbertEEG(i,:,:) = hilbert(squeeze(filtEEG.data(i,:,:))')';
% % %                     end
% % %                     
% % %                     save(['/home/bullock/Calgary/Data_Task/A_Hilbert_Alpha_9-12' '/' eeg_file '_' epochName '_hilbert.mat'],'hilbertEEG') 
% % %                     
% % %             end
% % %         end 
        

          



%%%%%%%%%%%05.27.18%%%%%%%%%%%%%%%



                    
                    
% %                     
% %                     
% %                     
% %                     %======================================================
% %                     % Do pre-threshold rejection accuracy/RT calculations
% %                     %======================================================
% %                  
% %                     %*********** gets nEpochs (no of correct resps) forTARGET FILES ONLY***********
% %                     if m==2 && iSub~=578
% %                         ACC_STRUCT.correctResps(j,:,i) = {j eeg_file size(EEG.epoch,2)};
% %                     end
% % 
% %                     % gets nEpochs (no of missed resps) for TARG_MISSED FILES
% %                     % ONLY
% %                     if m==3 && iSub~=578
% %                         ACC_STRUCT.misses(j,:,i) = {j eeg_file size(EEG.epoch,2)};
% %                     end
% %                     
% %                     % makes sure matrix of RTs is clear from previous EEG
% %                     % file
% %                     clear EEG.respTime.allRespTimesPreAR(iEpochs)
% %                     
% %                     % **********calculates RTs PRE ARTIFACT REJECTION for TARGET HITS**********
% %                     if m==2 && iSub~=578
% %                     nEpochs = size(EEG.epoch,2);
% %                     for iEpochs=1:nEpochs
% %                         % finds position index of response trigger (120) in epoch
% %                         rtLatencyIndex = find(strcmp(EEG.epoch(iEpochs).eventtype,'B4(120)'));
% % 
% %                         % if there are two RTs in the epoch then take the
% %                         % first press if the latency of that press >700ms,
% %                         % and the second press if latency <700ms (becoz length of
% %                         % targ = 750ms and std = 500, so anything <700ms
% %                         % ain't right)
% %                         if size(rtLatencyIndex,2)>1;
% %                             if cell2mat(EEG.epoch(iEpochs).eventlatency(rtLatencyIndex(1)))<=700
% %                                 rtLatencyIndex = rtLatencyIndex(2); % probably a carry-over resp 
% %                             elseif cell2mat(EEG.epoch(iEpochs).eventlatency(rtLatencyIndex(1)))>700 
% %                                 rtLatencyIndex = rtLatencyIndex(1); % probably 2nd press is a double click
% %                             end
% %                         end
% % 
% %                         % matches to appropriate latency value (response RT) then adds respTime to
% %                         % EEG structure (appends a matrix to end of EEG structure)
% %                         respTimeTmp = cell2mat(EEG.epoch(iEpochs).eventlatency(rtLatencyIndex));
% %                         EEG.respTime.allRespTimesPreAR(iEpochs) = respTimeTmp; 
% %                     end
% %                     EEG.respTime.meanRespTimePreAR = mean(EEG.respTime.allRespTimesPreAR);
% %                     EEG.respTime.stDevRespTimePreAR = std(EEG.respTime.allRespTimesPreAR);
% %                     EEG.respTime.lowestRespTimePreAR = min(EEG.respTime.allRespTimesPreAR);
% %                     end
% %                     
% %                     %======================================================
% %                     % RUN THRESHOLD BASED ARTIFACT REJ ON EPOCHED DATA
% %                     %======================================================           
% %                     % Corrects for blinks using regression (AAR/Conventional RLS) 
% % %                   EEG = pop_crls_regression( EEG, [18 19], 1, 0.9999, 0.01,[]);
% % 
% % 
% % 
% % 
% % 
% %                     % do channel based rejection
% %                     
% %                     
% % 
% %                     % threshold AR
% %                     chans = [1:17];   % 16/17 are mastoids, for now just do P, POz and Oz elects
% %                     minAmp = -75;
% %                     maxAmp = 75;
% %                     minTime = epochRej(1);
% %                     maxTime = epochRej(2);
% % 
% %                     EEG = pop_eegthresh(EEG,1,chans,minAmp,maxAmp,minTime,maxTime,0,0);    % final zero marks for rej but doesn't rej 
% %                     pop_summary_AR_eeg_detection(EEG, [cdTmp '/AR_summary_EEGLAB_REGULAR_EPOCHS/' eeg_file '_' epochName '_AR_sum.txt']);  % creates summary
% %                     EEG = pop_eegthresh(EEG,1,chans,minAmp,maxAmp,minTime,maxTime,0,1);    % final '1' rejects marked trials immediately
% % 
% %                     % create "rejection matrix" (use to easily view number of
% %                     % rejected trials in each condition
% %                     if m==1
% %                         
% %                         newRejMatrix.std(i,1) = iSub;
% %                         newRejMatrix.std(i,j+1) = sum(EEG.reject.rejthresh);
% %                         newRejMatrix.stdntrials(i,1) = iSub;
% %                         newRejMatrix.stdntrials(i,j+1) = size(EEG.epoch,2);
% %                         
% %                     elseif m==2
% %                         
% %                         newRejMatrix.hit(i,1) = iSub;
% %                         newRejMatrix.hit(i,j+1) = sum(EEG.reject.rejthresh);
% %                         newRejMatrix.hitntrials(i,1) = iSub;
% %                         newRejMatrix.hitntrials(i,j+1) = size(EEG.epoch,2);
% %                         
% %                     elseif m==3
% %                         
% %                         newRejMatrix.miss(i,1) = iSub;
% %                         newRejMatrix.miss(i,j+1) = sum(EEG.reject.rejthresh);
% %                         newRejMatrix.missntrials(i,1) = iSub;
% %                         newRejMatrix.missntrials(i,j+1) = size(EEG.epoch,2);
% %                         
% %                     end
% %                     
% %                     
% %                      save('newRejMatrix.mat','newRejMatrix');
% %                     
% %                     
% %                     
% % % %                     if m==1 %std
% % % %                         eeglabRejMatrix.std(i,1) = iSub;
% % % %                         eeglabRejMatrix.std(i,j+1) = round(sum(EEG.reject.rejthresh)/size(EEG.reject.rejthresh,2)*100);
% % % %                         eeglabRejMatrix.stdntrials(i,1) = iSub;
% % % %                         eeglabRejMatrix.stdntrials(i,j+1) = size(EEG.epoch,2);
% % % %                     elseif m==2 %target
% % % %                         eeglabRejMatrix.hit(i,1) = iSub;
% % % %                         eeglabRejMatrix.hit(i,j+1) = round(sum(EEG.reject.rejthresh)/size(EEG.reject.rejthresh,2)*100);
% % % %                         eeglabRejMatrix.hitntrials(i,j+1) = size(EEG.epoch,2);
% % % %                     elseif m==3 %target missed
% % % %                         eeglabRejMatrix.miss(i,1) = iSub;
% % % %                         eeglabRejMatrix.miss(i,j+1) = round(sum(EEG.reject.rejthresh)/size(EEG.reject.rejthresh,2)*100);
% % % %                         eeglabRejMatrix.missntrials(i,j+1) = size(EEG.epoch,2);
% % % %                     elseif m==4 %resp locked
% % % %                         eeglabRejMatrix.resplocked(i,1) = iSub;
% % % %                         eeglabRejMatrix.resplocked(i,j+1) = round(sum(EEG.reject.rejthresh)/size(EEG.reject.rejthresh,2)*100);
% % % %                         eeglabRejMatrix.resplockedntrials(i,j+1) = size(EEG.epoch,2);
% % % %                     elseif m==5  %resp locked
% % % %                         eeglabRejMatrix.fixGlobal(i,1) = iSub;
% % % %                         eeglabRejMatrix.fixGlobal(i,j+1) = round(sum(EEG.reject.rejthresh)/size(EEG.reject.rejthresh,2)*100);
% % % %                         eeglabRejMatrix.fixGlobalnTrials(i,j+1) = size(EEG.epoch,2);
% % % %                     elseif m==6 %resp locked
% % % %                         eeglabRejMatrix.taskGlobal(i,1) = iSub;
% % % %                         eeglabRejMatrix.taskGlobal(i,j+1) = round(sum(EEG.reject.rejthresh)/size(EEG.reject.rejthresh,2)*100);
% % % %                         eeglabRejMatrix.taskGlobalnTrials(i,j+1) = size(EEG.epoch,2);
% % % %                         
% % % %                     end
% % % %                     
% % % %                     
% % % %                     save('eeglabRejMatrix.mat','eeglabRejMatrix');
% % 
% % 
% %                     
% %                       
% %                     %======================================================
% %                     % CALCULATE RTs POST EPOCHED BASED ARTIFACT REJ
% %                     %======================================================
% %                     
% %                       % ***********calculates RTs POST ARTIFACT REJECTION*********
% %                       if m==2 && iSub~=578
% %                         nEpochs = size(EEG.epoch,2);
% %                         for jEpochs=1:nEpochs
% %                             % finds position index of response trigger (120) in epoch
% %                             rtLatencyIndex = find(strcmp(EEG.epoch(jEpochs).eventtype,'B4(120)'));
% % 
% %                             % if there are two RTs in the epoch then take the
% %                             % first press if the latency of that press >700ms,
% %                             % and the second press if latency <700ms (becoz length of
% %                             % targ = 750ms and std = 500, so anything <700ms
% %                             % ain't right)
% %                             if size(rtLatencyIndex,2)>1;
% %                                 if cell2mat(EEG.epoch(jEpochs).eventlatency(rtLatencyIndex(1)))<=700
% %                                     rtLatencyIndex = rtLatencyIndex(2); % probably a carry-over resp 
% %                                 elseif cell2mat(EEG.epoch(jEpochs).eventlatency(rtLatencyIndex(1)))>700 
% %                                     rtLatencyIndex = rtLatencyIndex(1); % probably 2nd press is a double click
% %                                 end
% %                             end
% % 
% %                             % matches to appropriate latency value (response RT) then adds respTime to
% %                             % EEG structure (appends a matrix to end of EEG structure)
% %                             respTimeTmp = cell2mat(EEG.epoch(jEpochs).eventlatency(rtLatencyIndex));
% %                             EEG.respTime.allRespTimesPostAR(jEpochs) = respTimeTmp; 
% %                         end 
% %                         EEG.respTime.meanRespTimePostAR = mean(EEG.respTime.allRespTimesPostAR);
% %                         EEG.respTime.lowestRespTimePostAR = min(EEG.respTime.allRespTimesPostAR);
% %                         EEG.respTime.stDevRespTimePostAR = std(EEG.respTime.allRespTimesPostAR);
% %                       end
% %                      
% %                     % *******calculates P3 statistics for HIT trials (Bin 2)******
% %                     channelP3 = 8;  % 8 = Pz
% %                     latencyRange = 201:326; % corresponds to 700 - 1200ms if epoched -.1 to 2...
% %                     
% %                     % ensures these matrices are all clear from previous
% %                     % file...
% %                     clear peakLatValueEpoch
% %                     clear peakLatDataSampleValue
% %                     clear ampValueEpoch
% %                     
% %                     if m==2 && iSub~=578 || m==3 && iSub~=578
% %                         
% %                         % to calculate peak latency values:
% %                         for jEpochs=1:size(EEG.epoch,2)
% %                             % determines the peak latency value in the
% %                             % range specified above
% %                             [peakValue, peakLat] = max(EEG.data(channelP3,latencyRange,jEpochs)); % finds max positive value (peak value) and the latency of that value
% %                             
% %                             % creates matrix of peak latency values (actual
% %                             % times in ms)
% %                             peakLatValueEpoch(jEpochs) = EEG.times(latencyRange(1)+peakLat);
% %                             
% %                             % creates matrix of peak latecy vaules in (data
% %                             % samples)
% %                             peakLatDataSampleValue(jEpochs) = latencyRange(1) + peakLat;
% %                             
% %                             
% % %                             % corrects the peak latency values to correspond to the
% % %                             % latencyRange, then defines a range for from
% % %                             % which to calculate a mean
% % %                             meanLatencyRange = ((latencyRange(1) + peakLat) - meanWindow):((latencyRange(1) + peakLat) + meanWindow);
% % %                             
% % %                             % gets amplitude values in specified range and
% % %                             % gets mean amp value
% % %                             meanAmpValueEpoch(jEpochs) = mean(EEG.data(channelP3, meanLatencyRange,jEpochs));
% %                            
% %                         end  
% %                         
% %                         % to calculate mean amplitude values
% %                         meanWindow = 6;  % 6 samples = +/-24ms
% %                         meanPeakLatDataSample = round(mean(peakLatDataSampleValue));   % gets mean of the peak latency values for that cond.
% %                         
% %                         
% %                         
% %                         for kEpochs=1:size(EEG.epoch,2)
% %                             ampValueEpoch(kEpochs) = mean(EEG.data(channelP3,(meanPeakLatDataSample - meanWindow):(meanPeakLatDataSample + meanWindow),kEpochs)); % gets amplitude value for each epoch at the average peak latency specified above                            
% %                         end
% %                         
% %                         % adds P3 results to structure
% %                         EEG.p3stats.overallPeakLat = mean(peakLatValueEpoch);   % overall peak lat value for this condition
% %                         EEG.p3stats.stdPeakLat = std(peakLatValueEpoch);        % stDev of the peak latencies for this condition
% %                         EEG.p3stats.peakLatEpochs = peakLatValueEpoch;          % vector of the peak lats for each trial in the condition
% %                         EEG.p3stats.overallMeanAmp = mean(ampValueEpoch);
% %                         EEG.p3stats.meanAmpEpochs = ampValueEpoch;
% %                         
% %                     end
% %                     
% %                
% %                     %======================================================
% %                     % SAVES THE EPOCHED DATASETS INTO DIFFERENT LOCATIONS
% %                     %======================================================
% %                     if m~=4
% %                         EEG = pop_saveset(EEG, 'filename', ['x' eeg_file '_ft_bl_ep_ar_' epochName '.set'],'filepath',[cdTmp '/A_REGULAR_EPOCHS/']);
% %                     elseif m==4
% %                         EEG = pop_saveset(EEG, 'filename', ['x' eeg_file '_ft_bl_ep_ar_' epochName '.set'],'filepath',[cdTmp '/A_REGULAR_EPOCHS/']);
% %                         EEG = pop_saveset(EEG, 'filename', ['x' eeg_file '_ft_bl_ep_ar_' epochName '.set'],'filepath',[cdTmp '/A_STUDY_RESP_LOCKED/']);    % save a version in separate folder for separate STUDY
% %                     end    
% %                     
% % 
% %                 
% %                 end
% %                 
% %                 
% % %                 % *****gets RTs for behavioural data in TARGET FILES ONLY*********
% % %                 % CURRENTLT SET TO REPORT PRE_ARTIFACT REJECTION RTs!
% % %                 if m==2 && iSub~=578
% % %                     RT_STRUCT.rtMean(j,:,i) = {j eeg_file EEG.respTime.meanRespTimePreAR };
% % %                     RT_STRUCT.rtStd(j,:,i) = {j eeg_file EEG.respTime.stDevRespTimePreAR };
% % %                     RT_STRUCT.rtMin(j,:,i) = {j eeg_file EEG.respTime.lowestRespTimePreAR };
% % %                 end
% % %                 
% % %                 
% % %                 %******gets P3 peak latency and mean amp stats********
% % %                 if m==2 && iSub~=578
% % %                     P3_STATS_HITS.overallMeanAmp(j,:,i) = {j eeg_file EEG.p3stats.overallMeanAmp };
% % %                     P3_STATS_HITS.overallPeakLat(j,:,i) = {j eeg_file EEG.p3stats.overallPeakLat };
% % %                     P3_STATS_HITS.stdPeakLat(j,:,i) = {j eeg_file EEG.p3stats.stdPeakLat };      
% % %                 end
% % %                 
% % %                 %******gets P3 peak latency and mean amp stats********
% % %                 if m==3 && iSub~=578
% % %                     P3_STATS_MISSES.overallMeanAmp(j,:,i) = {j eeg_file EEG.p3stats.overallMeanAmp };
% % %                     P3_STATS_MISSES.overallPeakLat(j,:,i) = {j eeg_file EEG.p3stats.overallPeakLat };
% % %                     P3_STATS_MISSES.stdPeakLat(j,:,i) = {j eeg_file EEG.p3stats.stdPeakLat };      
% % %                 end
% % %                     
% % %                   clear EEG.p3stats 
% % 
% % % % %                 % COMPLEX DEMODULATION
% % % % %                 if complex_demodulation_alpha==1
% % % % % 
% % % % %                     % re-Loads the dataset
% % % % %                     EEG = pop_loadset([cdTmp '/A_REGULAR_EPOCHS/' 'x' eeg_file '_ft_bl_ep_ar_' epochName '.set']);
% % % % % 
% % % % %                     % does the complex demodulation (10Hz +/- 2Hz)
% % % % %                     [EEG, com] = eeg_cdemod(EEG,'freq', 10, 'lowpass', 2); % was do 10/2 for ALPHA, then pehaps 15/2 for BETA
% % % % % 
% % % % %                     % saves each bin epoched dataset separately
% % % % %                     EEG = pop_saveset(EEG, 'filename', ['z' eeg_file '_ERDERS_ALPHA' epochName '.set'],'filepath',[cdTmp '/A_STUDY_ERDERS_ALPHA/']);
% % % % %                     
% % % % %                 end
% % % % %                 
% % % % %                 if complex_demodulation_ssvep==1
% % % % %                     
% % % % %                     % re-Loads the dataset
% % % % %                     EEG = pop_loadset([cdTmp '/A_REGULAR_EPOCHS/' 'x' eeg_file '_ft_bl_ep_ar_' epochName '.set']);
% % % % % 
% % % % %                     % does the complex demodulation (10Hz +/- 2Hz)
% % % % %                     [EEG, com] = eeg_cdemod(EEG,'freq', 8.33,'lowpass',.1); % was 10/2
% % % % % 
% % % % %                     % saves each bin epoched dataset separately
% % % % %                     EEG = pop_saveset(EEG, 'filename', ['z' eeg_file '_ERDERS_SSVEP' epochName '.set'],'filepath',[cdTmp '/A_STUDY_ERDERS_SSVEP/']);
% % % % %                     
% % % % %                 end 
% %                 
% %             end
% %             
% %             
% %             
% %             
% %         end
% %         
% %     end
% % end
% %         
% %         
% %         
% % 
% % 
% % 
% % 
% %         
% %         
% % 
% % 
% % 
% % 
% % 
% %         
% %         
% % %         % FILTER DATA
% % %         if filterData == 1   % stage tag = ft
% % %             
% % %             % loads .set files
% % %             EEG = pop_loadset([eeg_file '.set']);
% % % 
% % %             % filters data
% % %             
% % %             
% % %             % Saves the file with the channel locations
% % %             EEG.setname = [eeg_file '_ft.set'];
% % %             EEG = pop_saveset(EEG,'filename', [eeg_file '_ft.set']); %OVERWWRITE WITH CHAN INFO
% % %         
% % %         end
% %         
% % %         % CREATE BIN LIST
% % %         if createBinList==1
% % % 
% % %             %Re-Loads the dataset
% % %             EEG = pop_loadset([eeg_file '_ft.set']);
% % % 
% % %             %Create simple eventlist
% % %             EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString',...
% % %             { 'boundary' } );
% % %            
% % %             if iSub~=578
% % %                 % applies binlist for all subs EXCEPT 578 (no resps logged)
% % %                 %Apply binlist (needs to be from a set loc + need to create logfiles props)
% % %                 EEG  = pop_binlister( EEG , 'BDF', [cdTmp '/bin_lister_calgary_data.txt'],...
% % %                 'ExportEL', [cdTmp '/bin_lister_logfiles/bin_lister_log_' eeg_file '.txt'], 'IndexEL',  1, 'SendEL2',...
% % %                 'EEG&Text', 'UpdateEEG', 'on', 'Voutput', 'EEG' );
% % %             elseif iSub==578   
% % %                 %Apply binlist (needs to be from a set loc + need to create logfiles props)
% % %                 EEG  = pop_binlister( EEG , 'BDF', [cdTmp '/bin_lister_calgary_data_special_578.txt'],...
% % %                 'ExportEL', [cdTmp '/bin_lister_logfiles/bin_lister_log_' eeg_file '.txt'], 'IndexEL',  1, 'SendEL2',...
% % %                 'EEG&Text', 'UpdateEEG', 'on', 'Voutput', 'EEG' );
% % %             end
% % %                 
% % %             % overwrites EEG event list with bin labels 
% % %             EEG = pop_overwritevent( EEG, 'binlabel');
% % %             
% % %             %Saves the dataset with _elist_bl
% % %             EEG = pop_saveset(EEG, 'filename', [eeg_file '_ft_bl' '.set']);
% % %             
% % %         end
% %         
% % %         if continuousArtifactCorrection==1
% % %             
% % %              EEG = pop_loadset([eeg_file '_ft_bl' '.set']);
% % %             
% % % %             % CAUTION! artifact subspace reconstruction algoritm: removes... 1) flatlined channels, 2) sets highpass transition filter,
% % % %             % 3) noisy channels, 4) bursts via ASR, 5) irrepearable windows(-1 means deactivated)
% % % %             EEG = clean_rawdata(EEG, -1, -1, -1, 5, -1);
% % %             
% % %             
% % %             EEG = pop_crls_regression( EEG, [18 19], 1, 0.9999, 0.01,[]);%Corrects for blinks using regression (Conventional RLS) 
% % %             
% % %             
% % %             
% % %             %Saves the dataset with _elist_bl
% % %             EEG = pop_saveset(EEG, 'filename', [eeg_file '_ft_bl' '.set']); % saves files with _el_bl (eventlist, binlist) markers    
% % %             
% % %         end
% %         
% %         
% %         
% %         
% % %         if erplabProcessing==1
% % %             
% % %             if binEpochForERPLAB==1
% % %                 
% % %                 %Re-Loads the dataset
% % %                 EEG = pop_loadset([eeg_file '_ft_bl' '.set']);
% % % 
% % %                 %Creates bin-based epochs between -Ams and Bms (e.g. [-200 600]) and uses
% % %                 %the prestimulus period (e.g. [-200 0]) for baseline correction
% % %                 EEG = pop_epochbin( EEG , [-100  1500],  [-100 0]);  %%%MIGHT WANT TO LOOK AT THIS???
% % % 
% % %                 %Saves the bin epoched dataset
% % %                 EEG = pop_saveset(EEG, 'filename', [eeg_file '_ft_bl_be' '.set']);   % saves files with _be extension (epoched but no AR yet)
% % % 
% % %             end
% % %             
% % %             if createERPS == 1;
% % % 
% % %                 EEG = pop_loadset([eeg_file '_ft_bl_be' '.set']);
% % % 
% % %                 %Computes averaged ERP from current database pop_averager(dataset
% % %                 %indices, 1=exclude AR marked trials, 0= no stDev)
% % %                 %%ERP = pop_averager(EEG,1,1,0);
% % %                 ERP = pop_averager( EEG , 'Criterion', 'good', 'ExcludeBoundary', 'on' );
% % % 
% % %                 %Save ERPset 
% % %                 pop_savemyerp(ERP,'erpname',[eeg_file '_ERP.set'],'filename', [eeg_file '.erp'])
% % % 
% % %                 clear EEG
% % %             end
% % %             
% % %         end
% % %         
% % %         
% % %     end
% % % end
% % 
% % 
% % 
% % 
% % %%%%%%%%%%%%%%%%%%%%
% %             
% %         
% %         
% %         
% %         % BIN EPOCH AND ARTIFACT REJECTION
% %         if EEGLAB_PROCESSING==1
% %             
% %             % slightly different bin epoching for sub 578 coz no responses
% %             % logged.  This allows them to be processed normally...
% %             if iSub~=578
% %                 nBinTypes=1:6;
% %             elseif iSub==578
% %                 nBinTypes=[1 2 5 6];
% %             end
% %             
% %             % loop extracts 3 main types of epoch from each
% %             % subject/condition
% %             for m=nBinTypes
% % 
% % 
% %                 % define names of bins
% %                 if m==1; binName='B1(102)'; epochName='STD'; epochSize=[-1 2]; epochRej=[-.1 .5];  % non-target frequent (ORIG = [-1.
% %                 elseif m==2; binName='B2(101)'; epochName='TARG'; epochSize=[-1 3]; epochRej=[-.1 2];   % TARGET RESPONSE (Epochs are response locked) (ORIG = [-.1 2])
% %                 elseif m==3; binName='B3(101)'; epochName='TARG_MISSED'; epochSize=[-1 3]; epochRej=[-.1 2];   % TARGET RESPONSE (Epochs are response locked)
% %                 elseif m==4; binName='B4(120)'; epochName='TARG_RESP_LOCKED'; epochSize=[-.5 .5]; epochRej=[-.5 .5];
% %                 elseif m==5; binName='202'; epochName='FIX_GLOBAL';epochSize=[0 .5]; epochRej=[0 .5];
% %                 elseif m==6; binName='B1(102)'; epochName='TASK_GLOBAL'; epochSize=[0 .5]; epochRej=[0 .5];
% %                     
% %                 end
% %                 
% %                 % CREATES BIN BASED EPOCHS THEN DOES ARTIFACT REJECTION
% %                 if epochs_then_ar ==1
% %                     
% %                     %======================================================
% %                     % EPOCHING STUFF
% %                     %======================================================
% %     
% %                     %Re-Loads the dataset
% %                     EEG = pop_loadset([eeg_file '_ft_bl.set']);
% % 
% %                     % epochs bins
% %                     EEG = pop_epoch( EEG, {  binName  }, epochSize, 'newname', [sprintf('sj%02d',iSub) 'epochs_' epochName], 'epochinfo', 'yes');
% %                     
% %                     if m<5  % if normal epoching
% %                         EEG = pop_rmbase( EEG, [-100 0]);   % MIGHT WANT TO MAKE THIS DIFFERENT FOR RESPONSE LOCKED STUFF!!!
% %                     else % if creating peochs for global analysis
% %                         EEG = pop_rmbase(EEG,[]);
% %                         
% %                     
% %                     end
% %                     
% %                     % saves each bin epoched dataset separately (with X
% %                     % preface)
% %                     EEG = pop_saveset(EEG, 'filename', ['x' eeg_file '_ft_bl_ep' epochName '.set']);
% %                     
% %                     
% %                     
% %                     %======================================================
% %                     % Do pre-threshold rejection accuracy/RT calculations
% %                     %======================================================
% %                  
% %                     %*********** gets nEpochs (no of correct resps) forTARGET FILES ONLY***********
% %                     if m==2 && iSub~=578
% %                         ACC_STRUCT.correctResps(j,:,i) = {j eeg_file size(EEG.epoch,2)};
% %                     end
% % 
% %                     % gets nEpochs (no of missed resps) for TARG_MISSED FILES
% %                     % ONLY
% %                     if m==3 && iSub~=578
% %                         ACC_STRUCT.misses(j,:,i) = {j eeg_file size(EEG.epoch,2)};
% %                     end
% %                     
% %                     % makes sure matrix of RTs is clear from previous EEG
% %                     % file
% %                     clear EEG.respTime.allRespTimesPreAR(iEpochs)
% %                     
% %                     % **********calculates RTs PRE ARTIFACT REJECTION for TARGET HITS**********
% %                     if m==2 && iSub~=578
% %                     nEpochs = size(EEG.epoch,2);
% %                     for iEpochs=1:nEpochs
% %                         % finds position index of response trigger (120) in epoch
% %                         rtLatencyIndex = find(strcmp(EEG.epoch(iEpochs).eventtype,'B4(120)'));
% % 
% %                         % if there are two RTs in the epoch then take the
% %                         % first press if the latency of that press >700ms,
% %                         % and the second press if latency <700ms (becoz length of
% %                         % targ = 750ms and std = 500, so anything <700ms
% %                         % ain't right)
% %                         if size(rtLatencyIndex,2)>1;
% %                             if cell2mat(EEG.epoch(iEpochs).eventlatency(rtLatencyIndex(1)))<=700
% %                                 rtLatencyIndex = rtLatencyIndex(2); % probably a carry-over resp 
% %                             elseif cell2mat(EEG.epoch(iEpochs).eventlatency(rtLatencyIndex(1)))>700 
% %                                 rtLatencyIndex = rtLatencyIndex(1); % probably 2nd press is a double click
% %                             end
% %                         end
% % 
% %                         % matches to appropriate latency value (response RT) then adds respTime to
% %                         % EEG structure (appends a matrix to end of EEG structure)
% %                         respTimeTmp = cell2mat(EEG.epoch(iEpochs).eventlatency(rtLatencyIndex));
% %                         EEG.respTime.allRespTimesPreAR(iEpochs) = respTimeTmp; 
% %                     end
% %                     EEG.respTime.meanRespTimePreAR = mean(EEG.respTime.allRespTimesPreAR);
% %                     EEG.respTime.stDevRespTimePreAR = std(EEG.respTime.allRespTimesPreAR);
% %                     EEG.respTime.lowestRespTimePreAR = min(EEG.respTime.allRespTimesPreAR);
% %                     end
% %                     
% %                     %======================================================
% %                     % RUN THRESHOLD BASED ARTIFACT REJ ON EPOCHED DATA
% %                     %======================================================           
% %                     % Corrects for blinks using regression (AAR/Conventional RLS) 
% % %                   EEG = pop_crls_regression( EEG, [18 19], 1, 0.9999, 0.01,[]);
% % 
% % 
% % 
% % 
% % 
% %                     % do channel based rejection
% %                     
% %                     
% % 
% %                     % threshold AR
% %                     chans = [1:17];   % 16/17 are mastoids, for now just do P, POz and Oz elects
% %                     minAmp = -75;
% %                     maxAmp = 75;
% %                     minTime = epochRej(1);
% %                     maxTime = epochRej(2);
% % 
% %                     EEG = pop_eegthresh(EEG,1,chans,minAmp,maxAmp,minTime,maxTime,0,0);    % final zero marks for rej but doesn't rej 
% %                     pop_summary_AR_eeg_detection(EEG, [cdTmp '/AR_summary_EEGLAB_REGULAR_EPOCHS/' eeg_file '_' epochName '_AR_sum.txt']);  % creates summary
% %                     EEG = pop_eegthresh(EEG,1,chans,minAmp,maxAmp,minTime,maxTime,0,1);    % final '1' rejects marked trials immediately
% % 
% %                     % create "rejection matrix" (use to easily view number of
% %                     % rejected trials in each condition
% %                     if m==1
% %                         
% %                         newRejMatrix.std(i,1) = iSub;
% %                         newRejMatrix.std(i,j+1) = sum(EEG.reject.rejthresh);
% %                         newRejMatrix.stdntrials(i,1) = iSub;
% %                         newRejMatrix.stdntrials(i,j+1) = size(EEG.epoch,2);
% %                         
% %                     elseif m==2
% %                         
% %                         newRejMatrix.hit(i,1) = iSub;
% %                         newRejMatrix.hit(i,j+1) = sum(EEG.reject.rejthresh);
% %                         newRejMatrix.hitntrials(i,1) = iSub;
% %                         newRejMatrix.hitntrials(i,j+1) = size(EEG.epoch,2);
% %                         
% %                     elseif m==3
% %                         
% %                         newRejMatrix.miss(i,1) = iSub;
% %                         newRejMatrix.miss(i,j+1) = sum(EEG.reject.rejthresh);
% %                         newRejMatrix.missntrials(i,1) = iSub;
% %                         newRejMatrix.missntrials(i,j+1) = size(EEG.epoch,2);
% %                         
% %                     end
% %                     
% %                     
% %                      save('newRejMatrix.mat','newRejMatrix');
% %                     
% %                     
% %                     
% % % %                     if m==1 %std
% % % %                         eeglabRejMatrix.std(i,1) = iSub;
% % % %                         eeglabRejMatrix.std(i,j+1) = round(sum(EEG.reject.rejthresh)/size(EEG.reject.rejthresh,2)*100);
% % % %                         eeglabRejMatrix.stdntrials(i,1) = iSub;
% % % %                         eeglabRejMatrix.stdntrials(i,j+1) = size(EEG.epoch,2);
% % % %                     elseif m==2 %target
% % % %                         eeglabRejMatrix.hit(i,1) = iSub;
% % % %                         eeglabRejMatrix.hit(i,j+1) = round(sum(EEG.reject.rejthresh)/size(EEG.reject.rejthresh,2)*100);
% % % %                         eeglabRejMatrix.hitntrials(i,j+1) = size(EEG.epoch,2);
% % % %                     elseif m==3 %target missed
% % % %                         eeglabRejMatrix.miss(i,1) = iSub;
% % % %                         eeglabRejMatrix.miss(i,j+1) = round(sum(EEG.reject.rejthresh)/size(EEG.reject.rejthresh,2)*100);
% % % %                         eeglabRejMatrix.missntrials(i,j+1) = size(EEG.epoch,2);
% % % %                     elseif m==4 %resp locked
% % % %                         eeglabRejMatrix.resplocked(i,1) = iSub;
% % % %                         eeglabRejMatrix.resplocked(i,j+1) = round(sum(EEG.reject.rejthresh)/size(EEG.reject.rejthresh,2)*100);
% % % %                         eeglabRejMatrix.resplockedntrials(i,j+1) = size(EEG.epoch,2);
% % % %                     elseif m==5  %resp locked
% % % %                         eeglabRejMatrix.fixGlobal(i,1) = iSub;
% % % %                         eeglabRejMatrix.fixGlobal(i,j+1) = round(sum(EEG.reject.rejthresh)/size(EEG.reject.rejthresh,2)*100);
% % % %                         eeglabRejMatrix.fixGlobalnTrials(i,j+1) = size(EEG.epoch,2);
% % % %                     elseif m==6 %resp locked
% % % %                         eeglabRejMatrix.taskGlobal(i,1) = iSub;
% % % %                         eeglabRejMatrix.taskGlobal(i,j+1) = round(sum(EEG.reject.rejthresh)/size(EEG.reject.rejthresh,2)*100);
% % % %                         eeglabRejMatrix.taskGlobalnTrials(i,j+1) = size(EEG.epoch,2);
% % % %                         
% % % %                     end
% % % %                     
% % % %                     
% % % %                     save('eeglabRejMatrix.mat','eeglabRejMatrix');
% % 
% % 
% %                     
% %                       
% %                     %======================================================
% %                     % CALCULATE RTs POST EPOCHED BASED ARTIFACT REJ
% %                     %======================================================
% %                     
% %                       % ***********calculates RTs POST ARTIFACT REJECTION*********
% %                       if m==2 && iSub~=578
% %                         nEpochs = size(EEG.epoch,2);
% %                         for jEpochs=1:nEpochs
% %                             % finds position index of response trigger (120) in epoch
% %                             rtLatencyIndex = find(strcmp(EEG.epoch(jEpochs).eventtype,'B4(120)'));
% % 
% %                             % if there are two RTs in the epoch then take the
% %                             % first press if the latency of that press >700ms,
% %                             % and the second press if latency <700ms (becoz length of
% %                             % targ = 750ms and std = 500, so anything <700ms
% %                             % ain't right)
% %                             if size(rtLatencyIndex,2)>1;
% %                                 if cell2mat(EEG.epoch(jEpochs).eventlatency(rtLatencyIndex(1)))<=700
% %                                     rtLatencyIndex = rtLatencyIndex(2); % probably a carry-over resp 
% %                                 elseif cell2mat(EEG.epoch(jEpochs).eventlatency(rtLatencyIndex(1)))>700 
% %                                     rtLatencyIndex = rtLatencyIndex(1); % probably 2nd press is a double click
% %                                 end
% %                             end
% % 
% %                             % matches to appropriate latency value (response RT) then adds respTime to
% %                             % EEG structure (appends a matrix to end of EEG structure)
% %                             respTimeTmp = cell2mat(EEG.epoch(jEpochs).eventlatency(rtLatencyIndex));
% %                             EEG.respTime.allRespTimesPostAR(jEpochs) = respTimeTmp; 
% %                         end 
% %                         EEG.respTime.meanRespTimePostAR = mean(EEG.respTime.allRespTimesPostAR);
% %                         EEG.respTime.lowestRespTimePostAR = min(EEG.respTime.allRespTimesPostAR);
% %                         EEG.respTime.stDevRespTimePostAR = std(EEG.respTime.allRespTimesPostAR);
% %                       end
% %                      
% %                     % *******calculates P3 statistics for HIT trials (Bin 2)******
% %                     channelP3 = 8;  % 8 = Pz
% %                     latencyRange = 201:326; % corresponds to 700 - 1200ms if epoched -.1 to 2...
% %                     
% %                     % ensures these matrices are all clear from previous
% %                     % file...
% %                     clear peakLatValueEpoch
% %                     clear peakLatDataSampleValue
% %                     clear ampValueEpoch
% %                     
% %                     if m==2 && iSub~=578 || m==3 && iSub~=578
% %                         
% %                         % to calculate peak latency values:
% %                         for jEpochs=1:size(EEG.epoch,2)
% %                             % determines the peak latency value in the
% %                             % range specified above
% %                             [peakValue, peakLat] = max(EEG.data(channelP3,latencyRange,jEpochs)); % finds max positive value (peak value) and the latency of that value
% %                             
% %                             % creates matrix of peak latency values (actual
% %                             % times in ms)
% %                             peakLatValueEpoch(jEpochs) = EEG.times(latencyRange(1)+peakLat);
% %                             
% %                             % creates matrix of peak latecy vaules in (data
% %                             % samples)
% %                             peakLatDataSampleValue(jEpochs) = latencyRange(1) + peakLat;
% %                             
% %                             
% % %                             % corrects the peak latency values to correspond to the
% % %                             % latencyRange, then defines a range for from
% % %                             % which to calculate a mean
% % %                             meanLatencyRange = ((latencyRange(1) + peakLat) - meanWindow):((latencyRange(1) + peakLat) + meanWindow);
% % %                             
% % %                             % gets amplitude values in specified range and
% % %                             % gets mean amp value
% % %                             meanAmpValueEpoch(jEpochs) = mean(EEG.data(channelP3, meanLatencyRange,jEpochs));
% %                            
% %                         end  
% %                         
% %                         % to calculate mean amplitude values
% %                         meanWindow = 6;  % 6 samples = +/-24ms
% %                         meanPeakLatDataSample = round(mean(peakLatDataSampleValue));   % gets mean of the peak latency values for that cond.
% %                         
% %                         
% %                         
% %                         for kEpochs=1:size(EEG.epoch,2)
% %                             ampValueEpoch(kEpochs) = mean(EEG.data(channelP3,(meanPeakLatDataSample - meanWindow):(meanPeakLatDataSample + meanWindow),kEpochs)); % gets amplitude value for each epoch at the average peak latency specified above                            
% %                         end
% %                         
% %                         % adds P3 results to structure
% %                         EEG.p3stats.overallPeakLat = mean(peakLatValueEpoch);   % overall peak lat value for this condition
% %                         EEG.p3stats.stdPeakLat = std(peakLatValueEpoch);        % stDev of the peak latencies for this condition
% %                         EEG.p3stats.peakLatEpochs = peakLatValueEpoch;          % vector of the peak lats for each trial in the condition
% %                         EEG.p3stats.overallMeanAmp = mean(ampValueEpoch);
% %                         EEG.p3stats.meanAmpEpochs = ampValueEpoch;
% %                         
% %                     end
% %                     
% %                
% %                     %======================================================
% %                     % SAVES THE EPOCHED DATASETS INTO DIFFERENT LOCATIONS
% %                     %======================================================
% %                     if m~=4
% %                         EEG = pop_saveset(EEG, 'filename', ['x' eeg_file '_ft_bl_ep_ar_' epochName '.set'],'filepath',[cdTmp '/A_REGULAR_EPOCHS/']);
% %                     elseif m==4
% %                         EEG = pop_saveset(EEG, 'filename', ['x' eeg_file '_ft_bl_ep_ar_' epochName '.set'],'filepath',[cdTmp '/A_REGULAR_EPOCHS/']);
% %                         EEG = pop_saveset(EEG, 'filename', ['x' eeg_file '_ft_bl_ep_ar_' epochName '.set'],'filepath',[cdTmp '/A_STUDY_RESP_LOCKED/']);    % save a version in separate folder for separate STUDY
% %                     end    
% %                     
% % 
% %                 
% %                 end
% %                 
% %                 
% %                 % *****gets RTs for behavioural data in TARGET FILES ONLY*********
% %                 % CURRENTLT SET TO REPORT PRE_ARTIFACT REJECTION RTs!
% %                 if m==2 && iSub~=578
% %                     RT_STRUCT.rtMean(j,:,i) = {j eeg_file EEG.respTime.meanRespTimePreAR };
% %                     RT_STRUCT.rtStd(j,:,i) = {j eeg_file EEG.respTime.stDevRespTimePreAR };
% %                     RT_STRUCT.rtMin(j,:,i) = {j eeg_file EEG.respTime.lowestRespTimePreAR };
% %                 end
% %                 
% %                 
% %                 %******gets P3 peak latency and mean amp stats********
% %                 if m==2 && iSub~=578
% %                     P3_STATS_HITS.overallMeanAmp(j,:,i) = {j eeg_file EEG.p3stats.overallMeanAmp };
% %                     P3_STATS_HITS.overallPeakLat(j,:,i) = {j eeg_file EEG.p3stats.overallPeakLat };
% %                     P3_STATS_HITS.stdPeakLat(j,:,i) = {j eeg_file EEG.p3stats.stdPeakLat };      
% %                 end
% %                 
% %                 %******gets P3 peak latency and mean amp stats********
% %                 if m==3 && iSub~=578
% %                     P3_STATS_MISSES.overallMeanAmp(j,:,i) = {j eeg_file EEG.p3stats.overallMeanAmp };
% %                     P3_STATS_MISSES.overallPeakLat(j,:,i) = {j eeg_file EEG.p3stats.overallPeakLat };
% %                     P3_STATS_MISSES.stdPeakLat(j,:,i) = {j eeg_file EEG.p3stats.stdPeakLat };      
% %                 end
% %                     
% %                   clear EEG.p3stats 
% % 
% % % % %                 % COMPLEX DEMODULATION
% % % % %                 if complex_demodulation_alpha==1
% % % % % 
% % % % %                     % re-Loads the dataset
% % % % %                     EEG = pop_loadset([cdTmp '/A_REGULAR_EPOCHS/' 'x' eeg_file '_ft_bl_ep_ar_' epochName '.set']);
% % % % % 
% % % % %                     % does the complex demodulation (10Hz +/- 2Hz)
% % % % %                     [EEG, com] = eeg_cdemod(EEG,'freq', 10, 'lowpass', 2); % was do 10/2 for ALPHA, then pehaps 15/2 for BETA
% % % % % 
% % % % %                     % saves each bin epoched dataset separately
% % % % %                     EEG = pop_saveset(EEG, 'filename', ['z' eeg_file '_ERDERS_ALPHA' epochName '.set'],'filepath',[cdTmp '/A_STUDY_ERDERS_ALPHA/']);
% % % % %                     
% % % % %                 end
% % % % %                 
% % % % %                 if complex_demodulation_ssvep==1
% % % % %                     
% % % % %                     % re-Loads the dataset
% % % % %                     EEG = pop_loadset([cdTmp '/A_REGULAR_EPOCHS/' 'x' eeg_file '_ft_bl_ep_ar_' epochName '.set']);
% % % % % 
% % % % %                     % does the complex demodulation (10Hz +/- 2Hz)
% % % % %                     [EEG, com] = eeg_cdemod(EEG,'freq', 8.33,'lowpass',.1); % was 10/2
% % % % % 
% % % % %                     % saves each bin epoched dataset separately
% % % % %                     EEG = pop_saveset(EEG, 'filename', ['z' eeg_file '_ERDERS_SSVEP' epochName '.set'],'filepath',[cdTmp '/A_STUDY_ERDERS_SSVEP/']);
% % % % %                     
% % % % %                 end 
% %                 
% %             end
% %         end  
% %         
% % %         % splits the files into large (90s) epochs for blocks of standards
% % %         % and targets
% % %         if LONG_EPOCH_PROCESSING==1
% % %             
% % %             % loop extracts 3 main types of epoch from each
% % %             % subject/condition
% % %             for m=2
% % % 
% % %                 % define names of bins
% % %                 if m==1; binName='300'; epochName='TASK';  % task block * was 100 originally
% % %                 elseif m==2; binName='200'; epochName='FIX_TASK';  % fixation block  
% % %                 end
% % %                                
% % %                     %Re-Loads the dataset
% % %                     EEG = pop_loadset([eeg_file '_ft_bl.set']);
% % %                     
% % %                     
% % %                     % FIX event code latency so that we are actually
% % %                     % epoching from the FIRST flickering stimulus, not the
% % %                     % 100 that signals the start of the block.
% % %                     for i=1:length(EEG.event)
% % %                         
% % %                        if strcmp(EEG.event(i).type,'100')   % if event code is '100' 
% % %                            EEG.event(i+1).type = '300'; % label i+1 event as '300' (this is the real start of the flickering)
% % %                        end
% % %                         
% % %                     end
% % %                     
% % % 
% % %                     % epochs bins (change this to [0 90] if I want to do
% % %                     % the point by point corr stuff
% % %                     EEG = pop_epoch( EEG, {  binName  }, [0 90], 'newname', [sprintf('sj%02d',iSub) 'long_epochs_' epochName], 'epochinfo', 'yes');
% % %                     
% % %                     % removes pre-stim baseline (WHOLE BASELINE LATENCY)
% % %                     % ****NOT SURE ABOUT THIS***
% % %                     EEG = pop_rmbase( EEG, []);
% % %                     
% % % %                     % does the complex demodulation (10Hz +/- 2Hz)
% % % %                     %(ACTIVATE THIS TO DO THE POINT BY POINT CORR)
% % % %                     [EEG, com] = eeg_cdemod(EEG,'freq', 16.67, 'lowpass', 2); % was 10/2
% % % %                     
% % % %                     
% % % %                     
% % % % %                     % corrects for blinks using regression (AAR
% % % % %                     % Conventional RLS) 
% % % % %                     EEG = pop_crls_regression( EEG, [18 19], 1, 0.9999, 0.01,[]);
% % % %  
% % % % %                     % threshold AR - CAN'T DO THIS COZ ALL EPOCHS
% % % % %                     REJECTED BECAUSE THEY'RE SO LONG*
% % % % %                     chans = [7:15 18 19];   % 16/17 are mastoids
% % % % %                     minAmp = -100;
% % % % %                     maxAmp = 100;
% % % % %                     minTime = -.1;
% % % % %                     maxTime = .5;
% % % % %                     
% % % % %                     EEG = pop_eegthresh(EEG,1,chans,minAmp,maxAmp,minTime,maxTime,0,0);    % final zero marks for rej but doesn't rej 
% % % % %                     pop_summary_AR_eeg_detection(EEG, [cdTmp '/AR_summary_EEGLAB_LONG_EPOCHS/' eeg_file '_' epochName '_AR_sum.txt']);  % creates summary
% % % % %                     EEG = pop_eegthresh(EEG,1,chans,minAmp,maxAmp,minTime,maxTime,0,1);    % final '1' rejects 
% % % % 
% % % %                     % saves each bin epoched dataset separately
% % % %                     EEG = pop_saveset(EEG, 'filename', ['x' eeg_file '_ft_bl_ep_ar_' epochName '.set'],'filepath',[cdTmp '/A_CDEMOD_SSVEP/']);  
% % %                     
% % %                     
% % %                      % DO HILBERT TRANFORMATION TO GET INS. AMP/PHASE
% % %                     hilbertFreqs = [9 12];
% % %                     
% % %                     % filter between specified freqs
% % %                     filtEEG = pop_eegfiltnew(EEG,hilbertFreqs(1),hilbertFreqs(2));
% % %                     
% % %                     %loop through scalp chans and do hilbert;
% % %                     for i=1:19
% % %                         i
% % %                         hilbertEEG(i,:,:) = hilbert(squeeze(filtEEG.data(i,:,:))')';
% % %                     end
% % %                     
% % %                     save(['/home/bullock/Calgary/Data_Task/A_Hilbert_Alpha_9-12' '/' eeg_file '_' epochName '_hilbert.mat'],'hilbertEEG') 
% % %                     
% % %             end
% % %         end 
% %         
% %         
% % %         % COMPLEX DEMODULATION
% % %         if complex_demodulation==1
% % % 
% % %             % re-Loads the dataset
% % %             EEG = pop_loadset([eeg_file '_ft_icaAR_elist_bl_ep_' epochName '.set']);
% % % 
% % %             % does the complex demodulation (10Hz +/- 2Hz)
% % %             [EEG, com] = eeg_cdemod(EEG,'freq', 10, 'lowpass', 2); % was 10/2
% % % 
% % %             % saves each bin epoched dataset separately
% % %             EEG = pop_saveset(EEG, 'filename', ['z' eeg_file '_ERDERS_' epochName '.set']);
% % %         end
% % %         
% %         
% %         
% %         
% %       
% %         % splits the files into large (90s) epochs for blocks of standards
% %         % and targets
% %         if LONG_EPOCH_PROCESSING==1
% %             
% %             % loop extracts 3 main types of epoch from each
% %             % subject/condition
% %             for m=1:2
% % 
% %                 % define names of bins
% %                 if m==1; binName='100'; epochName='TASK';  % task block
% %                 elseif m==2; binName='200'; epochName='FIX';  % fixation block
% %                 end
% %                                
% %                     %Re-Loads the dataset
% %                     EEG = pop_loadset([eeg_file '_ft_bl.set']);
% % 
% %                     % epochs bins
% %                     EEG = pop_epoch( EEG, {  binName  }, [0 45], 'newname', [sprintf('sj%02d',iSub) 'long_epochs_' epochName], 'epochinfo', 'yes');
% %                     
% %                     % removes pre-stim baseline (WHOLE BASELINE LATENCY)
% %                     % ****NOT SURE ABOUT THIS***
% %                     EEG = pop_rmbase( EEG, [30 44]);
% %                     
% % %                     % corrects for blinks using regression (AAR
% % %                     % Conventional RLS) 
% % %                     EEG = pop_crls_regression( EEG, [18 19], 1, 0.9999, 0.01,[]);
% %  
% % %                     % threshold AR - CAN'T DO THIS COZ ALL EPOCHS
% % %                     REJECTED BECAUSE THEY'RE SO LONG*
% % %                     chans = [7:15 18 19];   % 16/17 are mastoids
% % %                     minAmp = -100;
% % %                     maxAmp = 100;
% % %                     minTime = -.1;
% % %                     maxTime = .5;
% % %                     
% % %                     EEG = pop_eegthresh(EEG,1,chans,minAmp,maxAmp,minTime,maxTime,0,0);    % final zero marks for rej but doesn't rej 
% % %                     pop_summary_AR_eeg_detection(EEG, [cdTmp '/AR_summary_EEGLAB_LONG_EPOCHS/' eeg_file '_' epochName '_AR_sum.txt']);  % creates summary
% % %                     EEG = pop_eegthresh(EEG,1,chans,minAmp,maxAmp,minTime,maxTime,0,1);    % final '1' rejects 
% % 
% %                     % saves each bin epoched dataset separately
% %                     EEG = pop_saveset(EEG, 'filename', ['x' eeg_file '_ft_bl_ep_ar_' epochName '.set'],'filepath',[cdTmp '/A_Epochs_45/']);
% %                     
% %             end
% %         end 
% %         
% %         
% %         
% %         
% %         
% %         
% %         
% %         
% %         if EEGLAB_PROCESSING==1
% %             if iSub~=578
% %                 % calculates accuracy in ACC_STRUCT
% %                 ACC_STRUCT.propHits(j,:,i) = {j eeg_file (cell2mat(ACC_STRUCT.correctResps(j,3,i)) / (cell2mat(ACC_STRUCT.correctResps(j,3,i)) +  cell2mat(ACC_STRUCT.misses(j,3,i))))};
% %             end
% %         end
% %         
% %         
% %         if getLongEpochTimings==1   
% %          %Re-Loads the dataset
% %             EEG = pop_loadset([eeg_file '_ft_bl.set']);
% %             % gets timings for start of fix (100) and task (200) blocks (to
% %             % synch with blood flow data)
% %             tmpCounter = 0;
% %             nEvents = size(EEG.event,2); 
% %             
% %             for iEvent = 1:nEvents
% %                 if find(strcmp(EEG.event(iEvent).type,'100'))
% %                     tmpCounter = tmpCounter+1; 
% %                     eventLatencyMatrix(tmpCounter,1) = str2num(EEG.event(iEvent).type);
% %                     eventLatencyMatrix(tmpCounter,2) = EEG.event(iEvent).latency*(1000/EEG.srate)/1000;  % sample rate is 250, this converts to seconds
% %                 elseif find(strcmp(EEG.event(iEvent).type,'200'))
% %                     tmpCounter = tmpCounter+1; 
% %                     eventLatencyMatrix(tmpCounter,1) = str2num(EEG.event(iEvent).type);
% %                     eventLatencyMatrix(tmpCounter,2) = EEG.event(iEvent).latency*(1000/EEG.srate)/1000;  % sample rate is 250, this converts to seconds
% %                 end  
% %             end
% %             
% %             for iTimes = 1:size(eventLatencyMatrix,1)
% %                 if iTimes == 1
% %                     eventLatencyMatrix(1,3) = 0;
% %                 else
% %                     eventLatencyMatrix(iTimes,3) = eventLatencyMatrix(iTimes,2) - eventLatencyMatrix(1,2)
% %                 end
% %             end
% %             save(['bloodflow_' eeg_file],'eventLatencyMatrix')
% %         end
% %         
% %         
% %          
% %     end
% % end
% % 
% % 
% % if EEGLAB_PROCESSING==1
% %     eeglabRejSummarystds = [sum(eeglabRejMatrix.std(:,2))/size(eeglabRejMatrix.std(:,2),1) sum(eeglabRejMatrix.std(:,3))/size(eeglabRejMatrix.std(:,3),1) sum(eeglabRejMatrix.std(:,4))/size(eeglabRejMatrix.std(:,4),1) sum(eeglabRejMatrix.std(:,5))/size(eeglabRejMatrix.std(:,5),1) sum(eeglabRejMatrix.std(:,6))/size(eeglabRejMatrix.std(:,6),1)];
% %     
% %     eeglabRejSummaryhits = [sum(eeglabRejMatrix.hit(:,2))/size(eeglabRejMatrix.hit(:,2),1) sum(eeglabRejMatrix.hit(:,3))/size(eeglabRejMatrix.hit(:,3),1) sum(eeglabRejMatrix.hit(:,4))/size(eeglabRejMatrix.hit(:,4),1) sum(eeglabRejMatrix.hit(:,5))/size(eeglabRejMatrix.hit(:,5),1) sum(eeglabRejMatrix.hit(:,6))/size(eeglabRejMatrix.hit(:,6),1)];
% %     
% %     eeglabRejSummarymisses = [sum(eeglabRejMatrix.miss(:,2))/size(eeglabRejMatrix.miss(:,2),1) sum(eeglabRejMatrix.miss(:,3))/size(eeglabRejMatrix.miss(:,3),1) sum(eeglabRejMatrix.miss(:,4))/size(eeglabRejMatrix.miss(:,4),1) sum(eeglabRejMatrix.miss(:,5))/size(eeglabRejMatrix.miss(:,5),1) sum(eeglabRejMatrix.miss(:,6))/size(eeglabRejMatrix.miss(:,6),1)];
% %     
% %     eeglabRejSummaryresplocked = [sum(eeglabRejMatrix.resplocked(:,2))/size(eeglabRejMatrix.resplocked(:,2),1) sum(eeglabRejMatrix.resplocked(:,3))/size(eeglabRejMatrix.resplocked(:,3),1) sum(eeglabRejMatrix.resplocked(:,4))/size(eeglabRejMatrix.resplocked(:,4),1) sum(eeglabRejMatrix.resplocked(:,5))/size(eeglabRejMatrix.resplocked(:,5),1) sum(eeglabRejMatrix.resplocked(:,6))/size(eeglabRejMatrix.resplocked(:,6),1)];
% %     save('eeglabRejSummary.mat','eeglabRejSummarystds','eeglabRejSummaryhits','eeglabRejSummarymisses','eeglabRejSummaryresplocked')     
% % end
% % 
% % % % get mean rejection across all subjects
% % % if EEGLAB_PROCESSING==1
% % %     
% % %     new_rej_summary_stds = (sum(eeglabRejMatrix.std,1) ./ sum(eeglabRejMatrix.stdntrials,1))*100;
% % %     
% % %     new_rej_summary_hits = (sum(eeglabRejMatrix.hit,1) ./ sum(eeglabRejMatrix.hitntrials,1))*100;
% % % 
% % %     new_rej_summary_miss = (sum(eeglabRejMatrix.miss,1) ./ sum(eeglabRejMatrix.missntrials,1))*100;
% % %     
% % %     %SEM_stds = 
% % %     
% % % end
% %     
% %     
% % 
% % 
% % if EEGLAB_PROCESSING==1
% %     save('A_RT_SUMMARY','RT_STRUCT')
% %     save('A_ACC_SUMMARY','ACC_STRUCT')
% %     save('P3_STATS_HITS_SUMMARY','P3_STATS_HITS')
% %     save('P3_STATS_MISSES_SUMMARY','P3_STATS_MISSES')
% % end
% % 
% % % creates a grand average if ERPLAB processing (calls GRAND_AVG FUNCTION)
% % % creates a grand average if ERPLAB processing
% % if erplabProcessing == 1
% %     
% %     ERP = pop_gaverager([cdTmp '/GA_AIR_LIST.txt'],'ExcludeNullBin', 'on', 'SEM', 'off');
% %     ERP = pop_savemyerp(ERP, 'erpname', 'GA_AIR_LIST', 'filename', 'GRAND_AVG_AIR.erp');
% %     
% %     ERP = pop_gaverager([cdTmp '/GA_HYPERCAP_LIST.txt'],'ExcludeNullBin', 'on', 'SEM', 'off');
% %     ERP = pop_savemyerp(ERP, 'erpname', 'GA_HYPERCAP_LIST', 'filename', 'GRAND_AVG_HYPERCAP.erp');
% %     
% %     ERP = pop_gaverager([cdTmp '/GA_HYPOCAP_LIST.txt'],'ExcludeNullBin', 'on', 'SEM', 'off');
% %     ERP = pop_savemyerp(ERP, 'erpname', 'GA_HYPOCAP_LIST', 'filename', 'GRAND_AVG_HYPOCAP.erp');
% %     
% %     ERP = pop_gaverager([cdTmp '/GA_HYPOXIA_LIST.txt'],'ExcludeNullBin', 'on', 'SEM', 'off');
% %     ERP = pop_savemyerp(ERP, 'erpname', 'GA_HYPOXIA_LIST', 'filename', 'GRAND_AVG_HYPOXIA.erp');
% % 
% % end
% % 
% % clear all
% % close all