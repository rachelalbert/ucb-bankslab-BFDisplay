% This script displays the pre-loaded GL commands and waits for input
if makeFix == 1
    [a b c d] = KbCheck(-1);
end
if makeFix == 1
    current_layers = 1;
elseif motion
    current_layers = round(abs(mod(floor((frameNo-1)/12),28)-14)+1);
else
    current_layers = 8;
end
depthplane = depthplane + 1;
if depthplane > 4
    depthplane = 1;
end
depthtex_handle = depthplane;
for whichEye = renderviews
    Screen('SelectStereoDrawBuffer', windowPtr, whichEye);
    Screen('BeginOpenGL', windowPtr);
    if whichEye == 1 | (whichEye == 0 & stereo == 1)
        glCallList(genlist_projection1(depthplane+whichEye*4));    %mandatory projection setup
        if static_mode  %optional mode for staic imagery
            glCallList(static_scene_disp_list1((current_layers-1)*8+depthplane+whichEye*4));
        end
    end
    Screen('EndOpenGL', windowPtr);
    
    if depthplane==3
        if whichEye==1
            Screen('FillRect', windowPtr, [255 255 255], [winRect(3)*.85, winRect(4)*.85, winRect(3) , winRect(4)]);
        else
            Screen('FillRect', windowPtr, [255 255  255], [0, winRect(4)*.85, winRect(3)*.15 , winRect(4)]);
        end
    else
        if whichEye==1
            Screen('FillRect', windowPtr, [0 0 0], [winRect(3)*.85, winRect(4)*.85, winRect(3) , winRect(4)]);
        else
            Screen('FillRect', windowPtr, [0 0 0], [0, winRect(4)*.85, winRect(3)*.15 , winRect(4)]);
        end
    end
    
    %draw response
    if(depthplane == 4 & whichEye == 1 & ~isnan(response))
        Screen('DrawText',windowPtr,num2str(response), 400, 50, [255 255 255] );
    elseif (depthplane==4 & whichEye==1 & isnan(response))
        Screen('DrawText',windowPtr,'No response',350,50,[255 255 255]);
    end
    
end
% TRY REMOVING THIS LINE
Screen('Flip', windowPtr, [], 2, 1);

[a b c d]=KbCheck();
if depthplane~=3 & a==1 
    responseTime = toc;
    if(responseTime-lastResponseTime > 0.3)
        inputstr=KbName(c);

        iKeyIndex=find(c);
        strInputName=KbName(iKeyIndex);
        if iscell(strInputName)
            strInputName=strInputName{1};
        end
        if strcmp(strInputName,'1')
            response = 1;
        elseif strcmp(strInputName,'2')
            response = 2;
        elseif strcmp(strInputName,'3')
            response = 3;
        elseif strcmp(strInputName,'4')
            response = 4;
        elseif strcmp(strInputName,'5')
            response = 5;
        elseif strcmp(strInputName,'6')
            response = 6;
        elseif strcmp(strInputName,'7')
            response = 7;
        elseif strcmp(strInputName,'8')
            response = 8;
        elseif strcmp(strInputName,'9')
            response = 9;
        elseif strcmp(strInputName,'0')
            response = 0;
        elseif strcmp(strInputName,'space')
            spacePressed=1;
%         elseif strcmp(strInputName,'ESCAPE')
%             escPressed=1;
        end
%         if strcmp(strInputName,'RightArrow')
%             response = response+1;
%         elseif strcmp(strInputName,'LeftArrow')
%             response = response-1;
%         elseif strcmp(strInputName,'UpArrow')
%             response = response+1;
%         elseif strcmp(strInputName,'DownArrow')
%             response = response-1;
%         elseif strcmp(strInputName,'space')
%             spacePressed = 1;
%         end
%         response = min(response,10);
%         response = max(response,0);
        lastResponseTime = responseTime;
    end
end

%go to next frame
frameNo = frameNo+1;


