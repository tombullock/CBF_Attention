%{
EEG_Import_Split_CNT
Author: Tom Bullock, UCSB Attention Lab
Date: 06.08.19

Notes
Split sj249 into 5 different conditions
Remove empty chans and make this consistent with previous data

%}

clear
close all

eegRawDir = '/home/bullock/Calgary/Data_Revisit_2018/EEG_RAW_2019';

eeg_file = '249_eeg_cbf_hx_air.cnt'; %96 mins
EEG = pop_loadcnt([eegRawDir '/' eeg_file ] ,'dataformat', 'auto', 'memmapfile', ''); % import cnt 

% split into hypoxia and air
EEG_hypoxia = pop_select(EEG,'point',[EEG.event(183).latency, EEG.event(1632).latency]);
EEG_air = pop_select(EEG,'point',[EEG.event(1633).latency, EEG.event(3078).latency]);

% split into hyperventilation(air), hypocapnia and hypercapnia
clear EEG
eeg_file = '249_eeg_cbf_airhv_hypo_.cnt';
EEG = pop_loadcnt([eegRawDir '/' eeg_file ] ,'dataformat', 'auto', 'memmapfile', ''); % import cnt 
EEG_hv = pop_select(EEG,'point',[EEG.event(1).latency, EEG.event(1447).latency]);
EEG_hypocap = pop_select(EEG,'point',[EEG.event(1448).latency, EEG.event(2887).latency]);
EEG_hypercap = pop_select(EEG,'point',[EEG.event(2888).latency, EEG.event(4331).latency]);

clear EEG
EEG = EEG_air;
save('sj249_air.mat','EEG')

clear EEG
EEG = EEG_hv;
save('sj249_hyperair.mat','EEG')

clear EEG
EEG = EEG_hypoxia;
save('sj249_hypoxia.mat','EEG')

clear EEG
EEG = EEG_hypocap;
save('sj249_hypocapnia.mat','EEG')

clear EEG
EEG = EEG_hypercap;
save('sj249_hypercapnia.mat','EEG')



