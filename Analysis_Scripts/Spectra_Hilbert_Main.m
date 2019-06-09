%{
Spectra_Hilbert_Main
Author: Tom Bullock, UCSB Attention Lab
Date: 05.28.18

Load long epoched data, do hilbert transform, created data plots and
averaged data mats.

%}

clear 
close all

%% dir
sourceDir = '/home/bullock/CBF_Attention/EEG_Ep_Task';
destDir = '/home/bullock/CBF_Attention/Data_Compiled';

%psList = [134 237  576 577 578 592 588 350];
%psList = [134 576 577 578 592 237 350 588]; % matches bloodflow order 
subjects = 249;

% loop through subs
for iSub=1:length(subjects)
    sjNum=subjects(iSub);

    % loop through gas challenge conditions
    for iCond=1:4
        
        clear hilbertEEG
        
        if iCond==1
            thisCond = 'air';
        elseif iCond==2
            thisCond = 'hypercapnia';
        elseif iCond==3
            thisCond = 'hypocapnia';
        elseif iCond==4
            thisCond = 'hypoxia';
        end
        
        hilbertEEG = [];

        % load 90 s epoch data
        load([sourceDir '/' sprintf('sj%d_',sjNum) thisCond '_fixTask90_ft_ep.mat'])
        
        % apply eegfiltnew (original filter in manuscript)
        tempEEG = pop_eegfiltnew(EEG,8,12);
        tempEEG = EEG.data;
        
%         % apply Butterworth Filter (better alternative to try)
%         filterorder = 3;
%         type = 'bandpass';
%         [z1,p1] = butter(filterorder, [8,12]./(EEG.srate/2),type);
%         data = double(EEG.data);
%         tempEEG = NaN(size(data,1),EEG.pnts,size(data,3));
%         for x = 1:size(data,1) % loop through chans
%             for y = 1:size(data,3) % loop through trials
%                 dataFilt1 = filtfilt(z1,p1,data(x,:,y)); % was filtfilt
%                 tempEEG(x,:,y) = dataFilt1; % tymp = chans x times x trials
%             end
%         end
        
%         eegBand = [];
%         eegBand = tempEEG;
%         
%         
        
        % apply Hilbert to each channel and trial
        hilberEEG = [];
        for j=1:size(tempEEG,1) % chans
            for i=1:size(tempEEG,3) % trials
                hilbertEEG(j,:,i) = hilbert(squeeze(tempEEG(j,:,i)));          
            end
        end
        
        % convert to amp or power
        hilbertEEG = [abs(hilbertEEG)];
        disp('Calculating Amplitude!')
        
        %average over electrodes and epochs
        allHilbert(iSub,iCond,:) = mean(mean(hilbertEEG(10:15,:,:),1),3); % do 10:15 for average of all O and PO elects
        
    end
end

% downsample to 1 Hz
for i=1:88 % 88 points coz lost edges!
    j=i*250;
    downsampledHilbert(:,:,i) = mean(allHilbert(:,:,(j-249):j),3);  
end

save([destDir '/' 'Hilbert_Alpha_Master.mat'],'downsampledHilbert');

% quick plot averaged across conditons

downsampledHilbert = squeeze(mean(downsampledHilbert,1));
plot(downsampledHilbert(1,:),'g');hold on % air
plot(downsampledHilbert(2,:),'r') % hypercap
plot(downsampledHilbert(3,:),'b') % hypocap
plot(downsampledHilbert(4,:),'m') % hypoxia

ylim([0,100])
ylabel('alpha power')
xlabel('secs')

legend('air','hcap','hpo','hpox')




        
        