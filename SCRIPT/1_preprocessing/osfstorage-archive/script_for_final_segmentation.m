%%% Skript Rodrigues: Made by Dr. rer. nat. Johannes Rodrigues, Dipl. Psych. Julius-Maximilians University of Würzburg. johannes.rodrigues@uni-wuerzburg.de; Started 2012, Latest update: 2021_05
%%% IMPORTATANT NOTE: THERE IS NO WARRENTY INCLUDED ! -> GNU 
%%% THERE ARE MANY THINGS THAT NEED TO BE ADJUSTED TO YOUR DATA !
%%% PLEASE ALSO KEEP IN MIND, THAT DIFFERENT MATLAB VERSIONS MIGHT HAVE SOME CRITICAL CHANGES IN THEM THAT MAY ALTER YOUR RESULTS !!! One example is the differences in the round function that changed the Baseline EEGLAB function on "older" MATLAB Version. 
%%% PLEASE DON´T USE THIS SCRIPT WITHOUT CONTROLLING YOUR RESULTS ! CHECK FOR PLAUSIBILITY OF THE SIGNAL AND TOPOGRAPHY

%script_for_final_segmentation
%This script is a simple example for setting the "CASEARRAY" that is used for the final segmentation in the processing script.
%Note that the CASEARRAY contains all relevant conditions. These are not necessarily the same as were used for the first segmentation.
%In this very basic example, we are only interested in Target markers, that are after event 1 or after event 2

 %%%"THE GREAT CHANGE": Adjust the marker names
%now tell the script the relevant marker names. 
Relevant_Markers = {'target_marker1_after_1' 'target_marker1_after_2' 'target_marker2_after_1' 'target_marker2_after_2'};


%see whether there are some double or triple mentioned markers because one might get carried away if there are many conditions...
Relevant_Markers = unique(Relevant_Markers);

%Create the Casearray:
CASEARRAY = Relevant_Markers;