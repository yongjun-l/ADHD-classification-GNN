%%% Skript Rodrigues: Made by Dr. rer. nat. Johannes Rodrigues, Dipl. Psych. Julius-Maximilians University of Würzburg. johannes.rodrigues@uni-wuerzburg.de; Started 2012, Latest update: 2021_05
%%% IMPORTATANT NOTE: THERE IS NO WARRENTY INCLUDED ! -> GNU 
%%% THERE ARE MANY THINGS THAT NEED TO BE ADJUSTED TO YOUR DATA !
%%% PLEASE ALSO KEEP IN MIND, THAT DIFFERENT MATLAB VERSIONS MIGHT HAVE SOME CRITICAL CHANGES IN THEM THAT MAY ALTER YOUR RESULTS !!! One example is the differences in the round function that changed the Baseline EEGLAB function on "older" MATLAB Version. 
%%% PLEASE DON´T USE THIS SCRIPT WITHOUT CONTROLLING YOUR RESULTS ! CHECK FOR PLAUSIBILITY OF THE SIGNAL AND TOPOGRAPHY


%seperate_script_for_first_segmentation
%This script is a very simple and basic example of a first segmentation that is needed in the pre-processing script.

%in this script an example for a segmentation and a renaming of relevant events is provided.
%The renaming is based on  example markers named "target_marker1" and "target_marker2"
%and three markers that are before this marker named "marker_before_1" etc.

%look for target marker and as you want to look one before, start from 2 not from 1
for i=2:size(EEG.event,2)
	if strcmp(EEG.event(1,i).type,'target_marker1') %if the present marker ist the target marker
		if strcmp(EEG.event(1,i-1).type,'marker_before_1')
			EEG.event(1,i-1).type = 'target_marker1_after_1'
		elseif strcmp(EEG.event(1,i-1).type, 'marker_before_2')
			EEG.event(1,i-1).type = 'target_marker1_after_2'		
		elseif strcmp(EEG.event(1,i-1).type, 'marker_before_3')
			EEG.event(1,i-1).type = 'target_marker1_after_3'
		end
	elseif strcmp(EEG.event(1,i).type,'target_marker2')
		if strcmp(EEG.event(1,i-1).type,'marker_before_1')
			EEG.event(1,i-1).type = 'target_marker2_after_1'
		elseif strcmp(EEG.event(1,i-1).type, 'marker_before_2')
			EEG.event(1,i-1).type = 'target_marker2_after_2'		
		elseif strcmp(EEG.event(1,i-1).type, 'marker_before_3')
			EEG.event(1,i-1).type = 'target_marker2_after_3'
		end
	end
end

 %%%"THE GREAT CHANGE": Adjust the marker names
%now tell the script the relevant marker names. 
Relevant_Markers = {'target_marker1_after_1' 'target_marker1_after_2' 'target_marker1_after_3' 'target_marker2_after_1' 'target_marker2_after_2' 'target_marker2_after_3' };


%see whether there are some double or triple mentioned markers because one might get carried away if there are many conditions...
Relevant_Markers = unique(Relevant_Markers);

 %%%"THE GREAT CHANGE": Adjust the time window mentioned below in seconds. Note, that also negative values are able in order to get baseline periods later.
%make the first raw selection of the segments. This is NOT the final segmentation but only for the pre-processing
EEG = pop_epoch( EEG, Relevant_Markers , [-1 8], 'newname', strcat(filenames{VP},'_intchan_avg_filt epochs'), 'epochinfo', 'yes'); %selection: -1 to 8 seconds

