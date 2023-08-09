


clear all   					%clear workspace matlab
clc								%clear command window matlab
eeglab							%start EEGlab
close all						%close all open plots/guis/windows in matlab: including EEGlab GUI (we don´t need that, if you want to have it back type 'eeglab redraw')



read_dir = 'C:\\Users\\falco\\Documents\\ADHD_research\\DATA\\TARGET_ADHD\\removed_automatically\\ICA\\done_still_to_reject\\';   

%"THE GREAT CHANGE"
write_dir = 'C:\\Users\\falco\\Documents\\ADHD_research\\DATA\\OUTPUT\\step_6_test_compLete\\ADHD\\';           %This is the directory 

%Here we look up how many files are in the read directory. Also we look at the names of the files.
%"THE GREAT CHANGE"
files = dir([read_dir '*.set']); % This is the file format of brain vision (.vhdr [vmrk,eeg]), if you have another file format, insert the corresponding file type
filenames = {files.name}';

%How many participants / files are there ?
COUNTPARTICIPANT = size(filenames,1);

for VP = 1:COUNTPARTICIPANT  %FOR EVERY FILE

    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    EEG = pop_loadset('filename',filenames{VP},'filepath',read_dir);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    EEG = eeg_checkset( EEG );
    pop_export(EEG,strrep(strcat(write_dir,filenames{VP}),'.set','.csv'),'transpose','on','separator',',','precision',4);
    eeglab redraw;
end


%[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
%EEG = pop_loadset('filename','v1p.set','filepath','C:\\Users\\falco\\Documents\\ADHD_research\\DATA\\TARGET\\removed_automatically\\ICA\\done_still_to_reject\\');
%[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
%eeglab redraw;

% EEGLAB history file generated on the 24-Mar-2022
% ------------------------------------------------





clear all   					%clear workspace matlab
clc								%clear command window matlab
eeglab							%start EEGlab
close all						%close all open plots/guis/windows in matlab: including EEGlab GUI (we don´t need that, if you want to have it back type 'eeglab redraw')



read_dir = 'C:\\Users\\falco\\Documents\\ADHD_research\\DATA\\TARGET_CONTROL\\removed_automatically\\ICA\\done_still_to_reject\\';   

%"THE GREAT CHANGE"
write_dir = 'C:\\Users\\falco\\Documents\\ADHD_research\\DATA\\OUTPUT\\step_6_test_compLete\\CONTROL\\';           %This is the directory 

%Here we look up how many files are in the read directory. Also we look at the names of the files.
%"THE GREAT CHANGE"
files = dir([read_dir '*.set']); % This is the file format of brain vision (.vhdr [vmrk,eeg]), if you have another file format, insert the corresponding file type
filenames = {files.name}';

%How many participants / files are there ?
COUNTPARTICIPANT = size(filenames,1);

for VP = 1:COUNTPARTICIPANT  %FOR EVERY FILE

    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    EEG = pop_loadset('filename',filenames{VP},'filepath',read_dir);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    EEG = eeg_checkset( EEG );
    pop_export(EEG,strrep(strcat(write_dir,filenames{VP}),'.set','.csv'),'transpose','on','separator',',','precision',4);
    eeglab redraw;
end


%[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
%EEG = pop_loadset('filename','v1p.set','filepath','C:\\Users\\falco\\Documents\\ADHD_research\\DATA\\TARGET\\removed_automatically\\ICA\\done_still_to_reject\\');
%[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
%eeglab redraw;

% EEGLAB history file generated on the 24-Mar-2022
% ------------------------------------------------


