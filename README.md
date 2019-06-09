# CBF_Attention

All new analyses stored in /home/bullock/CBF_Attention (June 2019 onwards)

Scripts for analyzing EEG and behavioral data from CBF_Attention study, as well as looking at relationships between these measures and other physio.

## Notes on individual subjects' data (EEG + Beh)

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

249 - NEW PILOT 060619

## Notes on which subjects to include in specific analyses

For standard/target analyses exclude 321 and 581 (missing events)
For ERPs (stds) 134, 237, 576, 577, 578, 588, 592 (EXC: 321 350 581)
For EERPs (targs) same (INC 350, EXC 321 581)

## Scripts

`EEG_Import_Split_CNT.m` Import .cnt files, split into differnt conditions (edit this)

`EEG_Preprocess1.m` Re-ref,filt, artifact correct (AAR)

`EEG_Preprocess2.m` Epoch, artifact reject (threshold, for task only)