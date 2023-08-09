%%% Processing Skript Rodrigues: Made by Dr. rer. nat. Johannes Rodrigues, Dipl. Psych. Julius-Maximilians University of Würzburg. johannes.rodrigues@uni-wuerzburg.de; Started 2012, Latest update: 2021_05
%%% Important Inputs were given by: Prof. John J. B. Allen, PhD, Prof. Johannes Hewig
%%% Lots ot parts or programming logic were taken from scripts by Prof. John J. B. Allen (I am not able to clearly disentangle where his ideas and input ended and where my part beginns...) Thanks a lot !!! 
%%% Important steady input over the years was also given by the Wintersymposium Montafon.
%%% Other important input was given by Janir Nuno Ramos da Cruz and Makoto Miyakoshi as well as Nathan Fox in the final stages of the script
%%% IMPORTATANT NOTE: THERE IS NO WARRENTY INCLUDED ! -> GNU 
%%% PLEASE SCROLL DOWN AND ADJUST THE PATHS AND THE DATA IMPORT FUNCTION ACCCORDING TO YOUR EEG FILE FORMAT!!!
%%% PLEASE ALSO SCROLL DOWN AND ADJUST SOME LINES ACCORDING TO YOUR EEG MONTAGE !!!
%%% THERE ARE MANY THINGS THAT NEED TO BE ADJUSTED TO YOUR DATA !
%%% FIND ALL LINES THAT NEED TO BE ADJUSTED BY THE SEARCH TERM: "THE GREAT CHANGE"
%%% PLEASE ALSO KEEP IN MIND, THAT DIFFERENT MATLAB VERSIONS MIGHT HAVE SOME CRITICAL CHANGES IN THEM THAT MAY ALTER YOUR RESULTS !!! One example is the differences in the round function that changed the Baseline EEGLAB function on "older" MATLAB Version. 
%%% Therefore some steps that are implemented in EEGlab are done "by hand" in this script.
%%% PLEASE DON´T USE THIS SCRIPT WITHOUT CONTROLLING YOUR RESULTS ! CHECK FOR PLAUSIBILITY OF THE SIGNAL AND TOPOGRAPHY
%%% IF SOMETHING WENT WRONG, CHECK ALSO THE PREPROCESSING AND SEGMENTATION ! VERY ! CAREFULLY !


%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Processing chain Rodrigues: Adaptation and automatization using Matlab 2011b / 2015b
%%% EEGlab (Delorme & Makeig, 2004) and code provided by Cohen, 2014
%%%%
%%%%%%  PLEASE REMEMBER: GARBAGE IN -> GARBAGE OUT ! MAKE A GOOD AND CLEAN EEG DATA RECORDING ! TAKE YOUR TIME TO GET THE ELECTRODES RIGHT ! PLACE THE ELECTRODE CAP RESPONSIBLY AND WITH GREAT CARE !
%%%%%	TAKE
%%%%% 	YOUR
%%%%%	TIME 
%%%%%	!!!!
%%
%% Processing steps:
%%
%% 9. Segment the data for analysis and create a 4 Dimensional matrix for signal and each frequency separately and a 5 Dimensional matrix for the respective single trials (of course one can also create a 5 D matrix or 6 D matrix...) 
%%		This approach has the problem of sometimes running into memory problems as the matrices are rather large. 
%%		If this happens, then please either only compute one matrix at a time or start resampling the data in the preprocessing (not only in the processing script). If you do so, then remember that the resampling should be done without unnecessary extrapolation (meaning that you should resample in a divisor of the current sampling rate)
%%		In order to go into single trial analysis of frequencies later, an adjustment was made to the frequency extraction functions provided by Cohen (2014). Otherwise, the functions are used as shown in Cohen (2014)
%%   
%%
%%      9a. Segment the data according to relevant markers
%%		    The markers need to be selected and a segmentation-file should be provided. For this chain, an example segmentation-script will be provided (in another script).
%%          Put the segmentation-script in the EEGlab directory. In the segmentation-script, the Cellarray "CASEARRAY" contains all the conditions of the experiment.
%%          Keep in mind, that the data matrix that is used for automatic peak detection and visualization assumes that all conditions are equally often present. If this is not the case, use the weighted averages examples.     
%%          Step 5. revisited: In some processing chains (mostly ERP related) there is a second bad segment detection step at this point (see Step 5 pre-processing script). If you want to perform this step with different parameters, be sure to mention them or just perform it with the same parameters than before.
%%		
%%      9b. Define the Baseline automatically without using EEGlab function 
%%		    This is done to avoid problems with the round function in differnt Matlab version that may or may not work correctly with the respective EEGlab versions and therefore may lead to a correct EEGlab baselinefunction or not.
%%          The recommendation is to chose an appropriate baseline dependent on the event one is regarding: On pure feedback a baseline from - 500 or -200 to 0 might be a good idea, while a motor reaction normally does not have a respective baseline to 0 but to ~ -200 ms due to premotor activations. Mind also, that frequency analysis might lead to some jittering in time.
%%
%%      9c. Choose the frequencies of interest
%%		    In this chain, I think you know what frequencies and ERP signals you are interested in and only want to look at them, because we first want to gather evidence concerning our hypotheses. (Of course you can look on other frequency bands for exploratory purposes)
%%          
%%	    9d. Choose a filter (if wanted for ERPs). Depending on the ERP you are interested in, you are of course familiar with the filters (if any) you need. 
%%
%%	    9e. Choose whether you want to look on and analyze single trials. I recommend using multilevel modelling if single trial analysis is wanted. Also I recommend using frequencies instead of raw (erp-related) data, because of the higher reliablity (see Rodrigues et al. 2020)
%%
%%
%% 10. (optional): Loose cases that are not present but in your segmentation file. This is relevant for free choice paradigms.
%%
%%
%% 11. Automatically detect the peak in a given time window in EEG signal (here example FRN)
%%		The peak is searched in a time window of interest on an electrode of interest for the mean signal. The respective parameters depend on the ERP. Please consult the literature but also criticize the literature (e.g. still looking for FRN on Fz might seem not appropriate in many cases if FCz is available due to more than 32 electrodes)
%%		Depending on your task, it might be worth to look at the total mean of all cases, or just to look for the peak in several cases that are different from others. Examples are provided, but have to be adjusted to your tasks.
%%
%%
%% 12. Create ERPs
%%      In this step, ERPs (figures) are created. 
%%
%%      12a: "Normal" ERP: This ERP is just a line as in the(ancient) manuscripts... follow the tradition (?)
%%
%%      12b: In addition to the "normal" ERP, also ERPs with shaded errorlines are created in order to give an impression of the distribution. In this step, only between errorlines are drawn to the figure.
%%
%%      12c: In addition to the "normal" ERP, also ERPs with shaded errorlines are created in order to give an impression of the distribution. In this step, mean within errorlines are drawn to the figure (mean within SE).
%%          Note that you need to display meaningful conditions and maybe also compute meaningful bundles of conditions (not shown in this example, but simply use nanmean)
%%
%% 13. Create topographical maps (Topoplots)
%%      
%%      13a: In this step, a topographical map of the time window of interest (peak-window) is made. 
%%           
%%      13b: Also, a GIF is created that shows different timesteps in order to see the dynamic changes in activation in the topography and verify the time-window of interest for the electrodes.
%%
%%
%% 14. Automatically detect peak in a given time window in frequency responses (here example midfrontal theta)
%%		The peak is searched in the time window of interest on an electrode of interest the frequency response. The respective parameters are the same as specified for the ERP of interest. Please consult the literature but also criticize the literature (e.g. still looking for peak midfrontal theta on Fz might seem not appropriate in many cases if FCz is available due to more than 32 electrodes)
%%		Depending on your task, it might be worth to look at the total mean of all cases, or just to look for the peak in several cases that are different from others. Examples are provided, but have to be adjusted to your tasks.
%%
%%
%% 15. Create topographical maps for frequency response(Topoplots)
%%      
%%      15a: In this step, a topographical map of the time window of interest (peak-window of frequency response) is made. 
%%           
%%      15b: Also, a GIF is created that shows different timesteps in order to see the dynamic changes in activation in the topography and verify the time-window of interest for the electrodes.
%%
%%
%% 16. Create a time-frequency plot for a specific electrode in a broad frequency window
%%      For this time frequency plot, once again a function that is based on the code of Mike X Cohen (2014) is used. It was edited by John J.B. Allen and me. This provides a log transformed power output
%%      This function gets you a time frequncy plot that displays the frequency reaction not only limited to your functional frequency, but it is meant to be used as a display of larger frequency windows. (Suggestion: 1-30 Hz, as I am filled with scepticism concerning gamma, since microsaccades have been discovered)
%%      Note that a dB to baseline output is recommended here in order to correct for the power law and therefore provide an adequate visualization of the frequencies in their spectrum related to the chosen baseline. The baseline must be part of the chosen display window.
%%      Note also, that this transformation is not done to the data per se, but only to your visualization. But if you are only interested in the frequency responses of your respective bands and do not compare power values of different frequency bands, the baseline standardization is not necessary.  
%%
%%
%% 17. Export the data to statistical software: As xlsx or matlab file. 
%%
%%		17a: Long format export for the mean signal/frequencies. This is for example used by many R packages to calculate anovas... Note that additional information is exported in other files (.txt and .mat)(like the channel names)
%%		
%%      17b: Wide format export for the mean signal/frequencies. This is for example used Jamovi or PSPP/SPSS to calculate anovas...Note that additional information is exported in other files (.txt and .mat)(like the channel names)
%%		
%%      17c: Long format export for single trial signal/frequencies. This is for example used by many R packages and SPSS to calculate multilevel mixed models. Note that additional information is exported in other files (.txt and .mat)(like the channel names)
%%
%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% END OF PROCESSING RODRIGUES "THEORY"


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PROCESSING CHAIN RODRIGUES: STEP 0: PREPARATION 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%"THE GREAT CHANGE":If you are not in the EEGlab directory and have not initialized it, then please do so by typing "eeglab" in matlab

%"THE GREAT CHANGE": These two Matlab Addons need to be used in order to have nice pictures of the effects and an easy way to print them. Modify to your own path:
addpath(genpath('C:\Matlab_Addon\boundedline-pkg-master\'))
addpath(genpath('C:\Matlab_Addon\export_fig-master\'))

%read in Data (still to modify)
%"THE GREAT CHANGE"
read_dir = 'C:\DataFolder\removed_automatically\ICA\automatically_rejected\CSD\';   %There is your EEG preprocessed data with the respective reference you are interested in. 

%specify where to save the .txt files of the necessary information:
printpath = 'C:\Matlab_Addon\eeglab14_1_1b\';



%"THE GREAT CHANGE":Please load one eegfile or specify the sampling rate.
load('montage_for_topoplot.mat') % montage file that should be safed during STEP 8 in preprocessing to ica file
%EEG.srate = 250;

%"THE GREAT CHANGE":Please load the previous information from preprocessing
load('Evaluation.mat') % evaluation file that should be safed at the End of preprocessing file




%"THE GREAT CHANGE": Insert here your desired Baseline parameters. Please consider that the start of the segment is the start of the final segmentation and not the preprocessing segmentation
%Manual Baseline: Dependent on the sampling rate and the segmentation
baselinestart = ((1000-500)/(1000/EEG.srate))+1; %from -500, as the segments start here from -1000, sampling rate set above
baselinestop =	((1000-0)/(1000/EEG.srate))+1; % to 0, as the segments start here from -1000, sampling rate set above

%"THE GREAT CHANGE": Change the values of the final segmentation (given in seconds). Here it is -1s to 2 seconds
Segementation_time_start = -1;
Segementation_time_end = 2;

%"THE GREAT CHANGE" : Adjust the number of maximal trials in a condition.
%SINGLETRIAL: Max trials in a conditions:
MAXTRIALS = 24; % This variable stores the maximum of trial that can be seen in any condition. The variable is needed in case one wants to go for single trial analysis as the matrix should be precomputed in order to save memory.

%"THE GREAT CHANGE": Change the channel number of your electrodes of interest.
%Elektrode of interest: Please select the electrode you are interested in (for ERPs). The examples here are provided for the electrodes Fz FCz and Cz. Of course you can add more electrodes of interest...
electrode_of_interest1 = 31; %here example FCz in my montage
%electrode_of_interest2 = 17; %here example Fz in my montage
%electrode_of_interest3 = 32; %here example Cz in my montage


%"THE GREAT CHANGE": Adjust the target search window of your ERP dependent on the relevant literature. The search window depends on your segmentation time_start. 
searchwindowlength_in_ms = 200; % 100ms (see Yeung & Sanfey, 2004, FRN)
searchwindowstart_from_zero_in_ms = 200; % 200ms (see Yeung & Sanfey, 2004, FRN)
%searchwindow
searchwindowlength = searchwindowlength_in_ms/(1000/EEG.srate); % 100ms dependent on the sampling rate
searchwindowstart = searchwindowstart_from_zero_in_ms/(1000/EEG.srate)-(Segementation_time_start*EEG.srate); % 200ms dependent on the starting point of segement and sampling rate


%"THE GREAT CHANGE": Adjust the target time window of your ERP dependent on the relevant literature. The time window will be centered around the automatically detected peak. Keep in mind to check if you got different tasks that are compared whether the individual task is still in the window. Else adjust window length and also peak location.
%windowlength
windowlength_in_ms = 40; %40 ms (see e.g. Rodrigues et al. 2020): 
%windowlength in points:
windowlength = windowlength_in_ms/(1000/EEG.srate); % Your extraction time window for the FRN / ERP you are interested in. This is a peak centered time window. It is dependening on the sampling rate

%"THE GREAT CHANGE": Adjust the time to be displayed in the ERPs (STEP 12) and in the broad time frequency plot (STEP 16)
%Display parameters for ERP: Set paramter
display_time_start_from_zero_in_ms = -200; %Note that one can also go into - : this means it is left from 0, being a display of the baseline. Note also that you cannot display data that is not in your segmentation.
display_time_end_from_zero_in_ms = 800; %Note also that you cannot display data that is not in your segmentation.
%display parameter for ERP:
display_time_start = display_time_start_from_zero_in_ms/(1000/EEG.srate)-(Segementation_time_start*EEG.srate); % dependent on the starting point of segement and sampling rate
display_time_end = display_time_end_from_zero_in_ms/(1000/EEG.srate)-(Segementation_time_start*EEG.srate); % dependent on the starting point of segement and sampling rate

%"THE GREAT CHANGE": Adjust the timesteps for the topographical map GIF
%Choose timesteps for topographical maps gif
timesteps_in_ms = 40;
timesteps = timesteps_in_ms/(1000/EEG.srate);

%"THE GREAT CHANGE": Adjust the time to be displayed in the topographical map GIF
%Display parameters for topoplot GIF: Set paramter (note that this is for ERP as well as frequency responses: STEP 13 and STEP 15)
display_time_start_from_zero_in_ms_GIF_topo = 0; %Note that one can also go into - : this means it is left from 0, being a display of the baseline. Note also that you cannot display data that is not in your segmentation.
display_time_end_from_zero_in_ms_GIF_topo = 600; %Note also that you cannot display data that is not in your segmentation.
%display parameter for ERP: 
display_time_start_GIF_topo = display_time_start_from_zero_in_ms_GIF_topo/(1000/EEG.srate)-(Segementation_time_start*EEG.srate); % dependent on the starting point of segement and sampling rate
display_time_end_GIF_topo = display_time_end_from_zero_in_ms_GIF_topo/(1000/EEG.srate)-(Segementation_time_start*EEG.srate); % dependent on the starting point of segement and sampling rate

%"THE GREAT CHANGE": Adjust the frequencies displayed in the broad time frequency plot. (in Hz)
%Set the frequencies for the broad frequency plot (STEP 16)
min_freq = 1;
max_freq = 30;


%select the files that are in the relevant directory:
files = dir([read_dir '*.set']);
filenames = {files.name}';
%How many participants / files are there ?
COUNTPARTICIPANT = size(filenames,1);

%"THE GREAT CHANGE" : Here you need to insert your script for the final segmentation. For inexperienced users, I recommend using EEGlab with the "eegh" commmand:
%(Edit -> extract epoches -> select your relevant markers in "time locking event types", think about baseline and buffer times in "epoche limits" in s)
%CAREFUL: SOME MATLAB VERSIONS ARE NOT COMPATIBLE WITH THE EEGLAB BASELINE CORRECTION (pop_rmbase(...)) ! IN THIS CASE, INSERT THE BASELINE CORRECTION MANUALLY AS DONE HERE !	
%Please also keep in mind that it may be the case that some conditions are not met by all participants.
%Therefore I created a "demo" script of a final segmentation: Named script_for_final_segmentation
%in this script, the Variable "CASEARRAY" defines the final segmentation markers
%load the final segmentation file in order to get the number of relevant cases that one is interested in:
script_for_final_segmentation % this file needs to be put into the EEGlab Folder


%"THE GREAT CHANGE": Adjust the matrices that you need. Select only the matrices that you need because of working memory (see above)
%Creating all needed arrays: Here only mean_signal array and mean_theta array, but other arrays are possible (e.g. signle trial array shown for signal here)
Total_mean_signal_array(:,:,:,:) = nan(COUNTPARTICIPANT,size(CASEARRAY,2),EEG.nbchan,EEG.pnts, 'single');		    %4D array: VP,CASES,ELECTRODES,TIMES
Total_mean_theta_array(:,:,:,:) =  nan(COUNTPARTICIPANT,size(CASEARRAY,2),EEG.nbchan,EEG.pnts, 'single');			%4D array: VP,CASES,ELECTRODES,TIMES
%Total_mean_alpha_array(:,:,:,:) =  nan(COUNTPARTICIPANT,size(CASEARRAY,2),EEG.nbchan,EEG.pnts, 'single');			%4D array: VP,CASES,ELECTRODES,TIMES
%Total_mean_beta_array(:,:,:,:) =   nan(COUNTPARTICIPANT,size(CASEARRAY,2),EEG.nbchan,EEG.pnts, 'single');			%4D array: VP,CASES,ELECTRODES,TIMES
%Total_mean_delta_array(:,:,:,:) =  nan(COUNTPARTICIPANT,size(CASEARRAY,2),EEG.nbchan,EEG.pnts, 'single');			%4D array: VP,CASES,ELECTRODES,TIMES
%Total_mean_gamma_array(:,:,:,:) =  zeros(COUNTPARTICIPANT,size(CASEARRAY,2),EEG.nbchan,EEG.pnts, 'single');		%4D array: VP,CASES,ELECTRODES,TIMES
%Total_signal_array(:,:,:,:,:) = zeros(COUNTPARTICIPANT,size(CASEARRAY,2),EEG.nbchan,EEG.pnts,MAXTRIALS, 'single');						%5D array: VP,CASES,ELECTRODES,TIMES,TRIALS

%Create an array only to visually quickly check whether a case / condition is given in a participant and if so how many times.
Casecheck (:,:) = zeros(COUNTPARTICIPANT,size(CASEARRAY,2), 'single');




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PROCESSING CHAIN RODRIGUES: STEP 9: Segmentation of the data for analysis and create a 4 Dimensional matrix for signal and each frequency separately and a 5 Dimensional matrix for the respective single trials 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for VP = 1:COUNTPARTICIPANT
	EEG = pop_loadset('filename',filenames{VP},'filepath',read_dir);									%load set (first time)	-> Reason for this here: in case of error, the file is not loaded every case but only if something is done correctly
	
	for CASES = 1:size(CASEARRAY,2) 
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% STEP 9a. Segment the data according to relevant markers
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%Making the Event segementation
		script_for_final_segmentation % script_for making Casearray -> put in eeglab directory

		try % see whether the relevant segements are there... else do the next iteration
            EEG = pop_epoch( EEG, {CASEARRAY{CASES}}, [Segementation_time_start Segementation_time_end ], 'newname', strcat(filenames{VP},CASEARRAY{CASES}), 'epochinfo', 'yes'); %selection here: -1 to 2 seconds 
            [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off'); 
            EEG = eeg_checkset( EEG );

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% % END OF STEP 9a.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%STEP 5 REVISITED
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % %%Reject from components when z > 20 (total), z>z-value (Channel) 
        %  %%"THE GREAT CHANGE" Change the number of channels to your ICA (here starting with 1:65, but the function should do it if you also added a reference channel); the z value 20 is chosen to not correct anything here on single component limitation, but only on all component limitations (global). 
        %  %%"THE GREAT CHANGE" Change the criterion on the single component. If your data is kind of messy (for example clinical data of epilepsy patients) I would recommend using the z-value criterion instead of the 20. 
        % EEG = pop_jointprob(EEG,0,[1:size(EEG.icaact,1)] ,20,Channelz_value_automatic_detection,0,0,0,[],0);
        % EEG = eeg_rejsuperpose( EEG, 0, 1, 1, 1, 1, 1, 1, 1);
        % %"THE GREAT CHANGE" Change the number of channels to your ICA(here starting with 1:65, but the function should do it if you also added a reference channel); the z value 20 is chosen to not correct anything here on single component limitation, but only on all component limitations (global)
        % EEG = pop_rejkurt(EEG,0,[1:size(EEG.icaact,1)] ,20,Channelz_value_automatic_detection,2,0,1,[],0);
        % EEG = eeg_rejsuperpose( EEG, 0, 1, 1, 1, 1, 1, 1, 1);
        % %reject the selected bad segments !
        % reject3 = EEG.reject; %save this for metrics
        % Reject3_VP(VP,CASES)=sum(reject3.rejglobal);
        % EEG = pop_rejepoch( EEG, EEG.reject.rejglobal ,0);
        % EEG = eeg_checkset( EEG );
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%END OF STEP 5 REVISITED
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% STEP 9b. Define the Baseline automatically
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Here the baseline is taken from the definded baseline start to the end of the baseline (parameters definded above)
            %Note that there is no separate baseline taken for the single trials vs. the mean trial, but the same baseline is taken for all approaches.
            %automatical Baseline total file:
            for i = 1:size(EEG.data,1)
                for j = 1:size(EEG.data,3)
                        EEG.data (i,:,j) = EEG.data (i,:,j) - nanmean(EEG.data(i,baselinestart:baselinestop,j),2);
                end
            end
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% % END OF STEP 9b.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% STEP 9c. Choose your frequency bands
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%"THE GREAT CHANGE": Change the desired frequencies and choose what frequency you are interested in. Also adjust the relevant cycles for the wavelets. (For beginners I recommend reading Cohen, 2014)
            %%%Note: The files "wavelet_power" and "wavelet_power2" need to be in the eeglab directory. They are from Cohen, 2014, commented bei John J.B. Allen or a slightly modified version (power2). Also note their output commented below.
            %%%Another possibility for frequency extraction is of course the FFT-function. Problem of FFT: Accurate in frequency, not in time -> whole time window; If parameters set right, wavelet = FFT
            %Frequency extraction:
            %Alpha = wavelet_power_2(EEG,'lowfreq', 8, 'highfreq', 13, 'log_spacing', 1, 'fixed_cycles', 3.5); % 3 dim array = Channel x Time x Trials
            Theta = wavelet_power_2(EEG,'lowfreq', 4, 'highfreq', 8, 'log_spacing', 1, 'fixed_cycles', 3.5); % 3 dim array = Channel x Time x Trials
            %Beta = wavelet_power2(EEG,'lowfreq', 13, 'highfreq', 30, 'log_spacing', 1, 'fixed_cycles', 3.5); % 3  dim array = Channel x Time x Trials 
            %Delta = wavelet_power2(EEG,'lowfreq', 1, 'highfreq', 4, 'log_spacing', 1, 'fixed_cycles', 3.5); % 3  dim array = Channel x Time x Trials
            %Gamma = wavelet_power2(EEG,'lowfreq', 30, 'highfreq', 40, 'log_spacing', 1, 'fixed_cycles', 3.5); % 3 dim array = Channel x Time x Trials

            %Alpha2 = wavelet_power(EEG,'lowfreq', 8, 'highfreq', 13, 'log_spacing', 1, 'fixed_cycles', 3.5); % 2 dim array = Channel x Trials
            %Theta2 = wavelet_power(EEG,'lowfreq', 4, 'highfreq', 8, 'log_spacing', 1, 'fixed_cycles', 3.5); % 2 dim array = Channel x Trials
            %Beta2 = wavelet_power(EEG,'lowfreq', 13, 'highfreq', 30, 'log_spacing', 1, 'fixed_cycles', 3.5); % 2 dim array = Channel x Trials
            %Delta2 = wavelet_power(EEG,'lowfreq', 1, 'highfreq', 4, 'log_spacing', 1, 'fixed_cycles', 3.5); % 2 dim array = Channel x Trials
            %Gamma2 = wavelet_power(EEG,'lowfreq', 30, 'highfreq', 40, 'log_spacing', 1, 'fixed_cycles', 3.5); % 2 dim array = Channel x Trials
        

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% STEP 9d. Choose your filters
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            %Filter according to your need...
            %EEG = pop_eegfiltnew(EEG, 1, 20, [], 0, [], 0); %%comment: Use filters if you need them, if you don´t -> don´t ! 

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% % END OF STEP 9d. (strangely befor 1c ends)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            %%%"THE GREAT CHANGE": Choose your desired mean signals and frequencies
            Total_mean_signal_array(VP,CASES,size(1:EEG.data,1),1:size(EEG.data,2))   = single(nanmean(EEG.data,3));	    %4D array: VP,CASES,ELECTRODES,TIMES
            Total_mean_theta_array(VP,CASES,size(1:EEG.data,1),1:size(EEG.data,2))    = single(nanmean(Theta,3));			%4D array: VP,CASES,ELECTRODES,TIMES
            %Total_mean_alpha_array(VP,CASES,size(1:EEG.data,1),1:size(EEG.data,2))   = single(nanmean(Alpha,3));		    %4D array: VP,CASES,ELECTRODES,TIMES
            %Total_mean_beta_array(VP,CASES,size(1:EEG.data,1),1:size(EEG.data,2))    = single(nanmean(Beta,3));			%4D array: VP,CASES,ELECTRODES,TIMES
            %Total_mean_delta_array(VP,CASES,size(1:EEG.data,1),1:size(EEG.data,2))   = single(nanmean(Delta,3));		    %4D array: VP,CASES,ELECTRODES,TIMES
            %Total_mean_gamma_array(VP,CASES,size(1:EEG.data,1),1:size(EEG.data,2))   = single(nanmean(Gamma,3));		    %4D array: VP,CASES,ELECTRODES,TIMES
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% % END OF STEP 9c. (strangely after 1d ended)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% STEP 9e Choose whether you want to look at single trials
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            %%%"THE GREAT CHANGE": Choose in case of single trial the appropriate frequencies:
            %IN CASE OF SINGLE TRIALS:     
            %check if only one trial:
            %if size(EEG.data,3) == 1
            %	Total_signal_array(VP,CASES,1:size(EEG.data,1),1:size(EEG.data,2),1)  = single(EEG.data);             %5D array: VP,CASES,ELECTRODES,TIMES,TRIALS
            %	Total_alpha_array(VP,CASES,1:size(EEG.data,1),1:size(EEG.data,2),1)   = single(Alpha);               %5D array: VP,CASES,ELECTRODES,TIMES,TRIALS
            %	Total_theta_array(VP,CASES,1:size(EEG.data,1),1:size(EEG.data,2),1)   = single(Theta);               %5D array: VP,CASES,ELECTRODES,TIMES,TRIALS
            %	Total_beta_array(VP,CASES,1:size(EEG.data,1),1:size(EEG.data,2),1)    = single(Beta);                %5D array: VP,CASES,ELECTRODES,TIMES,TRIALS
            %	Total_delta_array(VP,CASES,1:size(EEG.data,1),1:size(EEG.data,2),1)   = single(Delta);               %5D array: VP,CASES,ELECTRODES,TIMES,TRIALS
            %	Total_gamma_array(VP,CASES,1:size(EEG.data,1),1:size(EEG.data,2),1)   = single(Gamma);               %5D array: VP,CASES,ELECTRODES,TIMES,TRIALS
            %
            %else
            %	Total_signal_array(VP,CASES,1:size(EEG.data,1),1:size(EEG.data,2),1:size(EEG.data,3))  = single(EEG.data);	            %5D array: VP,CASES,ELECTRODES,TIMES,TRIALS
            %	Total_alpha_array(VP,CASES,1:size(EEG.data,1),1:size(EEG.data,2),1:size(EEG.data,3))   = single(Alpha);               %5D array: VP,CASES,ELECTRODES,TIMES,TRIALS
            %	Total_theta_array(VP,CASES,1:size(EEG.data,1),1:size(EEG.data,2),1:size(EEG.data,3))   = single(Theta);               %5D array: VP,CASES,ELECTRODES,TIMES,TRIALS
            %	Total_beta_array(VP,CASES,1:size(EEG.data,1),1:size(EEG.data,2),1:size(EEG.data,3))    = single(Beta);                %5D array: VP,CASES,ELECTRODES,TIMES,TRIALS
            %	Total_delta_array(VP,CASES,1:size(EEG.data,1),1:size(EEG.data,2),1:size(EEG.data,3))   = single(Delta);               %5D array: VP,CASES,ELECTRODES,TIMES,TRIALS
            %	Total_gamma_array(VP,CASES,1:size(EEG.data,1),1:size(EEG.data,2),1:size(EEG.data,3))   = single(Gamma);               %5D array: VP,CASES,ELECTRODES,TIMES,TRIALS
            %end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% % END OF STEP 9e
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            %Count the trials in the conditions and create a casecheck array
            try 
                if size(EEG.data) == [EEG.nbchan,EEG.pnts]
                    Casecheck (VP,CASES) =  single(1);                                  %2D array: VP,CASES
                end
            end
            try
                if size(EEG.data,3)>1
                    Casecheck (VP,CASES) = single(size(EEG.data,3));                    %2D array: VP,CASES
                end				
            end		
        
            %clear all temporary variables that could be used in this condition
            clear Alpha Alpha2 Theta Theta2 Beta Beta2 Gamma Gamma Delta Delta2
		
            STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];	    %clear the EEG sets
            EEG = pop_loadset('filename',filenames{VP},'filepath',read_dir);       %reload data here if something was cut from it
		end %try end: If this condition can not be found, then simply start from here -> next condition
	end
	STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];		    %clear the EEG sets
end

%As this takes some time: Save the results in the end. 
save('Backup_workspace', '-v7.3')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%END OF STEP 9
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PROCESSING CHAIN RODRIGUES: STEP 10: Loose unnecessary cases: THIS IS OPTIONAL ! "THE GREAT CHANGE": comment this step out if not needed 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%"THE GREAT CHANGE": Choose your desired matrices
%control the size of your matices
size(Total_mean_signal_array)
%size(Total_mean_alpha_array)
size(Total_mean_theta_array)
%size(Total_mean_beta_array)
%size(Total_mean_delta_array)
%size(Total_mean_gamma_array)
%
%size(Total_signal_array)
%size(Total_alpha_array)
%size(Total_theta_array)
%size(Total_beta_array)
%size(Total_delta_array)
%size(Total_gamma_array)

%now we got massive 4d arrays: Loose now the unnecessary cases that are not present in none of the participants.
%find the stuff to delete:
delete_array = [];
j =1;
for i = 1:size(Casecheck,2)
	if mean(Casecheck(:,i)) == 0
		delete_array(j) = i;
		j=j+1;
	end
end

NEWCASEARRAY = CASEARRAY(:,:,:,:) ;

%delete stuff...
NEWCASEARRAY(:,delete_array,:,:) = [];

%%%"THE GREAT CHANGE": Choose your desired matrices
%delete unnecessary cases:
Total_mean_signal_array(:,delete_array,:,:) = [];
%Total_mean_alpha_array(:,delete_array,:,:) = [];
Total_mean_theta_array(:,delete_array,:,:) = [];
%Total_mean_beta_array(:,delete_array,:,:) = [];
%Total_mean_delta_array(:,delete_array,:,:) = [];
%Total_mean_gamma_array(:,delete_array,:,:) = [];
Casecheck(:,delete_array) = []; 


%%%"THE GREAT CHANGE": Choose your desired matrices
%control the size of your matices again !
size(Total_mean_signal_array)
%size(Total_mean_alpha_array)
size(Total_mean_theta_array)
%size(Total_mean_beta_array)
%size(Total_mean_delta_array)
%size(Total_mean_gamma_array)
size(Casecheck);
%
%size(Total_signal_array)
%size(Total_alpha_array)
%size(Total_theta_array)
%size(Total_beta_array)
%size(Total_delta_array)
%size(Total_gamma_array)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%END OF STEP 10
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PROCESSING CHAIN RODRIGUES: STEP 11: Automatical peak detection in the mean signal:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load('montage_for_topoplot.mat')
%%%"THE GREAT CHANGE": Comment in / replicate with other electrodes if you want to have more electrodes... this is true for the entire step and following steps. This may not be mentioned again...
%%%"THE GREAT CHANGE": If your conditions are not equally often in there, the mean has to be weighted on count of trials for an adequate peak detection
%for i = 1:size(Total_mean_signal_array,1)
%    for j = 1:size(Total_mean_signal_array,2)
%        wTotal_mean_signal_array(i,j,:,:)= Total_mean_signal_array(i,j,:,:).*Casecheck(i,j);
%    end
%end

%%%"THE GREAT CHANGE": If your conditions are not equally often in there, the mean has to be weighted on count of trials:
%lookforPeak1 = double(squeeze(nanmean(nanmean(wTotal_mean_signal_array(:,:,electrode_of_interest1,:),1),2))/mean(nonzeros(Casecheck'))); %mean over all participants and all coditions on electrode position 1

%%%"THE GREAT CHANGE": If you need to select some conditions, use this and fill in the conitions_of_interests. Note that this is only the example for the default, where the trials are not equally often
%example if only some conditions are ment to be seen together:
%lookforPeak1 = double(squeeze(nanmean(nanmean(wTotal_mean_signal_array(:,[conitions_of_interest1 conditions_of_interest2],electrode_of_interest1,:),1),2))/mean(nonzeros(Casecheck(:,[conitions_of_interest1 conditions_of_interest2])'))); %mean over all participants in some oditions on electrode position 1


%%%"THE GREAT CHANGE": Comment in / replicate with other electrodes if you want to have more electrodes... this is true for the entire step and following steps. This may not be mentioned again...
%look for peaks on electrode of interest: For all conditions
lookforPeak1 = double(squeeze(nanmean(nanmean(Total_mean_signal_array(:,:,electrode_of_interest1,:),1),2))); %mean over all participants and all coditions on electrode position 1
%lookforPeak2 = double(squeeze(nanmean(nanmean(Total_mean_signal_array(:,:,electrode_of_interest2,:),1),2))); %mean over all participants and all coditions on electrode position 2
%lookforPeak3 = double(squeeze(nanmean(nanmean(Total_mean_signal_array(:,:,electrode_of_interest3,:),1),2))); %mean over all participants and all coditions on electrode position 3


%%%"THE GREAT CHANGE": If you need to select some conditions, use this and fill in the conitions_of_interests. Note that this is only the example for the default, where the trials are equally often
%example if only some conditions are ment to be seen together:
%lookforPeak1 = double(squeeze(nanmean(nanmean(Total_mean_signal_array(:,[conitions_of_interest1 conditions_of_interest2],electrode_of_interest1,:),1),2))); %mean over all participants in some oditions on electrode position 1

%(poorly) visualize the data
figure
plot(lookforPeak1)
%figure
%plot(lookforPeak2)
%figure
%plot(lookforPeak3)

%automatic detection of peak in time window:
[r1,c1]=find(lookforPeak1==min(findpeaks(lookforPeak1(searchwindowstart:searchwindowstart+searchwindowlength,1)*-1)*-1))% automatic detection in the time window 
%[r2,c2]=find(lookforPeak2==min(findpeaks(lookforPeak2(searchwindowstart:searchwindowstart+searchwindowlength,1)*-1)*-1))% automatic detection in the time window 
%[r3,c3]=find(lookforPeak3==min(findpeaks(lookforPeak3(searchwindowstart:searchwindowstart+searchwindowlength,1)*-1)*-1))% automatic detection in the time window 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%END OF STEP 11
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PROCESSING CHAIN RODRIGUES: STEP 12: Create ERPs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% STEP 12a: Classical ERP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%"THE GREAT CHANGE": Choose here how many electrodes/conditions should be displayed. 
% "normal" ERP
figure
plot(lookforPeak1(display_time_start:display_time_end));
hold on
%plot(lookforPeak2(display_time_start:display_time_end));
set(gca,'XTick',[0 (display_time_end-display_time_start)/5 (display_time_end-display_time_start)*2/5 (display_time_end-display_time_start)*3/5 (display_time_end-display_time_start)*4/5 display_time_end-display_time_start] ); %This are going to be the only values affected. Here, always 1/5 of the chosen time will be marked. If you want to change this, feel free to...
set(gca,'XTickLabel',[display_time_start_from_zero_in_ms ((display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)/5)+display_time_start_from_zero_in_ms ((display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)*2/5)+display_time_start_from_zero_in_ms ((display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)*3/5)+display_time_start_from_zero_in_ms ((display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)*4/5)+display_time_start_from_zero_in_ms display_time_end_from_zero_in_ms] ); %This is what it's going to appear in those places.´
%set x limit to the display time settings)
xlim([0 display_time_end-display_time_start])
%make line in size of height picture
yl = ylim;
y=yl(1,1):0.2:yl(1,2);
plot((-display_time_start_from_zero_in_ms/(1000/EEG.srate))*ones(size(y)), y, 'LineWidth', 1) %plot a line on 0
axis ij %negative up
xlabel('milliseconds')
%%%"THE GREAT CHANGE": Choose here whether it is really microvolt or whether it is microvolt/m² or microvolt/cm² -> CSD transformation means unit change ! 
ylabel('microvolts/m²')
%Time window for ERP:
Peak_window_start = r1-display_time_start+1-windowlength/2; 
Peak_fenster_ende = r1-display_time_start+1+windowlength/2; 
plot(Peak_window_start*ones(size(y)), y, '--b','LineWidth', 1) % plot dotted line to mark start of ERP extraction window (centered around the peak)
plot(Peak_fenster_ende*ones(size(y)) , y, '--b', 'LineWidth', 1) % plot dotted line to mark end of ERP extraction window (centered around the peak)
%%%"THE GREAT CHANGE": Choose the ERP title (picture title)
title('My ERP')
%%%"THE GREAT CHANGE": Include a legend if you want to:
%legend('y = electrodeofinterest1','y = electrodeofinterest2', 'Location', 'southeast' )
%%%"THE GREAT CHANGE": Change the name of the exported file or its´ resolution or its´ format
%%Export this plot automatically
export_fig 'mybeautifulerpyayayay' '-tif' '-r400'

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%END OF STEP 12a
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% STEP 12b: ERP with between SE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%"THE GREAT CHANGE": Choose here how many electrodes/conditions should be displayed. 
%ERP with between SE (SE of participants)
%%%"THE GREAT CHANGE": Choose the ERP title (frame title)
figure('name', 'this is my title')
boundedline(1:display_time_end-display_time_start+1, lookforPeak1(display_time_start:display_time_end),double(squeeze(nanstd(nanmean(Total_mean_signal_array(:,:,electrode_of_interest1,display_time_start:display_time_end),2),  0, 1)/sqrt(size(Total_mean_signal_array,1)))), '-r',...
1:display_time_end-display_time_start+1, lookforPeak2(display_time_start:display_time_end),double(squeeze(nanstd(nanmean(Total_mean_signal_array(:,:,electrode_of_interest2,display_time_start:display_time_end),2),  0, 1)/sqrt(size(Total_mean_signal_array,1)))), '-b',...
'alpha');
set(gca,'XTick',[0 (display_time_end-display_time_start)/5 (display_time_end-display_time_start)*2/5 (display_time_end-display_time_start)*3/5 (display_time_end-display_time_start)*4/5 display_time_end-display_time_start] ); %This are going to be the only values affected. Here, always 1/5 of the chosen time will be marked. If you want to change this, feel free to...
set(gca,'XTickLabel',[display_time_start_from_zero_in_ms ((display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)/5)+display_time_start_from_zero_in_ms ((display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)*2/5)+display_time_start_from_zero_in_ms ((display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)*3/5)+display_time_start_from_zero_in_ms ((display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)*4/5)+display_time_start_from_zero_in_ms display_time_end_from_zero_in_ms] ); %This is what it's going to appear in those places.´
%set x limit to the display time settings)
xlim([0 display_time_end-display_time_start])
yl = ylim;
y=yl(1,1):0.2:yl(1,2); %make line in size of height picture
hold on
plot((-display_time_start_from_zero_in_ms/(1000/EEG.srate))*ones(size(y)), y, 'LineWidth', 1) %plot a line on 0
axis ij % mach negative up
xlabel('milliseconds')
%%%"THE GREAT CHANGE": Choose here whether it is really microvolt or whether it is microvolt/m² or microvolt/cm² -> CSD transformation means unit change ! 
ylabel('microvolts')
%%%"THE GREAT CHANGE": Choose which time window to display (r1,r2,r3...)
%Time window for ERP:
Peak_window_start = r1-display_time_start+1-windowlength/2; 
Peak_fenster_ende = r1-display_time_start+1+windowlength/2; 
plot(Peak_window_start*ones(size(y)), y, '--b','LineWidth', 1) % plot dotted line to mark start of ERP extraction window (centered around the peak)
plot(Peak_fenster_ende*ones(size(y)) , y, '--b', 'LineWidth', 1) % plot dotted line to mark end of ERP extraction window (centered around the peak)
%%%"THE GREAT CHANGE": Choose the ERP title (picture title)
title('My ERP with an SE(between SE)')
%%%"THE GREAT CHANGE": Include a legend if you want to:
%legend('y = electrodeofinterest1','y = electrodeofinterest2', 'Location', 'southeast' )
%%%"THE GREAT CHANGE": Change the name of the exported file or its´ resolution or its´ format
%%Export this plot automatically
export_fig 'mybeautifulerpwithbetweenseyayayay' '-tif' '-r400'

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%END OF STEP 12b
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%"THE GREAT CHANGE": Choose wheteher you need or want this...
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% STEP 12c: ERP with within SE 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% %%%"THE GREAT CHANGE": Choose here how many conditions should be computed. The example only goes to 3 conditions. Also, you have to specify the "array of interest" where you specifiy the conditions and also which conditions may be averaged together
%Count_of_conditions_of_interest = 3; %specifiy how many differences there will be computed. Note that this is always count of conditions of interest-1 for first, -2 for second...
% %Note also, that you have to delete the Differences_electrode_of_interest array if you compute new differences.
% 
%conditions_of_interest = [condition_of_interest1A condition_of_interest1B; condition_of_interest2A condition_of_interest2B; condition_of_interest3A condition_of_interest3B];
% %%%"THE GREAT CHANGE": The conditions of interest and also which conditions may be averaged together: adjust also the count of conditions to average over below (here 1 and 2 in dimension 2 of the matrix)
%for i = 1:size(conditions_of_interest,1)
%    array_of_interest(:,i,:,:) = nanmean(Total_mean_signal_array(:,[conditions_of_interest(i,1) conditions_of_interest(i,2)],:,:),2);
%end

% h=1;
% for i = 1:Count_of_conditions_of_interest
%	 for j = 1:Count_of_conditions_of_interest
%		 if ~(i == j) && i<j
%             Differences_electrode_of_interest (:,:,:,h) = squeeze(array_of_interest(:,i,:,:) - array_of_interest(:,j,:,:));
%			 h = h+1;
%		 end
%	 end
% end

% %compute standard deviation of difference on electrode position of interest:
%Std_on_electrode_position_1 = squeeze(nanstd(Differences_electrode_of_interest(:,electrode_of_interest1,:,:)));

% %%%"THE GREAT CHANGE": Choose here how many conditions should be computed. The example calculation only goes to 5 conditions.
% %Compute standard deviations for the differences
% for i = 1:Count_of_conditions_of_interest
    % if i == 1
        % Mean_Std_on_electrode_position_1(:,i) = nanmean(Std_on_electrode_position_1(:,[i:Count_of_conditions_of_interest-1]),2);
    % elseif i == 2
        % Mean_Std_on_electrode_position_1(:,i) = nanmean(Std_on_electrode_position_1(:,[i-1 Count_of_conditions_of_interest:2*Count_of_conditions_of_interest-3]),2);  
    % elseif i == 3
        % Mean_Std_on_electrode_position_1(:,i) = nanmean(Std_on_electrode_position_1(:,[i-1 Count_of_conditions_of_interest 2*Count_of_conditions_of_interest-2:3*Count_of_conditions_of_interest-6]),2);  
    % elseif i == 4
        % Mean_Std_on_electrode_position_1(:,i) = nanmean(Std_on_electrode_position_1(:,[i-1 Count_of_conditions_of_interest+1 2*Count_of_conditions_of_interest-2 3*Count_of_conditions_of_interest-5:4*Count_of_conditions_of_interest-10]),2);  
    % elseif i == 5
        % Mean_Std_on_electrode_position_1(:,i) = nanmean(Std_on_electrode_position_1(:,[i-1 Count_of_conditions_of_interest+2 2*Count_of_conditions_of_interest-1 3*Count_of_conditions_of_interest-5 4*Count_of_conditions_of_interest-9:5*Count_of_conditions_of_interest-15]),2);  
    % end
    %% note: The pattern of higher i can be derived by looking at the formula from 1:5.
% end
    

%%%"THE GREAT CHANGE": Choose here how many electrodes/conditions should be displayed. 
% %%ERP with within SE (mean SE of the differences to the other conditions) Example with 3 conditions
% %%%"THE GREAT CHANGE": Choose the ERP title (frame title)
% figure('name', 'this is my title')
% boundedline(1:display_time_end-display_time_start+1,plot_peak1(display_time_start:display_time_end),double(Mean_Std_on_electrode_position_1(display_time_start:display_time_end,1)/sqrt(size(Total_mean_signal_array,1))), '-g',...
% 1:display_time_end-display_time_start+1,plot_peak2(display_time_start:display_time_end),double(Mean_Std_on_electrode_position_1(display_time_start:display_time_end,2)/sqrt(size(Total_mean_signal_array,1))), '-b',...
% 1:display_time_end-display_time_start+1,plot_peak3(display_time_start:display_time_end),double(Mean_Std_on_electrode_position_1(display_time_start:display_time_end,3)/sqrt(size(Total_mean_signal_array,1))), '-r',...
% 'alpha');
% set(gca,'XTick',[0 (display_time_end-display_time_start)/5 (display_time_end-display_time_start)*2/5 (display_time_end-display_time_start)*3/5 (display_time_end-display_time_start)*4/5 display_time_end-display_time_start] ); %This are going to be the only values affected. Here, always 1/5 of the chosen time will be marked. If you want to change this, feel free to...
% set(gca,'XTickLabel',[display_time_start_from_zero_in_ms ((display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)/5)+display_time_start_from_zero_in_ms ((display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)*2/5)+display_time_start_from_zero_in_ms ((display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)*3/5)+display_time_start_from_zero_in_ms ((display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)*4/5)+display_time_start_from_zero_in_ms display_time_end_from_zero_in_ms] ); %This is what it's going to appear in those places.´
% %set x limit to the display time settings)
% xlim([0 display_time_end-display_time_start])
% yl = ylim;
% y=yl(1,1):0.2:yl(1,2); %make line in size of height picture
% hold on
% plot((-display_time_start_from_zero_in_ms/(1000/EEG.srate))*ones(size(y)), y, 'LineWidth', 1) %plot a line on 0
% axis ij % mach negative up
% xlabel('milliseconds')
% %%%"THE GREAT CHANGE": Choose here whether it is really microvolt or whether it is microvolt/m² or microvolt/cm² -> CSD transformation means unit change ! 
% ylabel('microvolts')
% %%%"THE GREAT CHANGE": Choose which time window to display (r1,r2,r3...)
% %Time window for ERP:
% Peak_window_start = r1-display_time_start+1-windowlength/2; 
% Peak_fenster_ende = r1-display_time_start+1+windowlength/2; 
% plot(Peak_window_start*ones(size(y)), y, '--b','LineWidth', 1) % plot dotted line to mark start of ERP extraction window (centered around the peak)
% plot(Peak_fenster_ende*ones(size(y)) , y, '--b', 'LineWidth', 1) % plot dotted line to mark end of ERP extraction window (centered around the peak)
% %%%"THE GREAT CHANGE": Choose the ERP title (picture title)
% title('My ERP with an SE(within SE)')
% %%%"THE GREAT CHANGE": Include a legend if you want to:
%legend('y = Condition1','y = Condition2', 'y = Condition3',  'Location', 'southeast' )
% %%%"THE GREAT CHANGE": Change the name of the exported file or its´ resolution or its´ format
% %%Export this plot automatically
% export_fig 'mybeautifulerpwithwithinseyayayay' '-tif' '-r400'
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%END OF STEP 12c
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%END OF STEP 12
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PROCESSING CHAIN RODRIGUES: STEP 13: Create Topoplots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% STEP 13a: Topoplot peak window
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%"THE GREAT CHANGE": Load EEGlab new if not done so in this script. Might not be necessary if loaded previously. Note that all in EEG struct will be overwritten.
%check whether your matlab knows the EEGlab topoplot function... therefore just load it once more...
eeglab
%load a montage to plot in. This montage should be saved during STEP 16 in preprocessing to ICA
load('montage_for_topoplot.mat') % montage file
%%%"THE GREAT CHANGE": Choose your scaling: Adjust it to the data: If you see all green, blue or all red, it is not appropriate.
%Scaling of topoplot: Has to be adjusted ! Automatical borders are not chosen in order to get comparable topographical maps if more time steps or conditions are chosen.
Grenz = 17.5
minmax = [-Grenz Grenz];
%%%"THE GREAT CHANGE": Choose which time window to display (r1,r2,r3...)
%choose the time window
Peak_window_start_t = r1-windowlength/2; 
Peak_fenster_ende_t = r1+windowlength/2; 

%%%"THE GREAT CHANGE": Choose which conditions to display or whether all is displayed. Also choose whether your conditions where equally often
%conditions_of_interest2 = [condition_of_interest1A condition_of_interest1B condition_of_interest2A condition_of_interest2B condition_of_interest3A condition_of_interest3B];

% create datavector
%datavector = double(squeeze(nanmean(nanmean(nanmean(Total_mean_signal_array(:,conditions_of_interest2,:,Peak_window_start_t:Peak_fenster_ende_t),1),2),4))); 
%datavector = double(squeeze(nanmean(nanmean(nanmean(wTotal_mean_signal_array(:,conditions_of_interest2,:,Peak_window_start_t:Peak_fenster_ende_t),1),2),4)/mean(nonzeros(Casecheck(:,conditions_of_interest2)')))); 
datavector = double(squeeze(nanmean(nanmean(nanmean(Total_mean_signal_array(:,:,:,Peak_window_start_t:Peak_fenster_ende_t),1),2),4))); 
%datavector = double(squeeze(nanmean(nanmean(nanmean(wTotal_mean_signal_array(:,:,:,Peak_window_start_t:Peak_fenster_ende_t),1),2),4)/mean(nonzeros(Casecheck)))); 

%create topoplot figure:
figure
topoplot(datavector, EEG.chanlocs,'maplimits', minmax )
%%%"THE GREAT CHANGE": Choose a title for the plot and the font size
%%name the plot appropriate
title(['ERP of interest topography ' num2str(Peak_window_start_t*1000/EEG.srate+Segementation_time_start*1000),'ms to ' num2str(Peak_fenster_ende_t*1000/EEG.srate+Segementation_time_start*1000) 'ms'], 'FontSize', 14)
colorbar
set(gcf, 'color', [1 1 1])
%
%%%"THE GREAT CHANGE": Change the name of the exported file or its´ resolution or its´ format
%%Export this plot automatically
export_fig 'Wuhuhutopographyofpeakwindow' '-tif' '-r400'

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%END OF STEP 13a
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% STEP 13b: Topoplot Gif
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%"THE GREAT CHANGE": Choose your scaling: Adjust it to the data: If you see all green, blue or all red, it is not appropriate.
%Scaling of topoplot: Has to be adjusted ! Automatical borders are not chosen in order to get comparable topographical maps if more time steps or conditions are chosen.
Grenz = 17.5
minmax = [-Grenz Grenz];

%%%"THE GREAT CHANGE": Choose which conditions to display or whether all is displayed (note: the second dimension are the conditions)
%create the different plots
%%%"THE GREAT CHANGE": Choose which conditions to display or whether all is displayed
%conditions_of_interest2 = [condition_of_interest1A condition_of_interest1B condition_of_interest2A condition_of_interest2B condition_of_interest3A condition_of_interest3B];
%Plot_quick = squeeze(nanmean(nanmean(Total_mean_signal_array(:,conditions_of_interest2,:,:),2),1)),;	%make short helping array	
%Plot_quick = squeeze(nanmean(nanmean(Total_mean_signal_array(:,conditions_of_interest2,:,:),2),1)/mean(nonzeros(Casecheck(:,conditions_of_interest2)'))),;	%make short helping array	
Plot_quick = squeeze(nanmean(nanmean(Total_mean_signal_array(:,:,:,:),2),1)),;	%make short helping array	
%Plot_quick = squeeze(nanmean(nanmean(wTotal_mean_signal_array(:,:,:,:),2),1)/mean(nonzeros(Casecheck'))),;	%make short helping array	

fig = figure;
for idx = display_time_start_GIF_topo:timesteps:display_time_end_GIF_topo
	Peak_window_start_topo = idx;
	Peak_fenster_ende_topo = idx+timesteps-1;
	datavector = squeeze(nanmean(Plot_quick(:,Peak_window_start_topo:Peak_fenster_ende_topo),2));
	topoplot(datavector, EEG.chanlocs, 'style', 'map', 'maplimits',  minmax )
    %%%"THE GREAT CHANGE": Choose a title for the plot and control the font size
    title(['Topography during time window ',num2str(Peak_window_start_topo*1000/EEG.srate+Segementation_time_start*1000),'ms to ' num2str(Peak_fenster_ende_topo*1000/EEG.srate+Segementation_time_start*1000) 'ms'], 'FontSize', 14)
	colorbar
	drawnow
	set(gcf, 'color', [1 1 1])
	frame = getframe(fig);
	im{idx} = frame2im(frame);
end
close

%put all plots together

%%%"THE GREAT CHANGE": Change the name of the exported file 
%%Export this plot automatically
filename = 'Myfascinatingtopogifofsignal.gif'; % Specify the output file name
for idx = display_time_start_GIF_topo:timesteps:display_time_end_GIF_topo
    [A,map] = rgb2ind(im{idx},256);
    if idx == display_time_start_GIF_topo
        imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime',1);
    else
        imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',1);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%END OF STEP 13b
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PROCESSING CHAIN RODRIGUES: STEP 14: Detect frequency peaks in relevant frequency bands on relevant electrode positions.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%"THE GREAT CHANGE": Comment in / replicate with other electrodes if you want to have more electrodes... this is true for the entire step and following steps. This may not be mentioned again...
%%%"THE GREAT CHANGE": Comment in / replicate with other frequency bands if you want to have different frequency bands... this is true for the entire step and following steps. This may not be mentioned again...
%%%"THE GREAT CHANGE": Note that the timewindow for frequency responses might not be the same as for ERPs also due to time jittering
%%"THE GREAT CHANGE": If your conditions are not equally often in there, the mean has to be weighted on count of trials for an adequate peak detection
%for i = 1:size(Total_mean_theta_array,1)
%   for j = 1:size(Total_mean_theta_array,2)
%       wTotal_mean_theta_array(i,j,:,:)= Total_mean_theta_array(i,j,:,:).*Casecheck(i,j);
%   end
%end
%
%%%"THE GREAT CHANGE": If your conditions are not equally often in there, the mean has to be weighted on count of trials:
%lookforPeak1Freq = double(squeeze(nanmean(nanmean(wTotal_mean_theta_array(:,:,electrode_of_interest1,:),1),2))/mean(nonzeros(Casecheck'))); %mean over all participants and all coditions on electrode position 1

%%%"THE GREAT CHANGE": If you need to select some conditions, use this and fill in the conitions_of_interests. Note that this is only the example for the default, where the trials are not equally often
%example if only some conditions are ment to be seen together:
%lookforPeak1Freq = double(squeeze(nanmean(nanmean(wTotal_mean_theta_array(:,[conitions_of_interest1 conditions_of_interest2],electrode_of_interest1,:),1),2))/mean(nonzeros(Casecheck(:,[conitions_of_interest1 conditions_of_interest2])'))); %mean over all participants in some oditions on electrode position 1



%%%"THE GREAT CHANGE": Comment in / replicate with other electrodes if you want to have more electrodes... this is true for the entire step and following steps. This may not be mentioned again...
%%%"THE GREAT CHANGE": Comment in / replicate with other frequency bands if you want to have different frequency bands... this is true for the entire step and following steps. This may not be mentioned again...
%%%"THE GREAT CHANGE": Note that the timewindow for frequency responses might not be the same as for ERPs also due to time jittering
%look for peaks on electrode of interest: For all conditions
lookforPeak1Freq = double(squeeze(nanmean(nanmean(Total_mean_theta_array(:,:,electrode_of_interest1,:),1),2))); %mean over all participants and all coditions on electrode position 1
%lookforPeak2Freq = double(squeeze(nanmean(nanmean(Total_mean_theta_array(:,:,electrode_of_interest2,:),1),2))); %mean over all participants and all coditions on electrode position 2
%lookforPeak3Freq = double(squeeze(nanmean(nanmean(Total_mean_theta_array(:,:,electrode_of_interest3,:),1),2))); %mean over all participants and all coditions on electrode position 3

%%%"THE GREAT CHANGE": If you need to select some conditions, use this and fill in the conitions_of_interests
%example if only some conditions are ment to be seen together:
%lookforPeak1Freq = double(squeeze(nanmean(nanmean(Total_mean_theta_array(:,[conitions_of_interest1 conditions_of_interest2],electrode_of_interest1,:),1),2))); %mean over all participants and some coditions on electrode position 1

%(poorly) visualize the data
figure
plot(lookforPeak1Freq)
%figure
%plot(lookforPeak2Freq)
%figure
%plot(lookforPeak2Freq)

%automatic detection of peak in time window:
[r1freq,c1freq]=find(lookforPeak1Freq==max(findpeaks(lookforPeak1Freq(searchwindowstart:searchwindowstart+searchwindowlength,1))))% automatic detection in the time window 
%[r2freq,c2freq]=find(lookforPeak2Freq==max(findpeaks(lookforPeak2Freq(searchwindowstart:searchwindowstart+searchwindowlength,1))))% automatic detection in the time window 
%[r3freq,c3freq]=find(lookforPeak3Freq==max(findpeaks(lookforPeak3Freq(searchwindowstart:searchwindowstart+searchwindowlength,1))))% automatic detection in the time window 



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%END OF STEP 14
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PROCESSING CHAIN RODRIGUES: STEP 15: Create topographical map for frequency response
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% STEP 15a: Topoplot peak window freqency response
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%"THE GREAT CHANGE": Load EEGlab new if not done so in this script. Might not be necessary if loaded previously. Note that all in EEG struct will be overwritten.
%%check whether your matlab knows the EEGlab topoplot function... therefore just load it once more...
%eeglab
%%load a montage to plot in. This montage should be saved during STEP 16 in preprocessing to ICA
%load('montage_for_topoplot.mat') % montage file
%%%"THE GREAT CHANGE": Choose your scaling: Adjust it to the data: If you see all green, blue or all red, it is not appropriate. As a hint where to start from the mean of the frequency response is suggested. Also choose which frequency is chosen and whether you want raw power or log power
%Scaling of topoplot: Has to be adjusted ! Automatical borders are not chosen in order to get comparable topographical maps if more time steps or conditions are chosen.
%%%"THE GREAT CHANGE": Choose which conditions to display or whether all is displayed
%conditions_of_interest2 = [condition_of_interest1A condition_of_interest1B condition_of_interest2A condition_of_interest2B condition_of_interest3A condition_of_interest3B];
%Plot_quickfreq = squeeze(nanmean(nanmean(Total_mean_theta_array(:,conditions_of_interest2,:,:),2),1));		%make short helping array	
%Plot_quickfreq = squeeze(nanmean(nanmean(wTotal_mean_theta_array(:,conditions_of_interest2,:,:),2),1)/mean(nonzeros(Casecheck(:,conditions_of_interest2)')));		%make short helping array	
%Plot_quickfreq = squeeze(nanmean(nanmean(wTotal_mean_theta_array(:,:,:,:),2),1)/mean(nonzeros(Casecheck')));		%make short helping array	
Plot_quickfreq = squeeze(nanmean(nanmean(Total_mean_theta_array(:,:,:,:),2),1));		%make short helping array	
%%log power
%Plot_quickfreq = log10(squeeze(nanmean(nanmean(Total_mean_theta_array(:,conditions_of_interest2,:,:),2),1)));		%make short helping array	
%Plot_quickfreq = log10(squeeze(nanmean(nanmean(wTotal_mean_theta_array(:,conditions_of_interest2,:,:),2),1)/mean(nonzeros(Casecheck(:,conditions_of_interest2)'))));		%make short helping array	
%Plot_quickfreq = log10(squeeze(nanmean(nanmean(wTotal_mean_theta_array(:,:,:,:),2),1)/mean(nonzeros(Casecheck'))));		%make short helping array	
%Plot_quickfreq = log10(squeeze(nanmean(nanmean(Total_mean_theta_array(:,:,:,:),2),1)));		%make short helping array	
%%%"THE GREAT CHANGE": Adjust the display bar when you change for example from raw to log power
Grenzfreq = nanmean(nanmean(Plot_quickfreq,2),1);
%Grenzfreq = ?;
minmax = [0 Grenzfreq+Grenzfreq];
%%%"THE GREAT CHANGE": Choose which time window to display (r1,r2,r3...)
%choose the time window
Peak_window_start_tfreq = r1freq-windowlength/2; 
Peak_fenster_ende_tfreq = r1freq+windowlength/2; 

%%%"THE GREAT CHANGE": choose frequency band of interest. Also choose whether you want log power or raw power
% create datavector
datavectorfreq = squeeze(nanmean(Plot_quickfreq(:,Peak_window_start_tfreq:Peak_fenster_ende_tfreq),2)); 


%create topoplot figure:
figure
topoplot(datavectorfreq, EEG.chanlocs,'maplimits', minmax )
%%%"THE GREAT CHANGE": Choose a title for the plot and the font size
%%name the plot appropriate
title(['Frequency of interest topography ' num2str(Peak_window_start_tfreq*1000/EEG.srate+Segementation_time_start*1000),'ms to ' num2str(Peak_fenster_ende_tfreq*1000/EEG.srate+Segementation_time_start*1000) 'ms'], 'FontSize', 14)
colorbar
set(gcf, 'color', [1 1 1])
%
%%%"THE GREAT CHANGE": Change the name of the exported file or its´ resolution or its´ format
%%Export this plot automatically
export_fig 'Wuhuhutopographyofpeakwindowfreq' '-tif' '-r400'

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%END OF STEP 15a
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% STEP 15b: Topoplot Gif
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%"THE GREAT CHANGE": Choose your scaling: Adjust it to the data: If you see all green, blue or all red, it is not appropriate. As a hint where to start from the mean of the frequency response is suggested. Also choose which frequency is chosen and whether you want raw power or log power
%Scaling of topoplot: Has to be adjusted ! Automatical borders are not chosen in order to get comparable topographical maps if more time steps or conditions are chosen.
%%%"THE GREAT CHANGE": Choose which conditions to display or whether all is displayed
%conditions_of_interest2 = [condition_of_interest1A condition_of_interest1B condition_of_interest2A condition_of_interest2B condition_of_interest3A condition_of_interest3B];
%Plot_quickfreq = squeeze(nanmean(nanmean(Total_mean_theta_array(:,conditions_of_interest2,:,:),2),1));		%make short helping array	
%Plot_quickfreq = squeeze(nanmean(nanmean(wTotal_mean_theta_array(:,conditions_of_interest2,:,:),2),1)/mean(nonzeros(Casecheck(:,conditions_of_interest2)')));		%make short helping array	
%Plot_quickfreq = squeeze(nanmean(nanmean(wTotal_mean_theta_array(:,:,:,:),2),1)/mean(nonzeros(Casecheck')));		%make short helping array	
Plot_quickfreq = squeeze(nanmean(nanmean(Total_mean_theta_array(:,:,:,:),2),1));		%make short helping array	
%%log power
%Plot_quickfreq = log10(squeeze(nanmean(nanmean(Total_mean_theta_array(:,conditions_of_interest2,:,:),2),1)));		%make short helping array	
%Plot_quickfreq = log10(squeeze(nanmean(nanmean(wTotal_mean_theta_array(:,conditions_of_interest2,:,:),2),1)/mean(nonzeros(Casecheck(:,conditions_of_interest2)'))));		%make short helping array	
%Plot_quickfreq = log10(squeeze(nanmean(nanmean(wTotal_mean_theta_array(:,:,:,:),2),1)/mean(nonzeros(Casecheck'))));		%make short helping array	
%Plot_quickfreq = log10(squeeze(nanmean(nanmean(Total_mean_theta_array(:,:,:,:),2),1)));		%make short helping array	
%%%"THE GREAT CHANGE": Adjust the display bar when you change for example from raw to log power
Grenzfreq = nanmean(nanmean(Plot_quickfreq,2),1);
%Grenzfreq = ?;
minmax = [0 Grenzfreq+Grenzfreq];

%%%"THE GREAT CHANGE": Choose which frequency is chosen
%create the different plots
fig = figure;
for idx = display_time_start_GIF_topo:timesteps:display_time_end_GIF_topo
	Peak_window_start_topo = idx;
	Peak_fenster_ende_topo = idx+timesteps-1;
	datavectorfreq = squeeze(nanmean(Plot_quickfreq(:,Peak_window_start_topo:Peak_fenster_ende_topo),2));
	topoplot(datavectorfreq, EEG.chanlocs, 'style', 'map', 'maplimits',  minmax )
    %%%"THE GREAT CHANGE": Choose a title for the plot and control the font size
    title(['Topography during time window for frequency of interest ',num2str(Peak_window_start_topo*1000/EEG.srate+Segementation_time_start*1000),'ms to ' num2str(Peak_fenster_ende_topo*1000/EEG.srate+Segementation_time_start*1000) 'ms'], 'FontSize', 14)
	colorbar
	drawnow
	set(gcf, 'color', [1 1 1])
	frame = getframe(fig);
	im{idx} = frame2im(frame);
end
close

%put all plots together

%%%"THE GREAT CHANGE": Change the name of the exported file 
%%Export this plot automatically
filename = 'Myfascinatingtopogifoffrequency.gif'; % Specify the output file name
for idx = display_time_start_GIF_topo:timesteps:display_time_end_GIF_topo
    [A,map] = rgb2ind(im{idx},256);
    if idx == display_time_start_GIF_topo
        imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime',1);
    else
        imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',1);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%END OF STEP 15b
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PROCESSING CHAIN RODRIGUES: STEP 16: Create a time frequency plot in a broad frequency window
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%"THE GREAT CHANGE": See whether you need to load the montage (again) because it contains necessary information for the next step like sampling rate 
%%load a montage to plot in. This montage should be saved during STEP 16 in preprocessing to ICA
%load('montage_for_topoplot.mat') % montage file

%%%"THE GREAT CHANGE": Choose the array according to your data structure
%Create an array for the display. Also create the weighted array, if necessary
Total_freq_array(:,:,:,:) = nan(COUNTPARTICIPANT,size(NEWCASEARRAY,2),2*(max_freq-min_freq)+1,(display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)/(1000/EEG.srate), 'single');	
%wTotal_freq_array(:,:,:,:) = nan(COUNTPARTICIPANT,size(NEWCASEARRAY,2),2*(max_freq-min_freq)+1,(display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)/(1000/EEG.srate), 'single');	

%%%"THE GREAT CHANGE": Check whether all parameters are valid. Note that this step assumes that step 2 was performed (in order to avoid unnecessary conditions). If not, then just comment in the other line and comment out the "NEWCASEARRAY" lines
%This reloads the data for the relevant time window and performs the "big" frequency analysis. This is necessary if no single trial data is already present. If single trial data is present, you mal also start from the single trial array
for VP = 1:COUNTPARTICIPANT
	EEG = pop_loadset('filename',filenames{VP},'filepath',read_dir);									%load set (first time)	-> Reason for this here: in case of error, the file is not loaded every case but only if something is done correctly
	
	for CASES = 1:size(NEWCASEARRAY,2) %we already know what is there in the dataset
	%for CASES = 1:size(CASEARRAY,2) %we already know what is there in the dataset
        
        %Segment the data according to relevant markers
		try % see whether the relevant segements are there... else do the next iteration
            EEG = pop_epoch( EEG, {NEWCASEARRAY{CASES}}, [Segementation_time_start Segementation_time_end ], 'newname', strcat(filenames{VP},NEWCASEARRAY{CASES}), 'epochinfo', 'yes'); %selection here: trial
            %EEG = pop_epoch( EEG, {CASEARRAY{CASES}}, [Segementation_time_start Segementation_time_end ], 'newname', strcat(filenames{VP},CASEARRAY{CASES}), 'epochinfo', 'yes'); %selection here: trial
            [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off'); 
            EEG = eeg_checkset( EEG );

            %Define the Baseline manually
            %Manual Baseline total file:
            for i = 1:size(EEG.data,1)
                for j = 1:size(EEG.data,3)
                        EEG.data (i,:,j) = EEG.data (i,:,j) - nanmean(EEG.data(i,baselinestart:baselinestop,j),2);
                end
            end

            EEG = pop_select( EEG,'time',[display_time_start_from_zero_in_ms/1000 display_time_end_from_zero_in_ms/1000] );
            [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off'); 

            [GraphicsPlot frequ] = wavelet_power_plot(EEG,'lowfreq', min_freq, 'highfreq', max_freq, 'log_spacing', 1, 'fixed_cycles', 3.5); % 4 dim array = Channelx Freq x Time x Trials (Epochs)
            
            Total_freq_array(VP,CASES,:,:) =  squeeze(nanmean(GraphicsPlot(electrode_of_interest1,:,:,:),4)); % 4 D array: VP, Cases, Frequencies, times (on electrode of interest): be careful: this may be not weighted due to differnt count of trials in conditions
            wTotal_freq_array(VP,CASES,:,:) =  squeeze(nanmean(GraphicsPlot(electrode_of_interest1,:,:,:),4).*Casecheck(VP,CASES));
            clear GraphicsPlot
		
            STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];	    %clear the EEG sets
            EEG = pop_loadset('filename',filenames{VP},'filepath',read_dir);       %reload data here if something was cut from it
		end %try end: If this condition can not be found, then simply start from here -> next condition
	end
	STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];		    %clear the EEG sets
end



%%%"THE GREAT CHANGE": Choose whether you want to look at all conditions or just a few selected ones. If you need some specific conditions, specify their number and uncomment the respective lines below. Also see whether you want to display just one or all participants. If you want just one, then get rid of the nanmean of the first dimension

%%Summarize the needed data in array
%Plot_this_quick = squeeze(nanmean(nanmean(Total_freq_array(:,conditions_of_interest2,:,:),2),1));		%make short helping array	
%Plot_this_quick  = squeeze(nanmean(nanmean(wTotal_freq_array(:,conditions_of_interest2,:,:),2),1)/mean(nonzeros(Casecheck(:,conditions_of_interest2)')));		%make short helping array	
%Plot_this_quick = squeeze(nanmean(nanmean(wTotal_freq_array(:,:,:,:),2),1)/mean(nonzeros(Casecheck')));		%make short helping array	
Plot_this_quick  = squeeze(nanmean(nanmean(Total_freq_array(:,:,:,:),2),1));		%make short helping array	

%create "fake" EEG data structure in order to use Mike Cohens function:
EEG.trials = 1; %it is just one trial...
EEG.xmin = display_time_start_from_zero_in_ms;
EEG.xmax = display_time_end_from_zero_in_ms;
EEG.times = EEG.xmin:(1000/EEG.srate):(EEG.xmax-(1000/EEG.srate));
EEG.pnts = size(EEG.times,2);


%%%"THE GREAT CHANGE": Do you want log power or raw power or db to baseline ? It is suggested to use db to baseline here, as there are different frequencies involved and therefore the power law is affecting the data. If only one frequency band is selected, this does not matter that much
%loose all but electrode of interest
%eegpower = log10(squeeze(Plot_this_quick)); %make log of the power
%eegpower = Plot_this_quick; %raw power
%%%"THE GREAT CHANGE": Choose a baseline, this needs to be in the time window of the display
%db change baseline: Here from window start to 0
baselinef_start =1;
baselinef_end = -display_time_start_from_zero_in_ms/(1000/EEG.srate);
eegpower = 10*log10(Plot_this_quick./repmat(squeeze(nanmean(Plot_this_quick(:,baselinef_start:baselinef_end),2)),1,size(Plot_this_quick,2))); %db change to baseline
%%%"THE GREAT CHANGE": Select how many steps you want
%Steps
frequencystepparamter=30;
%plot
figure
%%%"THE GREAT CHANGE": Change your stile of Plot ?
contourf(EEG.times,frequ,eegpower,frequencystepparamter,'linecolor','none')
%imagesc(EEG.times,frequ,eegpower) %different stile
%set(gca,'YDir','normal')          %different stile line 2: This is needed too, because of the y axis flip of imagesc


%%%"THE GREAT CHANGE": Choose your scaling: Adjust it to the data: If you see all green, blue or all red, it is not appropriate. As a hint where to start from the mean of the frequency response is suggested. Also choose which frequency is chosen and whether you want raw power or log power
%Choose the power limit. 
%powerlimit = nanmean(nanmean(eegpower,1),2)*1.96; %inside-joke... but it is really an arbitraty suggestion... Note that with this formular, if the mean is negative (which could be) there will be an error !
%own powerlimits
powerlimit = 3;
%%%"THE GREAT CHANGE": Choose linear or log spacing of the frequencies. Also adjust your display limit. In db to baseline, negative and positive is ok. Otherwise (if not to baseline), negative values will not appear
%linear spacing plot
set(gca,'clim',[-powerlimit powerlimit],'xlim',[display_time_start_from_zero_in_ms display_time_end_from_zero_in_ms],'xtick',display_time_start_from_zero_in_ms:(display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)/5:display_time_end_from_zero_in_ms,'yscale','linear','ytick',min_freq:5:max_freq,'yticklabel',min_freq:5:max_freq)
%%log spacing plot
%%set(gca,'clim',[-powerlimit powerlimit],'xlim',[display_time_start_from_zero_in_ms display_time_end_from_zero_in_ms],'xtick',display_time_start_from_zero_in_ms:(display_time_end_from_zero_in_ms-display_time_start_from_zero_in_ms)/5:display_time_end_from_zero_in_ms,'yscale','log','ytick',logspace(log10(min_freq),log10(max_freq),6),'yticklabel',round(logspace(log10(min_freq),log10(max_freq),6)*10)/10)
ylabel('Frequency (Hz)')
xlabel('Time (ms)')
%%%"THE GREAT CHANGE": Give it a a good title
title('Frequency spectrum from 1 to 30 Hz on electrode of interest')
h = colorbar;
%%%"THE GREAT CHANGE": Check your units: Is it a CSD or normal reference ? Remember that you made a frequency power transformation. Also remember whether you displayed log power or raw power.
%ylabel(h, 'log power (µV²/m²)', 'Rotation',90)
ylabel(h, 'dB change from baseline', 'Rotation',90)
%%%"THE GREAT CHANGE": Change size of figure ?
set(gcf, 'Units', 'points', 'OuterPosition', [0, 0, 400, 400]);
set(gcf, 'color', [1 1 1])
%%%"THE GREAT CHANGE": Name the file an change format or resolution
export_fig 'Yeahthisistimefrequncystuffright' '-tif' '-r400'

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%END OF STEP 16
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PROCESSING CHAIN RODRIGUES: STEP 17: Export data to relevant statistical programms
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%goto the save path
eval(['cd ', printpath])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% STEP 17a: Export long format
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%"THE GREAT CHANGE": Check the details of your output below ! Which data do you want to export ? Also do you need to get the unequal trials export ?
%export the mean data in long format:
%Note that there are quicker ways to do this, but here you may still see what you are doing...
%This file is exporting all electrodes for all conditions for all participants in the time windows 1 and freq1 (mean of the time windows). Of course this can be changed to electrodes of interest only or other time windows of interest or....
% The structure of the file is: VP, Conditionnumber, electrode number, FRN, Theta, alpha, beta, delta, gamma
for VP = 1:size(Total_mean_signal_array,1)
    %%%"THE GREAT CHANGE": Choose your conditions of interest and adjust the array accordingly... e.g. [1 3 5 6], note that still there will be much space between the entries if you don´t change this either.
    for conditions = 1:size(Total_mean_signal_array,2)
        %%%"THE GREAT CHANGE": Choose whether you want all electodes or whether you want to modify the code in order to get only some electrodes of interest.
        %%%"THE GREAT CHANGE": Choose whether you want to have the VP "name" or internal VP number (see explanation below). If you want the name, be sure that the file is appropriately named (see below)
        Exportfile_long_format_mean1((VP-1)*size(Total_mean_signal_array,2)*size(Total_mean_signal_array,3)+(conditions-1)*size(Total_mean_signal_array,3)+1:(VP-1)*size(Total_mean_signal_array,2)*size(Total_mean_signal_array,3)+(conditions-1)*size(Total_mean_signal_array,3)+size(Total_mean_signal_array,3),1) = str2num(strrep(filenames{VP},'.set','')); %Write VP Name: Note that writing in this VP number only works when your VP is named "42.set" for instance. Otherwise you have to strrep some more unnecessary parts of the name of the VP,or use only the internal number and export the filenames and us it as it is used for the conditions and electrodes below
        %Exportfile_long_format_mean1((VP-1)*size(Total_mean_signal_array,2)*size(Total_mean_signal_array,3)+(conditions-1)*size(Total_mean_signal_array,3)+1:(VP-1)*size(Total_mean_signal_array,2)*size(Total_mean_signal_array,3)+(conditions-1)*size(Total_mean_signal_array,3)+size(Total_mean_signal_array,3),1) = VP; %%Write VP number:Note that this number is not the real VP number, but only an internal number. Find the correct number/name in filesnames and match it in the statistics programm
        Exportfile_long_format_mean1((VP-1)*size(Total_mean_signal_array,2)*size(Total_mean_signal_array,3)+(conditions-1)*size(Total_mean_signal_array,3)+1:(VP-1)*size(Total_mean_signal_array,2)*size(Total_mean_signal_array,3)+(conditions-1)*size(Total_mean_signal_array,3)+size(Total_mean_signal_array,3),2) = conditions;  %Write condition number 
        Exportfile_long_format_mean1((VP-1)*size(Total_mean_signal_array,2)*size(Total_mean_signal_array,3)+(conditions-1)*size(Total_mean_signal_array,3)+1:(VP-1)*size(Total_mean_signal_array,2)*size(Total_mean_signal_array,3)+(conditions-1)*size(Total_mean_signal_array,3)+size(Total_mean_signal_array,3),3) = transpose(1:size(Total_mean_signal_array,3)); %Write electrode number 
        %%%"THE GREAT CHANGE": Choose which electrodes you want to include and which time window should be used for the extraction. Modify the script accordingly or just export all electrodes.
        Exportfile_long_format_mean1((VP-1)*size(Total_mean_signal_array,2)*size(Total_mean_signal_array,3)+(conditions-1)*size(Total_mean_signal_array,3)+1:(VP-1)*size(Total_mean_signal_array,2)*size(Total_mean_signal_array,3)+(conditions-1)*size(Total_mean_signal_array,3)+size(Total_mean_signal_array,3),4) = squeeze(nanmean(Total_mean_signal_array(VP,conditions,:,r1-windowlength/2:r1+windowlength/2),4)); %Write FRN of target window 1
         %%%"THE GREAT CHANGE": Choose which frequency bands and electrodes you want to include and which time window should be used for the extraction. Modify the script accordingly or just export all electrodes. The example is given for the Theta. Note that the arrays (frequencies and signal) are with identical structure
        Exportfile_long_format_mean1((VP-1)*size(Total_mean_signal_array,2)*size(Total_mean_signal_array,3)+(conditions-1)*size(Total_mean_signal_array,3)+1:(VP-1)*size(Total_mean_signal_array,2)*size(Total_mean_signal_array,3)+(conditions-1)*size(Total_mean_signal_array,3)+size(Total_mean_signal_array,3),5) = squeeze(nanmean(Total_mean_theta_array(VP,conditions,:,r1freq-windowlength/2:r1freq+windowlength/2),4)); %Write theta of target window 1
        %Exportfile_long_format_mean1((VP-1)*size(Total_mean_signal_array,2)*size(Total_mean_signal_array,3)+(conditions-1)*size(Total_mean_signal_array,3)+1:(VP-1)*size(Total_mean_signal_array,2)*size(Total_mean_signal_array,3)+(conditions-1)*size(Total_mean_signal_array,3)+size(Total_mean_signal_array,3),6) = squeeze(nanmean(Total_mean_alpha_array(VP,conditions,:,r1freq-windowlength/2:r1freq+windowlength/2),4)); %Write alpha of target window 1
        %Exportfile_long_format_mean1((VP-1)*size(Total_mean_signal_array,2)*size(Total_mean_signal_array,3)+(conditions-1)*size(Total_mean_signal_array,3)+1:(VP-1)*size(Total_mean_signal_array,2)*size(Total_mean_signal_array,3)+(conditions-1)*size(Total_mean_signal_array,3)+size(Total_mean_signal_array,3),7) = squeeze(nanmean(Total_mean_beta_array(VP,conditions,:,r1freq-windowlength/2:r1freq+windowlength/2),4)); %Write beta of target window 1
        %Exportfile_long_format_mean1((VP-1)*size(Total_mean_signal_array,2)*size(Total_mean_signal_array,3)+(conditions-1)*size(Total_mean_signal_array,3)+1:(VP-1)*size(Total_mean_signal_array,2)*size(Total_mean_signal_array,3)+(conditions-1)*size(Total_mean_signal_array,3)+size(Total_mean_signal_array,3),8) = squeeze(nanmean(Total_mean_delta_array(VP,conditions,:,r1freq-windowlength/2:r1freq+windowlength/2),4)); %Write delta of target window 1
        %Exportfile_long_format_mean1((VP-1)*size(Total_mean_signal_array,2)*size(Total_mean_signal_array,3)+(conditions-1)*size(Total_mean_signal_array,3)+1:(VP-1)*size(Total_mean_signal_array,2)*size(Total_mean_signal_array,3)+(conditions-1)*size(Total_mean_signal_array,3)+size(Total_mean_signal_array,3),9) = squeeze(nanmean(Total_mean_gamma_array(VP,conditions,:,r1freq-windowlength/2:r1freq+windowlength/2),4)); %Write gamma of target window 1   
        

        %%%"THE GREAT CHANGE": Choose whether you need the modified export for unequal trials and which electrodes you want to include and which time window should be used for the extraction. Modify the script accordingly or just export all electrodes.
        %These examples are for the weighted mean export. Be aware that this kind of export corrects in a person according to the amount of trial and mean based weights, with fewer trials leading to dampened values, more trials inflating values.
        %Exportfile_long_format_mean1((VP-1)*size(Total_mean_signal_array,2)*size(Total_mean_signal_array,3)+(conditions-1)*size(Total_mean_signal_array,3)+1:(VP-1)*size(Total_mean_signal_array,2)*size(Total_mean_signal_array,3)+(conditions-1)*size(Total_mean_signal_array,3)+size(Total_mean_signal_array,3),10) = squeeze(nanmean(wTotal_mean_signal_array(VP,conditions,:,r1-windowlength/2:r1+windowlength/2),4))/mean(nonzeros(Casecheck(:,conditions)')); %Write weighted FRN of target window 1
        %%%"THE GREAT CHANGE": Choose whether you need the modified export for unequal trials for frequencies and which electrodes you want to include and which time window should be used for the extraction. Modify the script accordingly or just export all electrodes. The example is given for the Theta. Note that the arrays (frequencies and signal) are with identical structure
        %Exportfile_long_format_mean1((VP-1)*size(Total_mean_signal_array,2)*size(Total_mean_signal_array,3)+(conditions-1)*size(Total_mean_signal_array,3)+1:(VP-1)*size(Total_mean_signal_array,2)*size(Total_mean_signal_array,3)+(conditions-1)*size(Total_mean_signal_array,3)+size(Total_mean_signal_array,3),11) = squeeze(nanmean(wTotal_mean_theta_array(VP,conditions,:,r1-windowlength/2:r1+windowlength/2),4))/mean(nonzeros(Casecheck(:,conditions)')); %Write weighted theta of target window 1
    end              
end

% %%%"THE GREAT CHANGE": Choose which Exports to safe. Remember that you may only save what you have created previously. Give each file a propper name
%Export as Excel file:
xlswrite('export_this_file_excel',Exportfile_long_format_mean1)
%save as matlab file
save('export_this_file_matalb.mat','Exportfile_long_format_mean1')

%create and save necessary information
for i = 1:size(EEG.chanlocs,2)
    Chanlabels{i,1} = EEG.chanlocs(1,i).labels;
end
%save to matlab
save('export_this_file_matalb_information_long_format.mat','filenames', 'EEG', 'CASEARRAY', 'NEWCASEARRAY', 'Chanlabels')

%export as txt
fid = fopen(strcat(printpath,'filenames.txt'),'w');
fprintf(fid,'%s\n', filenames{:});
fclose(fid)

fid = fopen(strcat(printpath,'Chanlabels.txt'),'w');
fprintf(fid,'%s\n', Chanlabels{:});
fclose(fid)

fid = fopen(strcat(printpath,'Casearray_old.txt'),'w');
fprintf(fid,'%s\n', CASEARRAY{:});
fclose(fid)

fid = fopen(strcat(printpath,'Casearray_new.txt'),'w');
fprintf(fid,'%s\n', NEWCASEARRAY{:});
fclose(fid)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%END OF STEP 17a
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% STEP 17b: Export wide format
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%create necessary information
for i = 1:size(EEG.chanlocs,2)
    Chanlabels{i,1} = EEG.chanlocs(1,i).labels;
end

%wide format: write also label file
%export the mean data in long format:
%Note that there are quicker ways to do this, but here you may still see what you are doing...
%This file is exporting all electrodes for all conditions for all participants in the time windows 1 and freq1 (mean of the time windows). Of course this can be changed to electrodes of interest only or other time windows of interest or....
% The structure of the files are seen in a seperate label file, but it is VP in rows, conditionxelectrodes
    %%%"THE GREAT CHANGE": Choose your conditions of interest and adjust the array accordingly... e.g. [1 3 5 6], note that still there will be much space between the entries if you don´t change this either.
for conditions = 1:size(Total_mean_signal_array,2)
    %%%"THE GREAT CHANGE": Choose your electrodes of interest and adjust the array accordingly... e.g. [1 3 5 6], note that still there will be much space between the entries if you don´t change this either.
    for electrodepositions = 1:size(Total_mean_signal_array,3)
        Exportfile_wide_format_mean1(1:size(Total_mean_signal_array,1), (conditions-1)*size(Total_mean_signal_array,3)+electrodepositions) = transpose(squeeze(nanmean(Total_mean_signal_array(:,conditions,electrodepositions,r1-windowlength/2:r1+windowlength/2),4)));  %Write FRN of target window 1
        Export_file_names{(conditions-1)*size(Total_mean_signal_array,3)+electrodepositions} = strcat(Chanlabels{electrodepositions,1},NEWCASEARRAY{1,conditions});  %Write File with the labels of the colums
          % %%%"THE GREAT CHANGE": Choose which frequency bands and electrodes you want to include and which time window should be used for the extraction. Modify the script accordingly or just export all electrodes. The example is given for the Theta. Note that the arrays (frequencies and signal) are with identical structure
        Exportfile_wide_format_mean2(1:size(Total_mean_signal_array,1), (conditions-1)*size(Total_mean_signal_array,3)+electrodepositions) = transpose(squeeze(nanmean(Total_mean_theta_array(:,conditions,electrodepositions,r1-windowlength/2:r1+windowlength/2),4)));  %%Write theta of target window 1
        %Exportfile_wide_format_mean3(1:size(Total_mean_signal_array,1), (conditions-1)*size(Total_mean_signal_array,3)+electrodepositions) = transpose(squeeze(nanmean(Total_mean_alpha_array(:,conditions,electrodepositions,r1-windowlength/2:r1+windowlength/2),4)));  %%Write alpha of target window 1
        %Exportfile_wide_format_mean4(1:size(Total_mean_signal_array,1), (conditions-1)*size(Total_mean_signal_array,3)+electrodepositions) = transpose(squeeze(nanmean(Total_mean_beta_array(:,conditions,electrodepositions,r1-windowlength/2:r1+windowlength/2),4)));  %%Write beta of target window 1
        %Exportfile_wide_format_mean5(1:size(Total_mean_signal_array,1), (conditions-1)*size(Total_mean_signal_array,3)+electrodepositions) = transpose(squeeze(nanmean(Total_mean_delta_array(:,conditions,electrodepositions,r1-windowlength/2:r1+windowlength/2),4)));  %%Write delta of target window 1
        %Exportfile_wide_format_mean6(1:size(Total_mean_signal_array,1), (conditions-1)*size(Total_mean_signal_array,3)+electrodepositions) = transpose(squeeze(nanmean(Total_mean_gamma_array(:,conditions,electrodepositions,r1-windowlength/2:r1+windowlength/2),4)));  %Write gamma of target window 1
    
        %%%"THE GREAT CHANGE": Choose whether you need the modified export for unequal trials and which electrodes you want to include and which time window should be used for the extraction. Modify the script accordingly or just export all electrodes.
        %These examples are for the weighted mean export. Be aware that this kind of export corrects in a person according to the amount of trial and mean based weights, with fewer trials leading to dampened values, more trials inflating values.
        Exportfile_wide_format_mean7(1:size(Total_mean_signal_array,1), (conditions-1)*size(Total_mean_signal_array,3)+electrodepositions) = transpose(squeeze(nanmean(wTotal_mean_signal_array(:,conditions,electrodepositions,r1-windowlength/2:r1+windowlength/2),4))/mean(nonzeros(Casecheck(:,conditions)')));  %Write weighted FRN of target window 1
        %%%"THE GREAT CHANGE": Choose whether you need the modified export for unequal trials for frequencies and which electrodes you want to include and which time window should be used for the extraction. Modify the script accordingly or just export all electrodes. The example is given for the Theta. Note that the arrays (frequencies and signal) are with identical structure
        Exportfile_wide_format_mean8(1:size(Total_mean_signal_array,1), (conditions-1)*size(Total_mean_signal_array,3)+electrodepositions) = transpose(squeeze(nanmean(wTotal_mean_theta_array(:,conditions,electrodepositions,r1-windowlength/2:r1+windowlength/2),4))/mean(nonzeros(Casecheck(:,conditions)')));  %%Write weighted theta of target window 1
        
    end              
end
%create a colum vector of the labels for export
Export_file_names_colum = transpose(Export_file_names);

% %%%"THE GREAT CHANGE": Choose which Exports to safe. Remember that you may only save what you have created previously. Give each file a propper name
%Export as Excel file:
xlswrite('export_this_file_excel_wide1',Exportfile_wide_format_mean1)
xlswrite('export_this_file_excel_wide2',Exportfile_wide_format_mean2)
%xlswrite('export_this_file_excel_wide3',Exportfile_wide_format_mean3)
%xlswrite('export_this_file_excel_wide4',Exportfile_wide_format_mean4)
%xlswrite('export_this_file_excel_wide5',Exportfile_wide_format_mean5)
%xlswrite('export_this_file_excel_wide6',Exportfile_wide_format_mean6)
%xlswrite('export_this_file_excel_wide7',Exportfile_wide_format_mean7)
%xlswrite('export_this_file_excel_wide8',Exportfile_wide_format_mean8)

% %%%"THE GREAT CHANGE": Choose which Exports to safe. Remember that you may only save what you have created previously. Give each file a propper name
%save as matlab file
save('export_this_file_matlab_wide1.mat','Exportfile_wide_format_mean1')
save('export_this_file_matlab_wide2.mat','Exportfile_wide_format_mean2')
%save('export_this_file_matlab_wide3.mat','Exportfile_wide_format_mean3')
%save('export_this_file_matlab_wide4.mat','Exportfile_wide_format_mean4')
%save('export_this_file_matlab_wide5.mat','Exportfile_wide_format_mean5')
%save('export_this_file_matlab_wide6.mat','Exportfile_wide_format_mean6')
%save('export_this_file_matlab_wide7.mat','Exportfile_wide_format_mean7')
%save('export_this_file_matlab_wide8.mat','Exportfile_wide_format_mean8')

%save necessary information
save('export_this_file_matalb_information_wide_format.mat','filenames', 'EEG', 'CASEARRAY', 'NEWCASEARRAY', 'Chanlabels', 'Export_file_names','Export_file_names_colum')

%export as txt
fid = fopen(strcat(printpath,'filenames.txt'),'w');
fprintf(fid,'%s\n', filenames{:});
fclose(fid)

fid = fopen(strcat(printpath,'Chanlabels.txt'),'w');
fprintf(fid,'%s\n', Chanlabels{:});
fclose(fid)

fid = fopen(strcat(printpath,'Casearray_old.txt'),'w');
fprintf(fid,'%s\n', CASEARRAY{:});
fclose(fid)

fid = fopen(strcat(printpath,'Casearray_new.txt'),'w');
fprintf(fid,'%s\n', NEWCASEARRAY{:});
fclose(fid)

fid = fopen(strcat(printpath,'Export_file_names_colum.txt'),'w');
fprintf(fid,'%s\n', Export_file_names_colum{:});
fclose(fid)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%END OF STEP 17b
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% %%%"THE GREAT CHANGE": Choose to uncomment this if you need to
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% STEP 17c: Export long format single trials
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %export the data in long format:
% %Note that there are quicker ways to do this, but here you may still see what you are doing...
% %This file is exporting all electrodes for all conditions for all participants for all trials in the time windows 1 and freq1 (mean of the time windows). Of course this can be changed to electrodes of interest only or other time windows of interest or....
% % The structure of the file is: VP, Conditionnumber, electrode number, trial, FRN, Theta, alpha, beta, delta, gamma
% for VP = 1:size(Total_signal_array,1)
    % %%%"THE GREAT CHANGE": Choose your conditions of interest and adjust the array accordingly... e.g. [1 3 5 6], note that still there will be much space between the entries if you don´t change this either.
    % for conditions = 1:size(Total_signal_array,2)
        % %%%"THE GREAT CHANGE": Choose your trials of interest and adjust the array accordingly... e.g. [1 3 5 6], note that still there will be much space between the entries if you don´t change this either.
        % for trials = 1:size(Total_signal_array,5)
            % %%%"THE GREAT CHANGE": Choose whether you want all electodes or whether you want to modify the code in order to get only some electrodes of interest.
            % %%%"THE GREAT CHANGE": Choose whether you want to have the VP "name" or internal VP number (see explanation below). If you want the name, be sure that the file is appropriately named (see below)
            % Exportfile_long_format_1((VP-1)*size(Total_signal_array,2)*size(Total_signal_array,3)*size(Total_signal_array,5)+(conditions-1)*size(Total_signal_array,3)*size(Total_signal_array,5)+(trials-1)*size(Total_signal_array,3)+1:(VP-1)*size(Total_signal_array,2)*size(Total_signal_array,3)*size(Total_signal_array,5)+(conditions-1)*size(Total_signal_array,3)*size(Total_signal_array,5)+(trials-1)*size(Total_signal_array,3)+size(Total_signal_array,3),1) = str2num(strrep(filenames{VP},'.set','')); %Write VP Name: Note that writing in this VP number only works when your VP is named "42.set" for instance. Otherwise you have to strrep some more unnecessary parts of the name of the VP,or use only the internal number and export the filenames and us it as it is used for the conditions and electrodes below
            % %Exportfile_long_format_1((VP-1)*size(Total_signal_array,2)*size(Total_signal_array,3)*size(Total_signal_array,5)+(conditions-1)*size(Total_signal_array,3)*size(Total_signal_array,5)+(trials-1)*size(Total_signal_array,3)+1:(VP-1)*size(Total_signal_array,2)*size(Total_signal_array,3)*size(Total_signal_array,5)+(conditions-1)*size(Total_signal_array,3)*size(Total_signal_array,5)+(trials-1)*size(Total_signal_array,3)+size(Total_signal_array,3),1) =  VP; %%Write VP number:Note that this number is not the real VP number, but only an internal number. Find the correct number/name in filesnames and match it in the statistics programm
            % Exportfile_long_format_1((VP-1)*size(Total_signal_array,2)*size(Total_signal_array,3)*size(Total_signal_array,5)+(conditions-1)*size(Total_signal_array,3)*size(Total_signal_array,5)+(trials-1)*size(Total_signal_array,3)+1:(VP-1)*size(Total_signal_array,2)*size(Total_signal_array,3)*size(Total_signal_array,5)+(conditions-1)*size(Total_signal_array,3)*size(Total_signal_array,5)+(trials-1)*size(Total_signal_array,3)+size(Total_signal_array,3),2) = conditions;  %Write condition number 
            % Exportfile_long_format_1((VP-1)*size(Total_signal_array,2)*size(Total_signal_array,3)*size(Total_signal_array,5)+(conditions-1)*size(Total_signal_array,3)*size(Total_signal_array,5)+(trials-1)*size(Total_signal_array,3)+1:(VP-1)*size(Total_signal_array,2)*size(Total_signal_array,3)*size(Total_signal_array,5)+(conditions-1)*size(Total_signal_array,3)*size(Total_signal_array,5)+(trials-1)*size(Total_signal_array,3)+size(Total_signal_array,3),3) = transpose(1:size(Total_signal_array,3)); %Write electrode number 
            % Exportfile_long_format_1((VP-1)*size(Total_signal_array,2)*size(Total_signal_array,3)*size(Total_signal_array,5)+(conditions-1)*size(Total_signal_array,3)*size(Total_signal_array,5)+(trials-1)*size(Total_signal_array,3)+1:(VP-1)*size(Total_signal_array,2)*size(Total_signal_array,3)*size(Total_signal_array,5)+(conditions-1)*size(Total_signal_array,3)*size(Total_signal_array,5)+(trials-1)*size(Total_signal_array,3)+size(Total_signal_array,3),4) = trials;  %% Write trial number
            % %%%"THE GREAT CHANGE": Choose which electrodes you want to include and which time window should be used for the extraction. Modify the script accordingly or just export all electrodes.
            % Exportfile_long_format_1((VP-1)*size(Total_signal_array,2)*size(Total_signal_array,3)*size(Total_signal_array,5)+(conditions-1)*size(Total_signal_array,3)*size(Total_signal_array,5)+(trials-1)*size(Total_signal_array,3)+1:(VP-1)*size(Total_signal_array,2)*size(Total_signal_array,3)*size(Total_signal_array,5)+(conditions-1)*size(Total_signal_array,3)*size(Total_signal_array,5)+(trials-1)*size(Total_signal_array,3)+size(Total_signal_array,3),5) = squeeze(nanmean(Total_signal_array(VP,conditions,:,r1-windowlength/2:r1+windowlength/2,trials),4)); %Write FRN of target window 1
             % %%%"THE GREAT CHANGE": Choose which frequency bands and electrodes you want to include and which time window should be used for the extraction. Modify the script accordingly or just export all electrodes. The example is given for the Theta. Note that the arrays (frequencies and signal) are with identical structure
            % Exportfile_long_format_1((VP-1)*size(Total_signal_array,2)*size(Total_signal_array,3)*size(Total_signal_array,5)+(conditions-1)*size(Total_signal_array,3)*size(Total_signal_array,5)+(trials-1)*size(Total_signal_array,3)+1:(VP-1)*size(Total_signal_array,2)*size(Total_signal_array,3)*size(Total_signal_array,5)+(conditions-1)*size(Total_signal_array,3)*size(Total_signal_array,5)+(trials-1)*size(Total_signal_array,3)+size(Total_signal_array,3),6) = squeeze(nanmean(Total_theta_array(VP,conditions,:,r1freq-windowlength/2:r1freq+windowlength/2,trials),4)); %Write theta of target window 1
            % %Exportfile_long_format_1((VP-1)*size(Total_signal_array,2)*size(Total_signal_array,3)*size(Total_signal_array,5)+(conditions-1)*size(Total_signal_array,3)*size(Total_signal_array,5)+(trials-1)*size(Total_signal_array,3)+1:(VP-1)*size(Total_signal_array,2)*size(Total_signal_array,3)*size(Total_signal_array,5)+(conditions-1)*size(Total_signal_array,3)*size(Total_signal_array,5)+(trials-1)*size(Total_signal_array,3)+size(Total_signal_array,3),7) = squeeze(nanmean(Total_alpha_array(VP,conditions,:,r1freq-windowlength/2:r1freq+windowlength/2,trials),4)); %Write alpha of target window 1
            % %Exportfile_long_format_1((VP-1)*size(Total_signal_array,2)*size(Total_signal_array,3)*size(Total_signal_array,5)+(conditions-1)*size(Total_signal_array,3)*size(Total_signal_array,5)+(trials-1)*size(Total_signal_array,3)+1:(VP-1)*size(Total_signal_array,2)*size(Total_signal_array,3)*size(Total_signal_array,5)+(conditions-1)*size(Total_signal_array,3)*size(Total_signal_array,5)+(trials-1)*size(Total_signal_array,3)+size(Total_signal_array,3),8) = squeeze(nanmean(Total_beta_array(VP,conditions,:,r1freq-windowlength/2:r1freq+windowlength/2,trials),4)); %Write beta of target window 1
            % %Exportfile_long_format_1((VP-1)*size(Total_signal_array,2)*size(Total_signal_array,3)*size(Total_signal_array,5)+(conditions-1)*size(Total_signal_array,3)*size(Total_signal_array,5)+(trials-1)*size(Total_signal_array,3)+1:(VP-1)*size(Total_signal_array,2)*size(Total_signal_array,3)*size(Total_signal_array,5)+(conditions-1)*size(Total_signal_array,3)*size(Total_signal_array,5)+(trials-1)*size(Total_signal_array,3)+size(Total_signal_array,3),9) = squeeze(nanmean(Total_delta_array(VP,conditions,:,r1freq-windowlength/2:r1freq+windowlength/2,trials),4)); %Write delta of target window 1
            % %Exportfile_long_format_1((VP-1)*size(Total_signal_array,2)*size(Total_signal_array,3)*size(Total_signal_array,5)+(conditions-1)*size(Total_signal_array,3)*size(Total_signal_array,5)+(trials-1)*size(Total_signal_array,3)+1:(VP-1)*size(Total_signal_array,2)*size(Total_signal_array,3)*size(Total_signal_array,5)+(conditions-1)*size(Total_signal_array,3)*size(Total_signal_array,5)+(trials-1)*size(Total_signal_array,3)+size(Total_signal_array,3),10) = squeeze(nanmean(Total_gamma_array(VP,conditions,:,r1freq-windowlength/2:r1freq+windowlength/2,trials),4)); %Write gamma of target window 1           
        % end   
    % end
% end

% % %%%"THE GREAT CHANGE": Choose which Exports to safe. Remember that you may only save what you have created previously. Give each file a propper name
% %Export as Excel file:
% xlswrite('export_this_file_excel_single_trial',Exportfile_long_format_1)
% %save as matlab file
% save('export_this_file_matalb.mat','Exportfile_long_format_1')
%
% %create and save necessary information
% for i = 1:size(EEG.chanlocs,2)
%       Chanlabels{i,1} = EEG.chanlocs(1,i).labels;
% end
% save('export_this_file_matalb_information_long_format.mat','filenames', 'EEG', 'CASEARRAY', 'NEWCASEARRAY', 'Chanlabels')
% %export as txt
% fid = fopen(strcat(printpath,'filenames.txt'),'w');
% fprintf(fid,'%s\n', filenames{:});
% fclose(fid)
%
% fid = fopen(strcat(printpath,'Chanlabels.txt'),'w');
% fprintf(fid,'%s\n', Chanlabels{:});
% fclose(fid)
%
% fid = fopen(strcat(printpath,'Casearray_old.txt'),'w');
% fprintf(fid,'%s\n', CASEARRAY{:});
% fclose(fid)
%
% fid = fopen(strcat(printpath,'Casearray_new.txt'),'w');
% fprintf(fid,'%s\n', NEWCASEARRAY{:});
% fclose(fid)
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%END OF STEP 17c
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SAVE ONE ADDITIONAL EVALUATION PARAMETER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%"THE GREAT CHANGE": NOTHING, JUST MADE YOU LOOK: IN THIS MATRIX YOU FIND THE PERFORMANCE PARAMETERS OF THE CHAIN SIMILAR TO THE HAPPE: Gabard-Durnam, L. J., Mendez Leal, A. S., Wilkinson, C. L., & Levin, A. R. (2018) 
%%%%%save evaluation parameters: Following example of HAPPE, with exception of the second segmentation being in the next script: Gabard-Durnam, L. J., Mendez Leal, A. S., Wilkinson, C. L., & Levin, A. R. (2018)
Reject3_VP=sum(Reject2_VP,2);
save('Evaluation2.mat','Reject3_VP')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% END OF PROCESSING CHAIN RODRIGUES: That´s all folks: Still to come in another script (postprocessing/premiumprocessing): Cross frequency coupling 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% REFERENCES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Altman, Y (2020). export_fig (https://www.github.com/altmany/export_fig), GitHub. Retrieved March 9, 2020.
%%%%%% Cohen, M. X. (2014). Analyzing Neural Time Series Data Theory and Practice. Cambridge, Massachusetts, London, England.
%%%%%% Delorme, A., & Makeig, S. (2004). EEGLAB: an open source toolbox for analysis of single-trial EEG dynamics including independent component analysis. Journal of Neuroscience Methods, 134(1), 9–21. https://doi.org/10.1016/j.jneumeth.2003.10.009
%%%%%% Kearney, K. (2020). boundedline.m (https://www.github.com/kakearney/boundedline-pkg), GitHub. Retrieved March 9, 2020. 
%%%%%% Rodrigues, J., Liesner, M., Reutter, M., Mussel, P., & Hewig, J. (2020). It’s costly punishment, not altruistic: Low midfrontal theta and state anger predict punishment. Psychophysiology. https://doi.org/10.1111/PSYP.13557
%%%%%% Yeung, N., & Sanfey, A. G. (2004). Independent Coding of Reward Magnitude and Valence in the Human Brain. Journal of Neuroscience, 24(28), 6258–6264. https://doi.org/10.1523/JNEUROSCI.4537-03.2004
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
