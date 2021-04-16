%{
EEG_Artifact_Rej_Summary
Author: Tom Bullock
Date: 12.10.20

%}

clear
close all

sourceDir = '/home/bullock/CBF_Attention/EEG_Ep_Task';

subjects = [134,237,350,576,577,578,588,592,249,997:999];

for iSub=1:length(subjects)
    sjNum=subjects(iSub);
    
    for iCond=1:4
        
        if       iCond==1; thisCond='air';
        elseif   iCond==2; thisCond='hypercapnia';
        elseif   iCond==3; thisCond='hypocapnia';
        elseif   iCond==4; thisCond='hypoxia';
        end
    
        %load([sourceDir '/' sprintf('sj%d_%s_erp_std_ft_ep.mat',sjNum,thisCond)])
        load([sourceDir '/' sprintf('sj%d_%s_erp_tar_hit_ft_ep.mat',sjNum,thisCond)])
        
        
        artifactRejSummary(iSub,iCond) = pcRejTrials;
        
    end
end

disp('Art.Rej totals')

meanAR = mean(artifactRejSummary)
stdAR = std(artifactRejSummary,0,1)./sqrt(size(artifactRejSummary,1))