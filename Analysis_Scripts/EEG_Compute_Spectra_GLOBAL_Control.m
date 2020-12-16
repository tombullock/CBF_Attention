%{
EEG_Compute_Spectra_Control
Author: Tom Bullock, UCSB Attention Lab
Date: 12.13.20

Compute spectra using FFTs

Note - sj350 has a different freq SSVEP, so exclude from SSVEP plots?

%}

clear
close all

% set dirs
sourceDir = '/home/bullock/CBF_Attention/EEG_Ep_Task';
destDir = '/home/bullock/CBF_Attention/Data_Compiled';

% subjects
subjects = [134,237,576,578,588,592,249,997:999]; %350,577


% loop
for iSub=1:length(subjects)
    sjNum=subjects(iSub);
    for iCond=1:2
        
        if       iCond==1; thisCond='hyperair';
        elseif   iCond==2; thisCond='hypocapnia';
        end
        
        for iPhase=1:2
            
            if       iPhase==1; thisPhase='fix';
            elseif   iPhase==2; thisPhase='task';
            end
            
            % load data
            load([sourceDir '/' sprintf('sj%02d_%s_%s45_ft_ep.mat',sjNum,thisCond,thisPhase)])
            
            % get spectra using fft
            eegData.ALLEEG = EEG;
            tstart=29*250; %samples
            tend=43*250; %samples %%%%WHY CUT OFF AT 44??
            L = length(eegData.ALLEEG.data(1,tstart:tend,1)); % Length of signal
            NFFT =(L*3)-3; %L
            
            for i = 1:length(eegData.ALLEEG.epoch)
                for channel = 1:eegData.ALLEEG.nbchan
                    spectra(i,channel,:) = fft(eegData.ALLEEG.data(channel,tstart:tend,i),NFFT)/L;
                end
            end
            
            % get freqs
            freqs = 250/2*linspace(0,1,NFFT/2+1);
            
            % reduce freqs (do 4-20 Hz)
            spectra =spectra(:,:,find(freqs==4):find(freqs==30));
            
            freqs = freqs(find(freqs==4):find(freqs==30));
            
            % average over all epochs
            spectra = (abs(spectra)).^2;
            spectra = squeeze(mean(spectra,1));
            
            % compile averaged spectra into single matrix
            allSpectra(iSub,iCond,iPhase,:,:) = spectra;
            
            clear spectra
            
        end
    end
end

% save all spectra
save([destDir '/' 'EEG_Spectra_Global_Control.mat'],'allSpectra','freqs')