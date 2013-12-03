while(stop_flag==0)
    % Draw screen to black
    Screen('SelectStereoDrawBuffer',windowPtr,0);
    Screen('FillRect',windowPtr,[0 0 0]);
    Screen('SelectStereoDrawBuffer',windowPtr,1);
    Screen('FillRect',windowPtr,[0 0 0]);
    Screen('Flip',windowPtr);
    
    % Wait for input
    [a, b, c, d] = KbCheck(-1);
    if a == 1
        iKeyIndex = find(c);
        strInputName = KbName(iKeyIndex(1));
        actualHingeAngle = scell{s_i}{sNum}.stimVal;
        if strcmp(strInputName, 'UpArrow') %'LeftArrow')
            % record response and update staircase
            %correct = (actualHingeAngle < 90);
            correct = randi(2)-1;
            scell{s_i}{sNum} = staircase('update', scell{s_i}{sNum}, [correct, 1]);
            break;
        elseif strcmp(strInputName, 'DownArrow') %'RightArrow')
            %correct = (actualHingeAngle >= 90);
            correct = randi(2)-1;
            scell{s_i}{sNum} = staircase('update', scell{s_i}{sNum}, [correct, 2]);
            break;
        elseif strcmp(strInputName,'ESCAPE')||strcmp(strInputName,'esc')
            stop_flag=1;
            break;
        end
    end    
end