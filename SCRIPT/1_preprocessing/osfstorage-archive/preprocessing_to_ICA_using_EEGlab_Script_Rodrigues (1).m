%%% Preprocessing Skript Rodrigues: Made by Dr. rer. nat. Johannes Rodrigues, Dipl. Psych. Julius-Maximilians University of Würzburg. johannes.rodrigues@uni-wuerzburg.de; Started 2012, Latest update: 2021_05
%%% Important Inputs were given by: Prof. John J. B. Allen, PhD, Prof. Johannes Hewig
%%% Lots ot parts or programming logic were taken from scripts by Prof. John J. B. Allen (I am not able to clearly disentangle where his ideas and input ended and where my part beginns...) Thanks a lot !!! 
%%% Important steady input over the years was also given by the Wintersymposium Montafon, in this case especially Prof. Edmund Wascher
%%% Other important input was given by Janir Nuno Ramos da Cruz and Makoto Miyakoshi as well as Nathan Fox in the final stages of the script
%%% Some parts of the measurement of the performance of the Chain are adapted from HAPPE: Gabard-Durnam, L. J., Mendez Leal, A. S., Wilkinson, C. L., & Levin, A. R. (2018).
%%% IMPORTATANT NOTE: THERE IS NO WARRENTY INCLUDED ! -> GNU 
%%% PLEASE SCROLL DOWN AND ADJUST THE PATHS AND THE DATA IMPORT FUNCTION ACCCORDING TO YOUR EEG FILE FORMAT!!!
%%% PLEASE ALSO SCROLL DOWN AND ADJUST SOME LINES ACCORDING TO YOUR EEG MONTAGE !!!
%%% THERE ARE MANY THINGS THAT NEED TO BE ADJUSTED TO YOUR DATA !
%%% FIND ALL LINES THAT NEED TO BE ADJUSTED BY THE SEARCH TERM: "THE GREAT CHANGE"
%%% PLEASE ALSO KEEP IN MIND, THAT DIFFERENT MATLAB VERSIONS MIGHT HAVE SOME CRITICAL CHANGES IN THEM THAT MAY ALTER YOUR RESULTS !!! One example is the differences in the round function that changed the Baseline EEGLAB function on "older" MATLAB Version. 
%%% Therefore some steps that are implemented in EEGlab are done "by hand" in this script.
%%% PLEASE DON´T USE THIS SCRIPT WITHOUT CONTROLLING YOUR RESULTS ! CHECK FOR PLAUSIBILITY OF THE SIGNAL AND TOPOGRAPHY (see next scripts)


%Preprocessing suggested by EEGlab: 20.01.2019
%https://sccn.ucsd.edu/wiki/Chapter_01:_Rejecting_Artifacts: 
%Rejection based on independent data components:
%
%1. Visually reject unsuitable (e.g. paroxysmal) portions of the continuous data. 
%2. Separate the data into suitable short data epochs. 
%3. Perform ICA on these epochs to derive their independent components. 
%4. Perform semi-automated and visual-inspection based rejection of data epochs on the derived components. 
%5. Visually inspect and select data epochs for rejection. 
%6. Reject the selected data epochs. 
%7. Perform ICA a second time on the pruned collection of short data epochs 
%8. Inspect and reject the components. Note that components should NOT be rejected before the second ICA, but after. 

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Preprocessing chain Rodrigues: Adaptation and automatization using Matlab 2011b / 2015b
%%% EEGlab (Delorme & Makeig, 2004), 
%%% ADJUST (Mognon, Jovicich, Bruzzone & Buiatti,2011), 
%%% MARA (Winkler, Haufe & Tangermann, 2011), 
%%% SASICA (Chaumon, Bishop, & Busch, 2015) 
%%% IClabel (Pion-Tonachini, Kreutz-Delgado & Makeig, 2019) and 
%%% CSD Toolbox (Kayser & Tenke, 2006 a,b, Kayser, 2009)  or CSD transformation provided by Cohen, 2014
%%%
%%%%
%%%%%%  PLEASE REMEMBER: GARBAGE IN -> GARBAGE OUT ! MAKE A GOOD AND CLEAN EEG DATA RECORDING ! TAKE YOUR TIME TO GET THE ELECTRODES RIGHT ! PLACE THE ELECTRODE CAP RESPONSIBLY AND WITH GREAT CARE !
%%%%%	TAKE
%%%%% 	YOUR
%%%%%	TIME 
%%%%%	!!!!
%%
%% 8-9 new steps based on the EEGlab idea:
%%
%% 1. Statistically detect and interpolate “bad” channels: z-value detection: 
%%		- probability > 3.29;   
%%		- kurtosis > 3.29; 
%%		- spectra [1 125] >3.29 
%%		- Outlier criteria 3.29: Tabachnick & Fidell, 2007 p. 73 
%%		- with average reference, because the online reference Cz should also be affected by all steps
%%		- Interpolation of "bad channel" with spline interpolation (spherical interpolation) 
%%
%%      %Note from June 2020: Ramos da Cruz Janir Nuno (EPFL.ch, check also out his APP pre-processing, similar ideas, but unfortunately I did not know it before) pointed out correctly, that one could also use the modified z-value suggested by Hoaglin. This would lead to a more progressive detection of the outliers, as the outliers are not included in the calculation of the z-value. However, as we keep stressing the importance of clean data, we also want to stick with the more "classical" approach here, partly to remind of the importance of good clean data, partly because of the criterion we are using, which has been created for the "classical" z-value.
%%
%% 2. Separate the data into suitable "first" data epochs:
%%		- Segment length:
%%			- dependent on homogeneity of trial
%%			- as long as possible
%%				- ICA solution better for longer data periods
%%			- as short as possible
%%				- ICA solution on different tasks (or things happening) lead to noisier ICs
%%				- z-value based bad segment selection on different tasks (or things happening) is less sensitive
%%	-> Suggestions:
%%		- segmentation of the whole trial (if trial is long)
%%		- segmentation of parts of experiments (if trial is short and homogenous)
%%		- semgments should have the length from 8-20 seconds, if they are not homogenous, depending on selection focus and data quality
%%	-> Don´t forget:
%%		- time window for baseline (-x before your interesting marker / event)
%%		- frequency analysis leads to edge effects and needs more space on both sides (add some buffer time)
%%		- filters leads to edge effects and needs more space on both sides (add some buffer time)
%%		- in homogenous data, overlapping segments could also be used very easily 
%%
%% 3. Highpassfilter: 1 Hz
%%		- Reason: ICA solution is more stable if no low frequency shift is present in the data and MARA performance: 
%%         After various filter testing, I come to the conclusion that Mara performs best with just 1 Hz filter: 2 Hz leads to missing side eye movement, bandpass 1-40 Hz leads to miss muscular actiation
%%		- Remember:
%%			- Filters cause edge artifacts (filter rippling)
%%			- Filters alter all data !
%%			- Filters only alter all data ! (They do not magically delete some frequency)
%%			- Filters have filter curves: onsets, peak frequency, max dampening, filter phase
%%			- Filters only dampen the frequencys (They do not magically delete some frequency, if the signal was very big, it will be still there)
%%			- There are different types of filters:
%%				- Notch (delete the target frequencies, e.g. 50 Hz (AC in Germany), 60 Hz (Monitor frequency)...) 
%%				- Lowpass / Highcut: All frequencies above the target frequency will be dampened
%%				- Highpass / Lowcut: All frequencies below the target frequency will be dampened
%%				- Bandpass: Lowpass + Highpass
%%
%% 4. First ICA: Independent component analysis
%%		- similar to factor analysis with oblique rotation
%%		- every electrode provides data -> source / sensor
%%		- one may get as many vectors (ICs) as sources
%%			- dependent on interpolation -> less information for every interpolated channel
%%          - may use pca command in ICA to correct for this problem (see https://sccn.ucsd.edu/wiki/Makoto's_preprocessing_pipeline)  
%%		- ICs are (normally) considered independent from each other, but they may also be dependent to other ICs in their subspace. However the subspaces are independent
%%
%% 5. Detection and deletion of bad segments based on z-value detection on ICs:
%%		- probability > 3.29; 
%%		- kurtosis > 3.29; 
%%		- Why ICs ? We used to do this with our channels ?
%%			- Channels may have an "unfortunate" signal/ noise ratio if a task is long an not homogenous
%%			- IC based detection is likely to be more strict
%%		- Why get rid of the bad segments anyway ?
%%			- Higher data quality for second ICA
%%
%% 6. Second ICA: Independent component analysis:
%%		- Why a second ICA ? Already did one ?
%%			- new ICA is based on "cleaned" data (without bad segments)
%%			- better solution for noise / signal components
%%			- now we select signal and noise ICs
%%          - only done when a bad segment is detected in step 5. If not, then the first ICA will be used for the next step in order to save computing time
%%
%% 7. Inspect and reject the components automatically using ADJUST and MARA with SASICA or IClabels
%% 		- using MARA & ADJUST to identify components automatically (or personal NN / ML script)
%% 		- because of MARA we already did:
%% 			- Step 1: average reference and not CSD reference (we will do this later)
%% 			- Step 3: Filter 1 Hz highpass
%%      - Alternative: IClabel: Performs a bit better than MARA & ADJUST (see Pion-Tonachini, Kreutz-Delgado & Makeig, 2019)
%%          - (personal) problem with IClabel: No personal experience with the specific thresholds that are needed, example threshold taken from Pion-Tonachini, Kreutz-Delgado & Makeig, 2019
%% 		- You honestly think MARA and ADJUST or IClabels do a good job here ? I can do it much better !
%% 			- Sure you can on a good day... but tomorrow you might not do the same as yesterday, MARA and ADJUST or IClabels will
%% 			- provide me with an ML / NN script of your classification and filtering and / or alter step 1 and step 3 as well as step 7 accordingly
%% 			- (No, I don´t think these two packages are perfect [sorry to the authors], but they do reliable and replicable decisions. Even if you are the best IC detector on earth, you cannot be working on every data set that we all get the same result)
%% 			- (Please send me better / other standardized options than those three IC detection software algorithms)
%% 
%% 7b. Reload the data and apply the ICA segment rejection and ICA component rejection to the unfiltered data (because we can...)
%%      - Good if you are interested in your data without the lowcut filter because of interest in slow oscillations or in general like unfiltered data
%%
%%
%% 8. Re-reference (to CSD)
%%		- Using the Kayser CSD toolbox or the CSD transformation function provided by Cohen, 2014 (see step 8b)
%%		- What is current source density (CSD) / laplacian transformation: 
%%			- estimation of relative current on a point of the scalp surface depending on surrounding points
%%				- distance weighted relative activation on electrodes:
%%					- estimation of scalp as a sphere
%%					- measuring of signal differences to neighbours
%%					- weightiung every difference by the distance
%%				- "reference without a reference"
%%				- every electrode can be used
%%				- spatial filter: sharpening of topography of activation / deactivation
%%		- MUCH BETTER EXPLANATION OF CSD: 
%%		http://psychophysiology.cpmc.columbia.edu/software/CSDtoolbox/tutorial.html
%%
%% 8c. Re-reference to other offline-references (why not using ... as reference...)
%%
%% 9. Now you start your "real" segmentation, depending on your task / interest / ERP vs. frequency... (not included here, see other script)
%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% END OF PREPROCESSING RODRIGUES THEORY


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PREPROCESSING CHAIN RODRIGUES: STEP 0: PREPARATION 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%"THE GREAT CHANGE": If used for the first time, provide matlab with the location of your EEGlab folder and all subfolders.
%addpath(genpath('C:\Users\yl646\Downloads\Program\eeglab2021.1')) %School Computer lab



clear all   					%clear workspace matlab
clc								%clear command window matlab
eeglab							%start EEGlab
close all						%close all open plots/guis/windows in matlab: including EEGlab GUI (we don´t need that, if you want to have it back type 'eeglab redraw')


%This file can be started several times in order to process more than one file (as the ICA takes loads of time depending on the computer and the data)
%Please make sure that you wait until step 1 is finished before you start the script a second time in order to process different files with it.

% In order to use this file properly, you need to adjust and create some directories on your computer.
% 1. You need to install the addons MARA, SASIA and ADJUST in EEGlab 
% 2. You need to create a folder structure that contains subfolders:
%		- Targetfolder
%			-before_removal			(during step 1)
%			-removed_automatically (after step 1)
%				-ICA
%					-done_still_to_reject (after step 6)
%					-automatically_rejected (after step 7)
%						-CSD (after step 8)
%   If you don´t want the folder structure to be created, comment the respective lines below.





%read in Data (still to modify)
%"THE GREAT CHANGE"
%There is your EEG raw data. Please note that you have to adjust the read in function for different file formats. Here the gui of EEGlab might help to identify the function that you need. Remember that everything you clicked in the GUI can be seen as code if you use the code "eegh"
% read_dir = 'C:\\Users\yl646\Downloads\DATA\RAW\ADHD\\';   
read_dir = 'C:\\Users\falco\Documents\ADHD_research\DATA\ADHD\\';   

%"THE GREAT CHANGE"
write_dir = 'C:\\Users\falco\Documents\ADHD_research\DATA\TARGET_ADHD\\';           %This is the directory 

%mark important paths that are needed
check_dir = strcat(write_dir,'before_removal\\'); % This is the directory to save the file after bad channel detection but before removing the bad channels (it is still before finishing step 1)
load_dir = strcat(write_dir,'removed_automatically\\');           %This is the directory to save the file after bad channel detection after removing the bad channels (it is the end of step 1)
%automatically create the folders that are needed. If you don´t want these to be created, just comment them out
mkdir(write_dir);
mkdir(check_dir);
mkdir(load_dir);
mkdir(strcat(load_dir,'ICA\\'));
mkdir(strcat(load_dir,'ICA\\done_still_to_reject\\'));
mkdir(strcat(load_dir,'ICA\\automatically_rejected\\'));
mkdir(strcat(load_dir,'ICA\\automatically_rejected\\CSD\\'));





%Here we look up how many files are in the read directory. Also we look at the names of the files.
%"THE GREAT CHANGE"
files = dir([read_dir '*.mat']); % This is the file format of brain vision (.vhdr [vmrk,eeg]), if you have another file format, insert the corresponding file type
filenames = {files.name}';

Channelz_value_automatic_detection = 3.29; % Tabachnik & Fiedell, 2007 p. 73: Outlier detection criteria


%How many participants / files are there ?
COUNTPARTICIPANT = size(filenames,1);

%"THE GREAT CHANGE": How many electrodes are in your cap ?
%How many EEG channels are there (excluding heart, skin conductance, but also exkluding online ground and reference channel)
Number_of_EEG_electrodes_without_reference_and_ground = 19;


%"THE GREAT CHANGE": Do you need this ? Adjust the number of files (and the message)
%here we look at repeated measurement paradigms with several recordings. If you have for instance 3 recordings, than your number of files should be divisible by 3
%only useful in this case. if you don´t need it, just comment it out...
%if mod(COUNTPARTICIPANT/(3),1) ~ 0																 	%look for the modulo of 3 in this case
%	WARNING_FILES = 'The count (of files) is not divisable by three ! AHAHAHAH! *thunder*'  	%Give this warning
%end


for VP = 1:COUNTPARTICIPANT  %FOR EVERY FILE
	%Here starts a small loop to check whether the file is already present in the check directory. This allows to start the file several times for parallel processing
	checkfiles = dir([check_dir '*.set']); 	%look at all files in the check directory: the set format is the eeglab format
	checkfilenames = {checkfiles.name}';	%look at all file names there
	for checkfilesi = 1:size(checkfiles)	%for every file in there
        %"THE GREAT CHANGE" here you need to adjust the file format to the format of your recorded files (example is header file from brainvision)
		if strcmp(strrep(filenames{VP},'.mat',''),strrep(checkfilenames{checkfilesi},'.set','')) == 1 	%check whether the present file is in there
			VP = VP +1;																					%if it is in there, then take the next file
		end
	end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%STEP 1
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %THREE DIFFERENT BAD ELECTRODE CHECKS (Probability, kurtosis, Frequency 1-125 Hz): We load the data 3 times for checks, then a last time to carry on with the interpolation of the bad channels
    %"THE GREAT CHANGE" here you need to adjust the function for import according to your data file format
    %LOAD THE DATA, all channels, all timepoints		
    EEG = pop_importdata('data',strcat(read_dir,filenames{VP}),'dataformat','matlab')
    EEG.setname = 'first_one'
    EEG.srate = 128
    EEG.subject = filenames{VP}
    EEG.nbcchan = 19
    EEG.group = 'ADHD'
    EEG.chanlocs = readlocs('C:\Users\falco\Documents\ADHD_research\DATA\Standard-10-20-Cap19new.ced','filetype','chanedit')

    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname',filenames{VP},'gui','on'); %in dataset 0 of EEGLab

    %remove sc Heart (if you don´t have any, comment it out or use it for eye, we don´t need that any more as we use ICA for blink and eyemovement detection
    %"THE GREAT CHANGE"
%     EEG = pop_select( EEG,'nochannel',{'sc' 'Heart'});   		%State the channels that you want to "ignore" insert your channel names
%     EEG = eeg_checkset( EEG );
%     [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off'); 

    %"THE GREAT CHANGE"
    % making space for Cz (or your online reference): Add it back to the data that it could be used. Adjust the number to the number of the last channel (done). Adjust also the second number (done) and the electrode name (here Cz) according to your montage.
    %Also adjust where your EEGlab folder lies (here eeglab14_1_1b, it is in Matlab_Addons in folder C:)
    %EEG=pop_chanedit(EEG, 'lookup','C:\\Matlab_Addon\\eeglab14_1_1b\\plugins\\dipfit2.3\\standard_BESA\\standard-10-5-cap385.elp','append',Number_of_EEG_electrodes_without_reference_and_ground,'changefield',{Number_of_EEG_electrodes_without_reference_and_ground+1 'labels' 'Cz'},'lookup','C:\\Matlab_Addon\\eeglab14_1_1b\\plugins\\dipfit2.3\\standard_BESA\\standard-10-5-cap385.elp');
    EEG=pop_chanedit(EEG, 'lookup','C:\Users\falco\Documents\ADHD_research\DATA\Standard-10-20-Cap19new.ced','append',Number_of_EEG_electrodes_without_reference_and_ground,'changefield',{Number_of_EEG_electrodes_without_reference_and_ground+1 'labels' 'ref'});
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    EEG = eeg_checkset( EEG );

    %"THE GREAT CHANGE"
    %Rereference (average) WATCH IT HERE !!!! WHICH CHANNEL ARE TO BE INCLUDED DEPENDS ON THE MONTAGE !!! Adjust the name of the electrode and the coordination system (here Cz) to your online reference you want to get back. 
    %FOR UNEXPERIENCED USERS I highly recommend to do this step in EEGLAB GUI FIRST and then use the "eegh" command to generate the syntax to put in here 
    %(Tools -> rereference: Compute average reference and Add current reference channel back to the data -> here:Cz)
    EEG = pop_reref( EEG, [],'refloc',struct('labels',{'ref'},'type',{''},'theta',{0},'radius',{0},'X',{5.2047e-015},'Y',{0},'Z',{85},'sph_theta',{0},'sph_phi',{90},'sph_radius',{85},'urchan',{65},'ref',{''},'datachan',{0}));
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off'); 
    EEG = eeg_checkset( EEG );
		
    % now we look for band channels
	
    [~, indelec1] = pop_rejchan(EEG, 'elec',[1:Number_of_EEG_electrodes_without_reference_and_ground+1] ,'threshold',Channelz_value_automatic_detection,'norm','on','measure','prob'); 		%we look for probability

	[~, indelec2] = pop_rejchan(EEG, 'elec',[1:Number_of_EEG_electrodes_without_reference_and_ground+1] ,'threshold',Channelz_value_automatic_detection,'norm','on','measure','kurt');	%we look for kurtosis 
	
    [~, indelec3] = pop_rejchan(EEG, 'elec',[1:Number_of_EEG_electrodes_without_reference_and_ground+1] ,'threshold',Channelz_value_automatic_detection,'norm','on','measure','spec','freqrange',[1 125] );	%we look for frequency spectra


    % now we look whether a channel is bad in multiple criteria
    index=sort(unique([indelec1,indelec2,indelec3])); %index is the bad channel array
    disp('%%%%%%%%%%%%%');
    disp(index);
    disp(Number_of_EEG_electrodes_without_reference_and_ground+1);
    disp('%%%%%%%%%%%%%');
    for i = 1:size(index,2)
        VP_indexarray(VP,i) = index(1,i);
    end
    savename = strcat(write_dir,'removed_channels_auto.mat');  %save the bad channel array for every participant in a matrix
    save(savename,'VP_indexarray', 'filenames');

    %Here we save the data before we remove the bad channels we have detected before
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'filename', strcat(filenames{VP},'_to_ICA'),'filepath',strcat(write_dir,'before_removal\\'));

    %remove channels because of index array
	%Interpolate Channels (Bad Channels)
    EEG = pop_interp(EEG, index, 'spherical');
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'setname', strcat(filenames{VP},'_start'),'gui','off'); 
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'filename', strcat(filenames{VP},'_to_ICA'), 'filepath',strcat(write_dir,'removed_automatically\\'));
    EEG = eeg_checkset( EEG );
	
    clear indelec1 indelec2 indelec3 i 


	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%END OF STEP 1
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%STEP 2
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Segmenting all things with events for artifact correction
	
	%"THE GREAT CHANGE" : Here you need to insert your script for segmentation. For inexperienced users, I recommend using EEGlab with the "eegh" commmand:
	%(Edit -> extract epoches -> select your relevant markers in "time locking event types", think about baseline and buffer times in "epoche limits" in s)
	%CAREFUL: SOME MATLAB VERSIONS ARE NOT COMPATIBLE WITH THE EEGLAB BASELINE CORRECTION (pop_rmbase(...)) ! IN THIS CASE, INSERT THE BASELINE CORRECTION MANUALLY ! (or manually later, see later scripts)
    %Please also keep in mind that it may be the case that some conditions are not met by all participants.
    %Therefore I created a "demo" script of a final segmentation: Named seperate_script_for_first_segmentation -> noch machen
    %load the final segmentation file in order to get the number of relevant cases that one is interested in:	
    %epoch_script % this file needs to be put into the EEGlab Folder
	EEG = pop_importevent( EEG, 'event','C:\\Users\\falco\\Documents\\ADHD_research\\event.txt','fields',{'latency','type','position'},'skipline',1,'timeunit',1);
    EEG = eeg_checkset( EEG );
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    EEG = eeg_checkset( EEG );
    EEG = pop_epoch( EEG, {  '1'  }, [-4  0],'newname', strcat(filenames{VP},'_intchan_avg_filt epochs'), 'epochinfo', 'yes');
    EEG = eeg_checkset( EEG );
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    EEG.group = 'ADHD'
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%END OF STEP 2
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%STEP 3
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Filter lowpass 1 Hz: because it gives a more stable ICA solution and works best with MARA
	% (Tools-> filter the data -> basic FIR filter (new, default) -> lower edge 1 
	%EEG = pop_eegfiltnew(EEG, [], 1, [], 1, [], 0); %%comment: These two filter displayed here are mathematically identical... notch vs. bandpass
	EEG = pop_eegfiltnew(EEG, 1, [], [], 0, [], 0);
    
	[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'gui','off'); 
	EEG = eeg_checkset( EEG );
	

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%END OF STEP 3
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%STEP 4
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%first ICA: compute the ICA, takes some time....
	%EEG = pop_runica(EEG, 'extended',1,'interupt','on');
	EEG = pop_runica(EEG, 'extended',1,'interupt','on', 'pca', Number_of_EEG_electrodes_without_reference_and_ground-size(index,2)+1); %this takes into account that we have extrapolated some channels and the rank of the matrix was reduced: Count original electrodes + reference - extrapolated channels
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%END OF STEP 4
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%STEP 5
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Reject from components when z > 20 (total), z>z-value (Channel) 
		%%"THE GREAT CHANGE" Change the number of channels to your ICA (here starting with 1:65, but the function should do it if you also added a reference channel); the z value 20 is chosen to not correct anything here on single component limitation, but only on all component limitations (global). 
        %%"THE GREAT CHANGE" Change the criterion on the single component. If your data is kind of messy (for example clinical data of epilepsy patients) I would recommend using the z-value criterion instead of the 20. A common rule of thumb is to loose around 5-10% of the data (Miyakoshi, 2021) in this step.
	EEG = pop_jointprob(EEG,0,[1:Number_of_EEG_electrodes_without_reference_and_ground-size(index,2)+1] ,20,Channelz_value_automatic_detection,0,0,0,[],0);
	EEG = eeg_rejsuperpose( EEG, 0, 1, 1, 1, 1, 1, 1, 1);
	%"THE GREAT CHANGE" Change the number of channels to your ICA(here starting with 1:65, but the function should do it if you also added a reference channel); the z value 20 is chosen to not correct anything here on single component limitation, but only on all component limitations (global)
	EEG = pop_rejkurt(EEG,0,[1:Number_of_EEG_electrodes_without_reference_and_ground-size(index,2)+1] ,20,Channelz_value_automatic_detection,2,0,1,[],0);
	EEG = eeg_rejsuperpose( EEG, 0, 1, 1, 1, 1, 1, 1, 1);
    %reject the selected bad segments !
    reject1 = EEG.reject; %save this for later approaches, for instance if intersted in LPP or other stuff with freq < 1 Hz
	EEG = pop_rejepoch( EEG, EEG.reject.rejglobal ,0);
	EEG = eeg_checkset( EEG );
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%END OF STEP 5
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%STEP 6
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%second ICA: again, takes some time... if no segments were rejected, the ICA will be the same. This can be good if the data is rather well...
    % this step is only one if data is rejected in step 5
    if sum(reject1.rejglobal) > 0
        EEG = pop_runica(EEG, 'extended',1,'interupt','on', 'pca', Number_of_EEG_electrodes_without_reference_and_ground-size(index,2)+1); %this takes into account that we have extrapolated some channels and the rank of the matrix was reduced: Count original electrodes + reference - extrapolated channels
    end
	[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 3,'setname',strcat(filenames{VP},'_all_arifact_filt1'),'overwrite','on','gui','off');
    EEG = eeg_checkset( EEG ); 
	EEG = pop_saveset( EEG, 'filename', strcat(filenames{VP},'_to_ICA'),'filepath',strcat(write_dir,'removed_automatically\\ICA\\done_still_to_reject\\'));
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%END OF STEP 6
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%STEP 7
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%automatically reject ICA: Using MARA and ADJUST with SASICA
    %% "THE GREAT CHANGE": Change what kind of selection criteria you want to apply for automatic selection. 
    %% FOR UNEXPERIENCED USERS I RECOMMEND USING THE SETTINGS AS SHOWN BELOW: Only using MARA and ADJUST
	%% Create Structure with SASICA options
	%SAS_cfg = struct;
	%% MARA (enabled)
	%SAS_cfg.MARA.enable=1;
	%% FASTER (disabled)
	%SAS_cfg.FASTER.enable=0;
	%SAS_cfg.FASTER.blinkchans=[];
	%% ADJUST (enabled)
	%SAS_cfg.ADJUST.enable=1;
	%% Channel correlations (disabled)
	%SAS_cfg.chancorr.enable=0;
	%SAS_cfg.chancorr.channames=[];
	%SAS_cfg.chancorr.corthresh = 'auto 4';
	%% EOG correlations (disabled)
	%SAS_cfg.EOGcorr.enable=0;
	%SAS_cfg.EOGcorr.Heogchannames=[];
	%SAS_cfg.EOGcorr.corthreshH='auto 4';
	%SAS_cfg.EOGcorr.Veogchannames=[];
	%SAS_cfg.EOGcorr.corthreshV='auto 4';
	%% Dipole fit residual variance (disabled)
	%SAS_cfg.resvar.enable=0;
	%SAS_cfg.resvar.thresh=15;
	%% Signal to noise ratio (disabled)
	%SAS_cfg.SNR.enable=0;
	%SAS_cfg.SNR.snrcut=1;
	%SAS_cfg.SNR.snrBL=[-Inf 0];
	%SAS_cfg.SNR.snrPOI=[0 Inf]; 
	%% Focal Trial Activity (disabled)
	%SAS_cfg.trialfoc.enable=0;
	%SAS_cfg.trialfoc.focaltrialout='auto';
	%% Focal Components (disabled)
	%SAS_cfg.focalcomp.enable=0;
	%SAS_cfg.focalcomp.focalICAout='auto';
	%% Autocorrelation (disabled)
	%SAS_cfg.autocorr.enable=0;
	%SAS_cfg.autocorr.autocorrint=20;
	%SAS_cfg.autocorr.dropautocorr='auto';
	%% Options (disabled)
	%SAS_cfg.opts.noplot=1; % if = 1, no review and just store results in EEG. / if 0= review, but still it is automatic and will carry on with the script (it does not stop here, really, believe me... )
	%SAS_cfg.opts.FontSize=12;
	%% Run with these options
	%EEG=eeg_SASICA(EEG,SAS_cfg);

    %{

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%STEP 7a (MORE RECENT APPROACH)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %automatically reject ICA: Using IClabels (to be used instead of MARA and ADJUST)
    % "THE GREAT CHANGE": Change what kind of selection criteria you want to apply for automatic selection. Note that the "other" classification is very prevalent when having more than 64 channels.
    % The default selection criteria here is considering the probability of the signal against the highest artifact probability (if signal probability is higher, use the IC). Note that the "other" classification is not seen as an artifact Pion-Tonachini, L., Kreutz-Delgado, K., & Makeig, S. (2019).
    % FOR UNEXPERIENCED USERS I RECOMMEND USING GUI FIRST AND READING Pion-Tonachini, L., Kreutz-Delgado, K., & Makeig, S. (2019). ICLabel: An automated electroencephalographic independent component classifier, dataset, and website. NeuroImage, 198, 181–197. https://doi.org/10.1016/j.neuroimage.2019.05.026
    EEG = pop_iclabel(EEG, 'default');
    %EEG = pop_icflag(EEG, [NaN NaN;0.5 1;0.5 1;0.5 1;0.5 1;0.5 1;0.5 1]); % THESE ARE EXAMPLE THRESHOLDS ! VALIDATE ON YOUR DATA !
    for i = 1:size(EEG.etc.ic_classification.ICLabel.classifications,1)
        if EEG.etc.ic_classification.ICLabel.classifications(i,1)>max(EEG.etc.ic_classification.ICLabel.classifications(i,2:6))% if signal probability is higher than "pure" artifact
            classifyICs(i)=0;
        else
            classifyICs(i)=1;
        end
    end
    EEG.reject.gcompreject=classifyICs; %
    EEG = eeg_checkset( EEG );

    %"THE GREAT CHANGE": if you want to choose other criteria, specify them here.    This code is adapted from HAPPE  (Gabard-Durnam et al., 2018)
    %"THE GREAT CHANGE": if an error comes at compvar, check whether ICA_act is empty. if it is, run this code manually and start again from "ICs_to_keep" below: EEG.icaact = (EEG.icaweights*EEG.icasphere)*EEG.data(EEG.icachansind,:);
    %%% prepare evaluation of the performance
    %store IC variables and calculate variance of data that will be kept after IC rejection: This code is adapted from HAPPE  (Gabard-Durnam et al., 2018)
    ICs_to_keep =find(EEG.reject.gcompreject == 0);
    ICA_act = EEG.icaact;
    ICA_winv =EEG.icawinv;   
    %variance of wavelet-cleaned data to be kept = varianceWav: : This code is adapted from HAPPE  (Gabard-Durnam et al., 2018)
    [proj, variancekeep] =compvar(EEG.data, ICA_act, ICA_winv, ICs_to_keep);

    % 1)	Channels that are not rejected (contributing “good” channels): see VP_indexarray
    Percentage_channels_kept(VP,1) = (1-(size(index,2)/(Number_of_EEG_electrodes_without_reference_and_ground+1)))*100;
    % 2)	Rejected ICs after second ICA
    Percentage_rejected_ICs(VP,1) = 1-(size(ICs_to_keep,2)/size(classifyICs,2));
    %3)	Variance kept after the rejection of the ICs
    Percentage_variance_kept(VP,1) = variancekeep;
    %4)	Number of rejected segment: not yet possible: later in processing with Step 5 revisited but remember taking reject1
    Reject1_VP(VP,1)=sum(reject1.rejglobal);
    %5)	Artifact probability of retained components, from ICLabel  
    median_artif_prob_good_ICs(VP,1) = median(reshape(EEG.etc.ic_classification.ICLabel.classifications(ICs_to_keep,2:6),1,[]));
    mean_artif_prob_good_ICs(VP,1) = mean(reshape(EEG.etc.ic_classification.ICLabel.classifications(ICs_to_keep,2:6),1,[]));
    range_artif_prob_good_ICs(VP,1) = range(reshape(EEG.etc.ic_classification.ICLabel.classifications(ICs_to_keep,2:6),1,[]));
    min_artif_prob_good_ICs(VP,1) = min(reshape(EEG.etc.ic_classification.ICLabel.classifications(ICs_to_keep,2:6),1,[]));
    max_artif_prob_good_ICs(VP,1) = max(reshape(EEG.etc.ic_classification.ICLabel.classifications(ICs_to_keep,2:6),1,[]));
    %including category "other"
    median_artif_prob_good_ICs(VP,2) = median(reshape(EEG.etc.ic_classification.ICLabel.classifications(ICs_to_keep,2:7),1,[]));
    mean_artif_prob_good_ICs(VP,2) = mean(reshape(EEG.etc.ic_classification.ICLabel.classifications(ICs_to_keep,2:7),1,[]));
    range_artif_prob_good_ICs(VP,2) = range(reshape(EEG.etc.ic_classification.ICLabel.classifications(ICs_to_keep,2:7),1,[]));
    min_artif_prob_good_ICs(VP,2) = min(reshape(EEG.etc.ic_classification.ICLabel.classifications(ICs_to_keep,2:7),1,[]));
    max_artif_prob_good_ICs(VP,2) = max(reshape(EEG.etc.ic_classification.ICLabel.classifications(ICs_to_keep,2:7),1,[]));

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%END OF STEP 7a
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%STEP 7b
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    %now take the original data in order to loose the 1 Hz filter:
    %first save necessary ICA components
    reject2 = EEG.reject.gcompreject;
    ICA_stuff1 = EEG.icawinv;
    ICA_stuff2 = EEG.icasphere;
    ICA_stuff3 = EEG.icaweights;
    ICA_stuff4 = EEG.icachansind;
    %now reload the data
    %"THE GREAT CHANGE" Change the file extension from vhdr (brain-vision header file) to your original file type
    EEG = pop_loadset('filename',strrep(filenames{VP},'vhdr','set'),'filepath',load_dir)
    EEG = eeg_checkset( EEG );
    %segment the data once again as before
    seperate_script_for_first_segmentation 
    %reject the bad segemtns once more
    EEG.reject = reject1; %apply the bad segments
    EEG = pop_rejepoch( EEG, EEG.reject.rejglobal ,0); %reject the bad segments
    EEG = eeg_checkset( EEG );
    %now apply the ICA solution to the unfiltered EEG data
    EEG.icawinv = ICA_stuff1;
    EEG.icasphere = ICA_stuff2;
    EEG.icaweights = ICA_stuff3;
    EEG.icachansind = ICA_stuff4;
    %recompute EEG.icaact:
    EEG = eeg_checkset( EEG );
    %set the components to reject
    EEG.reject.gcompreject = reject2;
	%Automatically reject all marked components
	EEG = pop_subcomp(EEG,[],0);
    %recompute EEG.icaact:
    EEG = eeg_checkset( EEG );
	%save it
	EEG = pop_saveset( EEG, 'filename', strcat(filenames{VP},'_to_ICA'),'filepath',strcat(write_dir,'removed_automatically\\ICA\\automatically_rejected\\'));
	[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%END OF STEP 7
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%STEP 8 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%"THE GREAT CHANGE": only needed once, adjust the path and see whether you need it later (dependent on Matlab installation: client vs. local installation)
	% addpath(genpath(('G:\Matlab_Addon\CSDtoolbox')));   % Point to place where you put CSDToolbox
	
	% %"THE GREAT CHANGE": you need to pick your own specific montage file ! How to get it and how to use it see:
	% %http://psychophysiology.cpmc.columbia.edu/software/CSDtoolbox/tutorial.html
	% load G:\Matlab_Addon\CSDtoolbox\montage.mat; %load specific montage and Matrizes to this montage
		
	% data = single(repmat(NaN,size(EEG.data))); % use single data precision

	% data = CSD(reshape(single(EEG.data), ...   % compute CSD for reshaped data (i.e., use a ...
	  % EEG.nbchan,EEG.trials*EEG.pnts),G,H);    % <channels-by-(samples*trials)> 2-D data matrix)
	% data = reshape(data,EEG.nbchan, ...        % reshape CSD output and re-assign to EEGlab ...
	   % EEG.pnts, EEG.trials);                   % <channels-by-samples-by-epochs> data matrix
	% reshaped_CSD_final = double(data);         % final CSD data
	% EEG.data = data;						% put CSD data in EEG.data
	% clear N G H data  %clear all unnessesary stuff from CSD
	
	% %save the file
	% EEG = pop_saveset( EEG, 'filename',filenames{VP},'filepath',strcat(write_dir,'removed_automatically\\ICA\\automatically_rejected\\CSD\\'));
    % %"THE GREAT CHANGE": only needed once, comment out later
    % %save the montage for topographical maps in next script:
    % EEG.data = [];
    % EEG.icaact = [];
    % save('montage_for_topoplot.mat','EEG')
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%END OF STEP 8 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%STEP 8b (MORE RECENT APPROACH)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %"THE GREAT CHANGE": IF YOU WANT IT A BIT FASTER: USE THE laplacian_perrinX-FUNCTION PROVIDED BY MIKE COHEN, 2014 ! COMMENT OUT STEP 8 and use STEP 8b instead !
	data= laplacian_perrinX(EEG.data, [EEG.chanlocs.X],[EEG.chanlocs.Y],[EEG.chanlocs.Z]);
	EEG.data = data;
    backupEEGdata = EEG.data; %backup data for other references
    backupEEGICA = EEG.icaact; %backup data for other references
	%save the file
	EEG = pop_saveset( EEG, 'filename',filenames{VP},'filepath',strcat(write_dir,'removed_automatically\\ICA\\automatically_rejected\\CSD\\'));
    %"THE GREAT CHANGE": only needed once
    %save the montage for topographical maps in next script:
    EEG.data = [];
    EEG.icaact = [];
    save('montage_for_topoplot.mat','EEG')
	
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%END OF STEP 8b
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%STEP 8c (ADDITIONAL OFFLINE REFERENCES)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %"THE GREAT CHANGE": IF YOU WANT OTHER REFERENCES USE THE RESPECTIVE REFERENCES ADDITIONALLY. (e.g. Linked Mastoids: Put in the correct channel number)
    %EEG.data = backupEEGdata;  %backuped data from previous step
    %EEG.icaact = backupEEGICA; %backuped data from previous step
	%EEG = pop_reref( EEG, [27 28] );
    %"THE GREAT CHANGE": IF YOU WANT OTHER REFERENCES... also the saving path should be adjusted... see here "Mastoid" instead of "CSD" above
	%%save the file
	%EEG = pop_saveset( EEG, 'filename',filenames{VP},'filepath',strcat(write_dir,'removed_automatically\\ICA\\automatically_rejected\\Mastoid\\'));
	%%"THE GREAT CHANGE": only needed once
    %%save the montage for topographical maps in next script:
    %EEG.data = [];
    %EEG.icaact = [];
    %save('montage_for_topoplot.mat','EEG')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%END OF STEP 8c
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %clear all stuff that is not needed for next person
	STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];
    clear ICA_stuff1 ICA_stuff2 ICA_stuff3 ICA_stuff4 reject1 reject2 data backupEEGdata backupEEGICA proj variancekeep index ICA_act ICA_winv ICs_to_keep reject1 classifyICs
	close all

    %}
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SAVE SOME EVALUATION PARAMETERS TO A MATRIX
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%"THE GREAT CHANGE": NOTHING, JUST MADE YOU LOOK: IN THIS MATRIX YOU FIND THE PERFORMANCE PARAMETERS OF THE CHAIN SIMILAR TO THE HAPPE: Gabard-Durnam, L. J., Mendez Leal, A. S., Wilkinson, C. L., & Levin, A. R. (2018) 
%%%%%save evaluation parameters: Following example of HAPPE, with exception of the second segmentation being in the next script: Gabard-Durnam, L. J., Mendez Leal, A. S., Wilkinson, C. L., & Levin, A. R. (2018)
Bad_channel_array = VP_indexarray ;
Number_Great_epochs_rejected = Reject1_VP;
save('Evaluation.mat','max_artif_prob_good_ICs','mean_artif_prob_good_ICs','median_artif_prob_good_ICs','min_artif_prob_good_ICs','Percentage_channels_kept','Percentage_rejected_ICs','Percentage_variance_kept','range_artif_prob_good_ICs','filenames','Bad_channel_array','Number_Great_epochs_rejected','Number_of_EEG_electrodes_without_reference_and_ground','Channelz_value_automatic_detection')

   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% END OF PREPROCESSING CHAIN RODRIGUES: STEPs > 8: (real) SEGMENTATION / PROCESSING: SEE NEXT SCRIPTS !
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% REFERENCES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Chaumon, M., Bishop, D. V. M., & Busch, N. A. (2015). A practical guide to the selection of independent components of the electroencephalogram for artifact correction. Journal of Neuroscience Methods, 250, 47–63. https://doi.org/10.1016/j.jneumeth.2015.02.025
%%% Cohen, M. X. (2014). Analyzing Neural Time Series Data Theory and Practice. Cambridge, Massachusetts, London, England.
%%% Delorme, A., & Makeig, S. (2004). EEGLAB: an open source toolbox for analysis of single-trial EEG dynamics including independent component analysis. Journal of Neuroscience Methods, 134(1), 9–21. https://doi.org/10.1016/j.jneumeth.2003.10.009
%%% Gabard-Durnam, L. J., Mendez Leal, A. S., Wilkinson, C. L., & Levin, A. R. (2018). The Harvard Automated Processing Pipeline for Electroencephalography (HAPPE): Standardized Processing Software for Developmental and High-Artifact Data. Frontiers in Neuroscience, 12, 97. https://doi.org/10.3389/fnins.2018.00097
%%% Kayser, J. (2009). Current source density (CSD) interpolation using spherical splines - CSD Toolbox (Version 1.1) [http://psychophysiology.cpmc.columbia.edu/Software/CSDtoolbox]. New York State Psychiatric Institute: Division of Cognitive Neuroscience.
%%% Kayser, J., Tenke, C.E. (2006a). Principal components analysis of Laplacian waveforms as a generic method for identifying ERP generator patterns: I. Evaluation with auditory oddball tasks. Clinical Neurophysiology, 117(2), 348-368. doi:10.1016/j.clinph.2005.08.034
%%% Kayser, J., Tenke, C.E. (2006b). Principal components analysis of Laplacian waveforms as a generic method for identifying ERP generator patterns: II. Adequacy of low-density estimates. Clinical Neurophysiology, 117(2), 369-380. doi:10.1016/j.clinph.2005.08.033
%%% Miyakoshi, M. (2021). Makoto’s preprocessing pipeline - SCCN. https://sccn.ucsd.edu/wiki/Makoto’s_preprocessing_pipeline
%%% Mognon, A., Jovicich, J., Bruzzone, L., & Buiatti, M. (2011). ADJUST: An automatic EEG artifact detector based on the joint use of spatial and temporal features. Psychophysiology, 48(2), 229–240. https://doi.org/10.1111/j.1469-8986.2010.01061.x
%%% Pion-Tonachini, L., Kreutz-Delgado, K., & Makeig, S. (2019). ICLabel: An automated electroencephalographic independent component classifier, dataset, and website. NeuroImage, 198, 181–197. https://doi.org/10.1016/j.neuroimage.2019.05.026
%%% Tabachnick, B. G., & Fidell, L. S. (2007). Using multivariate statistics. Pearson/Allyn & Bacon. Retrieved from https://dl.acm.org/citation.cfm?id=1213888
%%% Winkler, I., Haufe, S., & Tangermann, M. (2011). Automatic Classification of Artifactual ICA-Components for Artifact Removal in EEG Signals. Behavioral and Brain Functions, 7(1), 30. https://doi.org/10.1186/1744-9081-7-30