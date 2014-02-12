
function [] = BF_display_Start(viewMode, observer_initials, exp_num)
%BF_display_Start(viewMode, WhatDefaultParams, observer_initials)
%David Hoffman
%July 2, 2008 Eventually this will be the roon experiment file for BF
%Lens system based display
clear GL;
tic;

%David has adapted the anaglyph teapot demo to use dual displays on
%10/27/07
%Getting rid of the silly teapot and putting in some other primatives
%at different depths


if (exist([pwd '/BF_display_Start.m'])~=2)
    disp('********************************************************************************')
    disp('*********************************ERROR******************************************')
    disp('********************************************************************************')
    disp('*************Please set the working Directory to the PTBLayers******************')
    disp('********************************************************************************')
    disp('********************************************************************************')
    disp('********************************************************************************')
    disp('********************************************************************************')
    return
    
end

global IPD;
global nearClip;
global farClip;
global vertFOV;
global horizFOV;
global deghorizoffset;
global degvertoffset;
global vertFOVoffset;
global horizFOVoffset;
global GL;
global show_image;

show_image = 1;

if ~exist('viewMode', 'var')
    viewMode = 9;
    disp('**************No Stereo Mode entered*************, defaulting to Anaglyph')
end
if ~exist('observer_initials', 'var')
    observer_initials= 'DBUG';
end
if ~exist('exp_num', 'var')
    exp_num= 'exp_0';
end
if ~exist('parameter_setting', 'var')
    parameter_setting=1;
end


if ~exist([observer_initials '.m'], 'file' )
    disp(['***********There is no observer known as ' observer_initials '  *********************'])
    disp('***********Please make a parameter file for this observer****************************')
    return
end

if ~exist([exp_num '.m'], 'file')
    disp(['***********There is no testfile known as ' exp_num '  *********************'])
    disp('***********Please check the test file****************************')
    return
end



% Is the script running in OpenGL Psychtoolbox?
AssertOpenGL;
%InitializeMatlabOpenGL;
InitializeMatlabOpenGL(0,0);
Screen('Preference', 'SkipSyncTests', 0);
% Find the screen to use for display:
screenid=max(Screen('Screens'));

if viewMode == 10
    % Yes. Do we have at least two separate displays for both views?
    if length(Screen('Screens')) < 2
        error('Sorry, for stereoMode 10 you''ll need at least 2 separate display screens in non-mirrored mode.');
    end
    
    if ~IsWin
        % Assign left-eye view (the master window) to main display:
        screenid = 0;
    else
        % Assign left-eye view (the master window) to main display:
        screenid = 1;
    end
    
    %Change the screen resolutions
    current_resolution=Screen('Resolution',1);
    
end


%Load the special params for a specific user
eval([observer_initials]);
%The observer_initials must contain the IPD, parameter_setting, and
%calibration settings


%Make sure that the display is configured correctly for the observer
disp('*************************CHECKLIST******************************')
disp('****************************************************************')
disp('*********************SET IPD************************************')
disp('*********************SET HAPLOSCOPE VERGENCE********************')
disp('****************************************************************')
disp('****************************************************************')
disp('****************************************************************')
disp('********************PRESS RETURN TO INITIALIZE******************')
disp('****************************************************************')
disp('****************************************************************')
disp('****************************************************************')

pause()

vertFOV= 23.3;  %degrees absolute
horizFOV= 32.6;  %degrees
%     % For non-bf-lens haploscope:
%     vertFOV= 44*0.9;  %degrees absolute
%     horizFOV= 57*0.9;  %degrees '

% Below is dioptric distance of actual experimental setup.
% Format: [Farthest, FarMid, MidNear, Near]
dio=[0 0.575 1.28 1.785];
% Change it to metric distances that have following characteristics.
% 1. The farthest distance is better to be less than 2 meters.
% 2. The relative difference between dioptric distances should not
% changed.
observer_initials_length=length(observer_initials);
tempStart=observer_initials_length-3;
tempEnd=observer_initials_length;
tempTestSequence=observer_initials(tempStart:tempEnd);
if strcmp(exp_num,'exp_specularity') || strcmp(tempTestSequence,'spec')
    imageplanedist=1./(3.1887+dio); % far-mid plane at 27cm away.
    % NOTE!
    % Because of base distance difference, subjects need separate
    % calibration.
else
    imageplanedist=1./(0.6988+dio);
end

%Make the distance handles
FarDist=imageplanedist(1);
FarMidDist=imageplanedist(2);
MidNearDist=imageplanedist(3);
NearDist=imageplanedist(4);
%UberNearDist and UberUberNearDist are only used as convergence distances.
UberNearDist=1/(0.6988+2.4);
UberUberNearDist=1/(0.6988+3.0);
%UberFarDist, only used as vergence distance
UberFarDist=1/(0.6988-0.6);

MidpointFarMidDist=2/(1/imageplanedist(1)+1/imageplanedist(2));  %Dioptric midpoint
MidpointMidMidDist=2/(1/imageplanedist(2)+1/imageplanedist(3));  %Dioptric midpoint
MidpointMidNearDist=2/(1/imageplanedist(3)+1/imageplanedist(4));  %Dioptric midpoint

SuperNearDist=1/(1/imageplanedist(4)+0.6);
%end of distance handles

eval([exp_num]);

ListenChar(2)

% Enable unified mode of KbName, so KbName accepts identical key names on
% all operating systems:
KbName('UnifyKeyNames');

% Setup image processing pipeline:
PsychImaging('PrepareConfiguration');

% Load and apply display calibration/undistortion for left and right
% view channels: The zero flag means: don't plot any calibration
% figures. The two optional values define xLoomSize and yLoomSize - the
% density of the undistortion mesh. They default to 73 and 53 resp. if left out:
% Note:  Comment-out the two following lines for use with non-bf-lens hapoloscope
PsychImaging('AddTask', 'RightView','GeometryCorrection','BVLCalibdata_1_800_600_180hz_08122013_MB_RA_JK.mat',0,37,27);
PsychImaging('AddTask', 'LeftView','GeometryCorrection','BVLCalibdata_0_800_600_180hz_08142013_MB_JK.mat',0,37,27);

% This line would enable horizontal mirroring of images on both stereo views:
PsychImaging('AddTask', 'AllViews','FlipHorizontal');
%PsychImaging('AddTask', 'AllViews','FlipVertical');

% Open a double-buffered full-screen window on the main displays screen
% in stereo display mode 'viewMode' and background clear color black
% (aka 0). This will enable the image processing operations - display
% undistortion for both views:

if strcmp(experiment_type,'demomode2')
    PsychImaging('AddTask','General','FloatikngPoint16Bit');
    PsychImaging('AddTask','General','UseFastOffscreenWindows');
end
if strcmp(experiment_type,'specularity')
    PsychImaging('AddTask','General','FloatingPoint16Bit');
    PsychImaging('AddTask','General','UseFastOffscreenWindows');
end
[windowPtr, winRect] = PsychImaging('OpenWindow', screenid, 0, [], [], [], viewMode, []);
if strcmp(experiment_type,'demomode2')
    Screen('Blendfunction',windowPtr,GL_SRC_ALPHA,GL_ONE);
    woff=Screen('OpenOffscreenWindow',windowPtr,BlackIndex(windowPtr));
    w_1l=Screen('OpenOffscreenWindow',windowPtr,BlackIndex(windowPtr));
    w_1r=Screen('OpenOffscreenWindow',windowPtr,BlackIndex(windowPtr));
    w_2l=Screen('OpenOffscreenWindow',windowPtr,BlackIndex(windowPtr));
    w_2r=Screen('OpenOffscreenWindow',windowPtr,BlackIndex(windowPtr));
    w_3l=Screen('OpenOffscreenWindow',windowPtr,BlackIndex(windowPtr));
    w_3r=Screen('OpenOffscreenWindow',windowPtr,BlackIndex(windowPtr));
    w_4l=Screen('OpenOffscreenWindow',windowPtr,BlackIndex(windowPtr));
    w_4r=Screen('OpenOffscreenWindow',windowPtr,BlackIndex(windowPtr));
end

if viewMode==9 % probably desktop or laptop
    % skip gamma adjustment
    %         load('BF_params/BF_CLUTlookuptables.mat');
    %         origGamma=Screen('LoadNormalizedGammaTable', windowPtr, BF_CLUT_L);
elseif viewMode==4 % BF display with DATAPixx
    load('BF_params/correctedLinearGamma_256steps_zeroOffset.mat');
    
    if strcmp(experiment_type, 'comparison')
        correctedGamma{2} = transpose(repmat(0:1/255:1, [3 1]));
    end
    origGamma=Screen('LoadNormalizedGammaTable', windowPtr, correctedGamma{2});
end

windowWidth     = winRect(3);
windowHeight    = winRect(4);

% Initially fill left- and right-eye image buffer with black background
% color:
Screen('SelectStereoDrawBuffer', windowPtr, 0);
Screen('FillRect', windowPtr, [0 255 0]);
Screen('SelectStereoDrawBuffer', windowPtr, 1);
Screen('FillRect', windowPtr, BlackIndex(screenid));
Screen('SelectStereoDrawBuffer', windowPtr, 0);
Screen('FillRect', windowPtr, [0 255 0]);
Screen('SelectStereoDrawBuffer', windowPtr, 1);
Screen('FillRect', windowPtr, BlackIndex(screenid));

% Show cleared start screen:
onset=Screen('Flip', windowPtr);

%Code for building the depth textures
% Clip planes
nearClip    = .05;        %in meters
farClip     = 2;       %in meters
% note:  Keep the near and far clip as close together as
% possible. The depth texture is finite and spans from the near
% to far clip plane
if max(imageplanedist)>farClip-.1 || min(imageplanedist)<nearClip+.05
    disp('***********************************************************')
    disp('***********************************************************')
    disp('***********************************************************')
    disp('***********************************************************')
    disp('********Check that depth planes fit in clipping bounds*****')
    disp('***********************************************************')
    disp('***********************************************************')
    disp('***********************************************************')
    disp('***********************************************************')
    disp('***********************************************************')
    return
end

Screen('BeginOpenGL', windowPtr);
glActiveTexture(GL.TEXTURE1);
glTexEnvi(GL.TEXTURE_ENV, GL.TEXTURE_ENV_MODE, GL.MODULATE);
glActiveTexture(GL.TEXTURE0);
glTexEnvi(GL.TEXTURE_ENV, GL.TEXTURE_ENV_MODE, GL.MODULATE);
Screen('EndOpenGL', windowPtr);
glClearDepth(1.0);
DEPTHTEXSIZE=4096;   %This is from depth.h and is a parameter for depth image size


depthtex_id=glGenTextures(7);

%depthtex_handle=
%1:  Depth blend, plane 1
%2:  Depth blend, plane 2
%3:  Depth blend, plane 3
%4:  Depth blend, plane 4
%5:  25% luminance
%6:  0% luminance
%7:  100% luminance
for depthtex_handle=1:7    %repeat this call for each depth plane
    BFCalcDepthTexture(depthtex_handle,depthtex_id, nearClip, farClip, imageplanedist, DEPTHTEXSIZE)
end

Screen('BeginOpenGL', windowPtr);
glActiveTexture(GL.TEXTURE1);
glTexEnvi(GL.TEXTURE_ENV, GL.TEXTURE_ENV_MODE, GL.MODULATE);
glActiveTexture(GL.TEXTURE0);
glTexEnvi(GL.TEXTURE_ENV, GL.TEXTURE_ENV_MODE, GL.MODULATE);
Screen('EndOpenGL', windowPtr);

Screen('BeginOpenGL', windowPtr);

% Some GL init
glClearColor(0.0, 0.0, 0.0, 0.0);
glDisable(GL.DEPTH_TEST);
glEnable(GL.CULL_FACE);

% Turn on OpenGL local lighting model: The lighting model supported by
% OpenGL is a local Phong model with Gouraud shading.
glDisable(GL.LIGHTING);

numframes = 1;

%Generate the textures that we want to keep throughout
texname_static=BF_build_textures;
%Generate textures for specularity project. It needs many textures, so
%make it only when we are in specularity project.
if strcmp(experiment_type,'specularity')
    %         BF_build_textures_for_specularity_project;
    BF_build_textures_for_specularity_project3;
end

if strcmp(experiment_type, 'comparison')
    glDisable(GL.DEPTH_TEST);
    trial_params=[];
    fix_params=[];
    started=0;
    BF_build_textures_optimizer;
end


Screen('EndOpenGL', windowPtr);

if strcmp(experiment_type,'demomode2')
    Screen('BeginOpenGL', windowPtr);
    lightPos    = [0 0 2 5];
    lightAmb    = [0.1 0.1 0.1 1.0];
    lightDiff   = [1.0 1.0 1.0 1.0];
    lightSpec   = [0.2 0.2 0.2 1.0];
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glEnable(GL.DEPTH_TEST);
    glEnable(GL.CULL_FACE);
    glDisable(GL.LIGHTING);
    % 		texname_static_woff=BF_build_textures; % might be non-mandatory?
    Screen('EndOpenGL', windowPtr);
end


activelensmode=1;
depthplane=1;
depthtex_handle=1;



spatialundistort=1;   %Enables and disables the spatial undistortion

adjustEye=0;  %Which eye is being adjusted during alignment

% %for randomdot stimuli, need a random dot seed array
% %or else it will randomize the dots between each view
% %eventually make this vector the right length, or don't exceed the 400.
% 
% 
% %make a sample RDS
% RDS_list_index=glGenLists(1);
% glNewList(RDS_list_index, GL.COMPILE)
% %BF_make_rds_grating(distance, numdots, grating_orientation,
% %cyclesperdegree, diameter_size_degrees, arcmindisp, IPD, dotradius_arcmin, texname_static)
% 
% %         BF_make_rds_grating(MidNearDist, 300, 90, 1.35, 4, 10, IPD, 1.5,
% %         texname_static);
% BF_make_rds_grating(MidNearDist, 30, 90, 1.35, 1.5, 0, IPD, 1.5, texname_static);
% glEndList();
% 
% CYLDOTS_list_index=glGenLists(1);
% glNewList(CYLDOTS_list_index, GL.COMPILE)
% BF_make_cylinder_dots(200, .1, .15, .001);
% glEndList();
% 
% 


if ~exist('depthoffset', 'var')
    depthoffset=0;  % how many meters should the focus cues be set backwards
    % from the specified object distance
    % a positive number pushes the focus cues back
end
if ~exist('focus_cue_multiplier', 'var')
    focus_cue_multiplier=1;   %by what factor should focal information be scaled about the ending focal distance
    %if depthoffset is 0, then this is
    %simple and just expands or
    %diminishes focal cues
    %If depthoffset is nonzero, then it
    %does this about the offset focal
    %point
    %1 means that focus cues are proportional
    %to the real depth
    %<1 means that focus cues are compressed
    %>1 means that focus cues are exaggerated
end
if ~exist('vergdist', 'var')
    vergdist=NearDist;         %This will be the default vergence distance for an object
    %This is particularly important if we
    %are using a focus_cue_multiplier
end
if ~exist('stim_type', 'var')
    stim_type='None';
end
if ~exist('show_verg_ref_dist', 'var')
    show_verg_ref_dist=0;   %This is a debugging tool so you know what the focal distance is.  It is set from the test file
end
if ~exist('trials_per_block', 'var')
    trials_per_block=200;
end
if ~exist('projection_type', 'var')
    projection_type=0;  % 0 is perspective, 1 is orthographic (warning: stereo will not work if set to 1)
end
if ~exist('use3planeonly', 'var')
    use3planeonly=0;  %with the demo, only do 3 squares if flag is set to 1
end


%Build the display lists
%This is the precomputation of the openGL stuff
%Trades off real time flexibility for speed in some cases
%Best chances of not dropping frames

%write and call display lists in same sequence as the init setting vectors
Screen('BeginOpenGL', windowPtr);


if trial_mode==0
        glDisable(GL.DEPTH_TEST);
        genlist_start=glGenLists(17);  %Returns integer of first set of free display lists
        genlist_projection1=[0 1 2 3 4 5 6 7]+genlist_start;  %Set of indices
        static_scene_disp_list=[0 1 2 3 4 5 6 7]+genlist_start+8;
        wrap_texture_on_square=16+genlist_start;
        
        for depthplane= 4: -1: 1
            depthtex_handle=depthplane;
            for whichEye=0:1
                glNewList(genlist_projection1(depthplane+whichEye*4), GL.COMPILE);
                BF_viewport_specific_GL_commands;
                glEndList();
                
                glNewList(static_scene_disp_list(depthplane+whichEye*4), GL.COMPILE);
                BFRenderScene_static;
                glEndList();
            end
        end
else
    
    %open a data file
    resultfilenameout = [pwd '/BF_data_files/BF_' observer_initials '_' exp_num '_' datestr(clock, 30) '.txt'];
    file_1 = fopen(resultfilenameout,'a');
    dumpworkspacefilename=[pwd '/BF_data_files/BF_WORKSPACE_' observer_initials '_' exp_num '_' datestr(clock, 30)];
    
end

Screen('EndOpenGL', windowPtr);

list_rendering=1;
recompute_projection_list=1;
recompute_static_scene_list=1;

% Animation loop: Run until escape key is presed
tic;
frameNum=0;
strInputName='';
while (trial_mode==0)
    timeOffset=toc;
    kinetic_dist= 0.8657+ .4637*sin(numframes/100);
    cyl_rotation=numframes/3;
    % BFWaitForInput (actually KbCheck) takes about 1.8msec.
    % Let's do that once every 8 frames,
    % which still is sampling at every 44msec.
    frameNum=frameNum+1;
    if mod(frameNum,18)==0
        [strInputName, x, y] = BFWaitForInput(0.000001); % takes 0.0017 sec
        BF_keyboard_handling;    %handle the responses
    end
    if list_rendering==1 && 0==strcmp(strInputName, '')
        %Only rebuild the display lists if they pressed a button and they are in list_rendering,
        %Also only rebuild if we have made a viewport specific change, like in
        %otherwise, proceed
        
        %glDeleteLists(genlist_start,8);  %Clear the old display lists
        depthplaneinit=depthplane;
        depthtexinit=depthtex_handle;
        if activelensmode==1
            if recompute_projection_list==1
                
                for depthplane= 1: 4
                    depthtex_handle=depthplane ;
                    for whichEye=renderviews
                        glNewList(genlist_projection1(depthplane+whichEye*4), GL.COMPILE);
                        BF_viewport_specific_GL_commands;
                        glEndList();
                    end
                end
                recompute_projection_list=0;
            end
            
            if recompute_static_scene_list==1
                
                for depthplane= 4: -1: 1
                    depthtex_handle=depthplane ;
                    for whichEye=renderviews
                        glNewList(static_scene_disp_list(depthplane+whichEye*4), GL.COMPILE);
                        BFRenderScene_static;
                        glEndList();
                    end
                end
                recompute_static_scene_list=0;
            end
            
            
        else
            
            for whichEye=renderviews
                glNewList(genlist_projection1(depthplane+whichEye*4), GL.COMPILE);
                BF_viewport_specific_GL_commands;
                glEndList();
            end
        end
        
        depthplane=depthplaneinit;
        depthtex_handle=depthtexinit;
        			depthtex_handle=depthtexinit;
        
    elseif list_rendering==1 && 0==strcmp(strInputName, '')
        genlist_start=glGenLists(16);  %Returns integer of first set of free display lists
        genlist_projection1=[0 1 2 3 4 5 6 7]+genlist_start;  %Set of indices
        static_scene_disp_list=[0 1 2 3 4 5 6 7]+genlist_start+8;
        
        for depthplane= 4: -1: 1
            depthtex_handle=depthplane;
            for whichEye=0:1
                glNewList(genlist_projection1(depthplane+whichEye*4), GL.COMPILE);
                BF_viewport_specific_GL_commands;
                glEndList();
                %                     stim_layer='surface';
                glNewList(static_surface_scene_disp_list(depthplane+whichEye*4), GL.COMPILE);
                BFRenderScene_static;
                glEndList();
                %                     stim_layer='reflection';
                % 				    glNewList(static_reflection_scene_disp_list(depthplane+whichEye*4), GL.COMPILE);
                % 				    BFRenderScene_static;
                % 				    glEndList();
            end
        end
        
    end
    
    if activelensmode
        
        depthplane=depthplane+1;
        if depthplane>4
            
            depthplane=1;
        end
        depthtex_handle=depthplane;
    end
    
   
        timeStamp=zeros(1,8);
        for whichEye=renderviews
            Screen('SelectStereoDrawBuffer', windowPtr, whichEye);
            Screen('BeginOpenGL', windowPtr);
            timeStamp(whichEye*3+1)=toc;
            timeStampDescription{whichEye*3+1}='Began OpenGL';
            
            glCallList(genlist_projection1(depthplane+whichEye*4));    %mandatory projection setup
            
            %                 glCallList(static_scene_disp_list(depthplane+whichEye*4));
            %                 BFRenderScene_dynamic;
            if static_mode  %optional mode for staic imagery
                glCallList(static_scene_disp_list(depthplane+whichEye*4));
            end
            if dynamic_mode  %optional mode for moving imagery
                glTranslatef(-0.06,.060, -kinetic_dist);
                glCallList(wrap_texture_on_square);
            end
            timeStamp(whichEye*3+2)=toc;
            timeStampDescription{whichEye*3+2}='Called list';
            
            %                 glTranslatef(0.03,.030, -kinetic_dist);
            %                 glutWireSphere(0.04, 25, 25);
            %
            %                 glTranslatef(-0.06,-.06, +(kinetic_dist)-(.8+1.2-kinetic_dist));
            %                 glutWireSphere(0.05, 20, 20);
            
            Screen('EndOpenGL', windowPtr);
            % 				if show_verg_ref_dist  % print out the lens specified depth
            %
            % 					Screen('TextSize',windowPtr, 50);
            %
            % 					Screen('DrawText', windowPtr, ['Depthplane is = ' num2str(depthplane)], 100, 100, [0, 0, 255, 255]);
            % 					Screen('DrawText', windowPtr, ['WhichEye is = ' num2str(whichEye)], 100, 200, [0, 0, 255, 255]);
            % 				end
            if depthplane==3
                if whichEye==1
                    Screen('FillRect', windowPtr, [255 255 255], [winRect(3)*.85, winRect(4)*.85, winRect(3) , winRect(4)]);
                    % 						Screen('FillRect', windowPtr, [255 255 255], [winRect(3)*.5, winRect(4)*.85, winRect(3) , winRect(4)]);
                else
                    Screen('FillRect', windowPtr, [255 255 255], [0, winRect(4)*.85, winRect(3)*.15 , winRect(4)]);
                    % 						Screen('FillRect', windowPtr, [255 255 255], [0, winRect(4)*.85, winRect(3)*.5 , winRect(4)]);
                end
            end
            
            timeStamp(whichEye*3+3)=toc;
            timeStampDescription{whichEye*3+3}='Drew rectangles';
        end
        
        timeStamp(whichEye*3+4)=toc;
        timeStampDescription{whichEye*3+4}='Ready to flip';
        
        %Screen('Flip', windowPtr [, when] [, dontclear] [, dontsync] [, multiflip]);
        onset=Screen('Flip', windowPtr, [], 2, 1);
        timeStamp(whichEye*3+5)=toc;
        timeStampDescription{whichEye*3+5}='Flipped';

    timecounter(numframes)=toc;
    timecounter1(numframes)=timeStamp(1);
    timecounter2(numframes)=timeStamp(2);
    timecounter3(numframes)=timeStamp(3);
    timecounter4(numframes)=timeStamp(4);
    timecounter5(numframes)=timeStamp(5);
    timecounter6(numframes)=timeStamp(6);
    timecounter7(numframes)=timeStamp(7);
    timecounter8(numframes)=timeStamp(8);
    
    numframes = numframes + 1;
    
end  %while trial mode==0


if ~exist('trial_counter')
    trial_counter=0;
end
if ~exist('block_counter')
    block_counter=0;
end

if trial_mode==1
    BF_initialize_trial;    %Just to build projections for splash screen
    BF_display_initial_message;
    
        stop_flag=0;
        started=1;
        
        % Trial starts here
        while stop_flag==0
            % CHANGE THESE VARIABLES FOR EACH EXPERIMENT
            
            % Randomize algorithm side
            alg_combo = Shuffle(get(scellThisRound{s_i}, 'combination'));
            
            % Get parameters for this trial
            trial_params{1} = alg_combo;
            trial_params{2} = get(scellThisRound{s_i}, 'currentValue'); % scene
            trial_params{3} = get(scellThisRound{s_i}, 'question');
            
            question = param.question_names(trial_params{3});
            questionText = question{1};
            message = 'displayquestion';
            BF_disp_message;
            
            BF_build_textures_optimizer;
            BF_initialize_trial; % calls RenderSceneStatic
            response_given = 0;
            while response_given == 0
                BF_run_trial; % calls actual GL commands
                if a == 1
                    takeKeyboardInput
                    BF_build_textures_optimizer;
                    BF_initialize_trial; % calls RenderSceneStatic
                end
            end
            process_response;
            
            
            % Trying to solve inter-trial delay
            size = uint32(zeros(length(texname_static),1));
            glDeleteTextures(size, texname_static);
            size = uint32(zeros(length(genlist_projection1),1));
            glDeleteTextures(size, genlist_projection1);
            size = uint32(zeros(length(static_scene_disp_list1),1));
            glDeleteTextures(size, static_scene_disp_list1);
            Screen('Close', texname_static);
            Screen('Close', genlist_projection1);
            Screen('Close', static_scene_disp_list1);
            
        end
        save(scell_filename,'scell','param','scellCompleted','scellThisRound','scellNextRound', 'trial_counter', 'block_counter');
        fclose(text_fp);
end

message='experimentcomplete';
BF_disp_message

message='turnlensoff';
BF_disp_message

% Close onscreen window and release all other ressources:
Screen('CloseAll');

if (viewMode==10) && current_resolution.width==1056;
    SetResolution(0, oldres);
    SetResolution(1, oldres);
end

ListenChar(0);
end

