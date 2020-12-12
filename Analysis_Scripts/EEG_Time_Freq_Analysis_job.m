%{
EEG_Time_Freq_Analysis_job
Author: Tom Bullock, UCSB Attention Lab
Date: 12.10.20

Run stuff
%}

clear 
close all

% which subs?
subjects = [134,237,350,576,577,578,588,592,249,997:999];

% if run on local machine(0), else if run on cluster(1)
processInParallel=1;

% cluster settings
if processInParallel
    cluster=parcluster();
    cluster.ResourceTemplate = '--ntasks-per-node=6 --mem=65536'; % max set to 12! mem not working atm
    job = createJob(cluster);
end

% loop through subs/conds and run time-freq analysis
for iSub=1:length(subjects)
    sjNum = subjects(iSub);
    
    for iCond=1:4
        
        if       iCond==1; thisCond='air';
        elseif   iCond==2; thisCond='hypercapnia';
        elseif   iCond==3; thisCond='hypocapnia';
        elseif   iCond==4; thisCond='hypoxia';
        end
        
        if processInParallel
            createTask(job,@EEG_Time_Freq_Analysis,0,{sjNum,thisCond})
        else
            EEG_Time_Freq_Analysis(sjNum,thisCond)
        end
        
    end
end

% submit jobs
if processInParallel
    submit(job)
end