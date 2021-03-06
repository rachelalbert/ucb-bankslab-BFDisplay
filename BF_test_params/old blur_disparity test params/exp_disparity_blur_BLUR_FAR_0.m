%This file is the prototype for the staircase method of measuring blur- and disparity-based detection thresholds


experiment_type='disparity_blur';       % Experiment for measuring visual fatigue, staircase method

trial_mode=1;                           % Enter the presentation and respond flavor of the program
show_verg_ref_dist=0;

dynamic_mode=0;                         % 1 for time varying stimulus, 0 for a static stimulus
static_mode=1;                          % 1 to present a static scene, this will be precomputed in load time
diopter_offset = 1/FarMidDist - 2.5;    % Used to move the stimuli into the display's native frusta
                
renderviews= [0 1];           % 0 is the left eye, 1 is the right eye
                
s = PTBStaircase;           % Instantiate a staircase
dumpworkspace=1;            % Dump all variables to mat file for future reference.  
trials_per_block=12;        % check: what does it stand for?

% Set up the staircases' values.  Start with one staircase.  This
% will later be duplicated and the appropriate values will be
% changed for each staircase

scell{1} = set(s,...
    'condition_num',1,... %check
    'initialValue', 0.035,...
    'initialValue_random_range', 0.01,...
    'stepSize',.02,...
    'minValue',0.0,...
    'maxValue',0.05,....
    'maxReversals',10,...
    'maximumtrials', 33,...
    'stimDistance',0.40,... %check
    'stepLimit',.00250,...
    'numUp',1,...
    'numDown',2,...
    'phase1_duration',0.75,...      % Fixation duration
    'phase2_duration',0.150,...      % Stimulus duration
    'eccentricity',0,...            % Specified in arcmin
    'pedestal',0.35,...                % Defined relative to viewer (m)
    'blur_disparity_stim',1,...     % 0 = disparity only, 1 = blur only, 2 = both
    'phase1_focusmult',1);          % 0 = no accommodation        
    

% Copy to other staircases
scell{2} = scell{1};
scell{2} = set(scell{2},'pedestal',0.335); 
scell{2} = set(scell{2},'initialValue', 0.04);
scell{3} = scell{2};
scell{3} = set(scell{3},'pedestal',0.32); 
scell{4} = scell{2};
scell{4} = set(scell{4},'pedestal',0.305); 
scell{5} = scell{2};
scell{5} = set(scell{5},'pedestal',0.29); 
scell{5} = set(scell{5},'initialValue', 0.02);
scell{6} = scell{5};
scell{6} = set(scell{6},'pedestal',0.275);

% Set all the staircases to restrict the range of test stimuli
for i=1: length(scell);
    maxVal = get(scell{i},'stimDistance') - get(scell{i},'pedestal');
    scell{i}= set(scell{i},'maxValue',maxVal);
end 


% Initialize the staircases
for i=1: length(scell);
    scell{i}=initializeStaircase(scell{i});
end


%Prepare the data file
testfileoutdir = [pwd '/datafiles'];
mkdir(testfileoutdir);
textfilenameout = [pwd '/datafiles/resultfile_' observer_initials '_' exp_num '_' datestr(clock, 30) '.txt'];

