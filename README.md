# CBF_Attention

All new analyses stored in /home/bullock/CBF_Attention (June 2019 onwards)

Scripts for analyzing EEG and behavioral data from CBF_Attention study, as well as looking at relationships between these measures and other physio.


## Notes on individual subjects' data (EEG + Beh)

Original data collection

134 - all conditions

237 - all conditions

321 - hypoxia missing

576 - all conditions

578 - no behavioral responses logged in any conditons

581 - no events in hypocapnia

588 - all conditions

592 - all conditions

350 - no hyperair

577 - no hyperair

Restart data collection (06.06.19)

249 - all conditions

997 - all conditions

998 - all conditions

999 - all conditions


## Notes on which subjects to include in specific analyses

For standard/target analyses exclude 321 and 581 (missing events)
For ERPs (stds) 134, 237, 576, 577, 578, 588, 592 (EXC: 321 350 581)
For EERPs (targs) same (INC 350, EXC 321 581)


## Scripts

`EEG_Import_Split_CNT.m` Import .cnt files, split into differnt conditions (edit this)

`EEG_Preprocess1.m` Re-ref,filt, artifact correct (AAR) -channel rej???

`EEG_Preprocess2.m` Epoch, artifact reject (threshold, for task only) << CHECK THIS, NOT CURRENTLY IMPLEMENTED!

## NOTES ON PROGRESS

Redone behavior plots with new subjects (Figure 2)

Look on local machine Calgary_Data/Paper/Stats/Stats_for_paper_june 2018 for useful scripts etc (and elsewhere in that dir)
