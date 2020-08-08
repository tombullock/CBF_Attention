%{
BBT_Downsample
Author: Tom Bullock
Date: 08.07.20

Downsample the original 2Hz signal to 1Hz for all gas conditions.  Also create some other mats.  

Should only need to run this once.  This was originally done on my local
machine in the folder: 

/Users/tombullock/Documents/Psychology/Calgary_Data/Paper/Stats/STATS_FOR_PAPER_FEB_21_2017/2_GlobalCBFandBrainResponses

%}

% downsample to 1Hz continuous

MCA_BBT_AIR_NEW = MCA_BBT_AIR(1:2:180,:);
PCA_BBT_AIR_NEW = PCA_BBT_AIR(1:2:180,:);

MCA_BBT_HYPERAIR_NEW = MCA_BBT_HYPERAIR(1:2:180,:);
PCA_BBT_HYPERAIR_NEW = PCA_BBT_HYPERAIR(1:2:180,:);

MCA_BBT_HYPERCAP_NEW = MCA_BBT_HYPERCAP(1:2:180,:);
PCA_BBT_HYPERCAP_NEW = PCA_BBT_HYPERCAP(1:2:180,:);

MCA_BBT_HYPOCAP_NEW = MCA_BBT_HYPOCAP(1:2:180,:);
PCA_BBT_HYPOCAP_NEW = PCA_BBT_HYPOCAP(1:2:180,:);

MCA_BBT_HYPOXIA_NEW = MCA_BBT_HYPOXIA(1:2:180,:);
PCA_BBT_HYPOXIA_NEW = PCA_BBT_HYPOXIA(1:2:180,:);

save('BBT_Master.mat')