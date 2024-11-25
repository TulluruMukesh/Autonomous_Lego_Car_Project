global key;
InitKeyboard();  % Initialize keyboard input
brick.SetColorMode(2,2);  % Set color sensor on port 2

while 1
    pause(0.1);  % Small delay to reduce CPU usage
    color = brick.ColorCode(2);  % Read color sensor on port 2
    display(color);  % Display the detected color
    
    % Check for colors green, yellow, and blue to switch to manual mode
    if (color == 2 || color == 3 || color == 4 || color == 7)
        disp("Switching to Manual Mode");
        
        brick.StopMotor('AB');  % Stop both motors
        pause(0.1);  % Short delay
        
        % Keyboard control in manual mode
        switch key
            case 'uparrow'
                brick.MoveMotor('AB', -25);  % Move forward
            case 'leftarrow'
                brick.MoveMotor('A', 40);  % Turn left
                brick.MoveMotor('B', -40);
            case 'rightarrow'
                brick.MoveMotor('B', 35);  % Turn right
                brick.MoveMotor('A', -35);
            case 'downarrow'
                brick.MoveMotor('AB', 25);  % Move backward
            case 'w'
                brick.MoveMotor('C', 20);  % Lift up the wheelchair
                pause(0.9);
                brick.StopMotor('C');
            case 's'
                brick.MoveMotor('C', -20);  % Lower the wheelchair
                pause(0.9);
                brick.StopMotor('C');
            case 'b'
                brick.StopMotor('AB');  % Stop both motors
            case 'e'
                brick.StopMotor('AB');  % Stop both motors and exit program
                CloseKeyboard();
                break;
            case 'k'
                InitKeyboard();  % Reinitialize keyboard input
        end
    end

    % Check for red color to apply brakes
    if color == 5
        disp("Red light, applying brakes; hold tight");
        brick.MoveMotor('AB', 0);  % Stop both motors
        pause(4);  % Wait for 4 seconds
        brick.MoveMotor('AB', -50);  % Move with small velocity
        pause(1);
    end

    % Check for black color to switch to autonomous mode
    if color == 1
        disp("Changing to autonomous mode");
        brick.StopMotor('AB');  % Stop both motors
        
        dis = brick.UltrasonicDist(3);  % Read ultrasonic sensor on port 3
        tt = brick.TouchPressed(1);  % Read touch sensor on port 1
        
        % Autonomous navigation logic
        if dis <= 65 && tt == 0  % Front is empty and parallel to left wall
            brick.MoveMotor('AB', -70);  % Move forward
        elseif dis <= 65 && tt == 1  % Front is blocked and parallel to left wall
            brick.MoveMotor('A', 50);  % Move backward slightly to make space
            brick.MoveMotor('B', 50);
            pause(1);

            brick.MoveMotor('B', 100);  % Turn right
            brick.MoveMotor('A', -100);
            pause(2.3);
            brick.StopMotor('AB');  % Stop both motors
        elseif dis > 65 && tt == 1  % Front is blocked and non-parallel to wall
            brick.MoveMotor('A', 50);  % Move backward slightly to make space
            brick.MoveMotor('B', 50);
            pause(1);
            
            brick.MoveMotor('B', -100);  % Turn left
            brick.MoveMotor('A', 100);
            pause(2.2);
            brick.StopMotor('AB');  % Stop both motors
            
            brick.MoveMotor('AB', -50);  % Move forward slightly to avoid double rotation
            pause(2);
            brick.StopMotor('AB');  % Stop both motors
        elseif dis > 65 && tt == 0  % Front is open and non-parallel to wall
            brick.MoveMotor('B', -100);  % Turn left
            brick.MoveMotor('A', 100);
            pause(2.2);
            
            brick.MoveMotor('AB', -50);  % Move backward slightly
            pause(2);
        end
    end
end
