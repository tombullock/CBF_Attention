
clear
close all

eegRawDir = '/home/bullock/Calgary/Data_Revisit_2018/EEG_RAW_2019';
eegDestDir = '/home/bullock/CBF_Attention/EEG_Converted';

% load file
eeg_file = '249_eeg_cbf_hx_air.cnt'; %96 mins
EEG = pop_loadcnt([eegRawDir '/' eeg_file ] ,'dataformat', 'auto', 'memmapfile', ''); % import cnt 

% split into hypoxia and air conditions
EEG_hypoxia = pop_select(EEG,'point',[EEG.event(183).latency, EEG.event(1632).latency]);
EEG_air = pop_select(EEG,'point',[EEG.event(1633).latency, EEG.event(3078).latency]);

% save files
clear EEG
EEG = EEG_air;
save([eegDestDir '/' 'sj249_air.mat'],'EEG')

clear EEG
EEG = EEG_hypoxia;
save([eegDestDir '/' 'sj249_hypoxia.mat'],'EEG')

clear EEG EEG_hypoxia EEG_air eeg_file

% load file
load([eegDestDir '/' 'sj249_air.mat'])

%%%%%%%%%%

% find events (if event codes are strings)
eventCnt=0
for i=1:length(EEG.event)
    if strcmp(EEG.event(i).type,'200')
        eventCnt=eventCnt+1;
        allEventIndices(eventCnt) = i;
    end
end

% find events (if event codes are numerica)
eventCnt=0;
for i=1:length(EEG.event)
    if EEG.event(i).type==200
        eventCnt=eventCnt+1;
        allEventIndices(eventCnt) = i;
    end
end

