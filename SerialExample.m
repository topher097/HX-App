clc;
clear;
home;

disp("Starting...");

% Declare vars
readVarCount = 17;          % number of variables to be read from serial
sendVarCount = 4;           % number of variables to be sent by serial
readVarType = "string";     % datatype of variables read from serial
sendVarType = "double";     % datatype of variables sent by serial
BAUD = 9600;                % baud rate of serial connection
comPort = "COM6";           % COM port used by teensy, may change depending on machine  

% Get user input for COM port to use
portsAvailable = serialportlist("available");       % Lists the available COM ports
setCOMPort = 0;
if ~(isempty(portsAvailable))
    disp("Ports available:");
    disp(portsAvailable);
    while ~(setCOMPort)
        prompt = strcat("Please input COM port to use (press enter to use default ", comPort, "): ");
        inputStr = input(prompt, 's');
        if ~(inputStr == "")
            if (any(strcmp(portsAvailable, inputStr)))
                comPort = inputStr;
                disp(strcat("Using", comPort, "port"));
                setCOMPort = 1;
            else
                disp("Invalid input, try again...")
            end
        else
            disp(strcat("Using ", comPort, " port for serial connection"));
            setCOMPort = 1;
        end
    end
else
    disp("No COM ports available, please connect device(s)");
    return;
end


% Set serial communcation object
teensy = serialport(comPort,BAUD);      % Create teensy object
configureTerminator(teensy, "CR/LF");   % Terminator set in teensy code
flush(teensy);                          % Flush serial bits
teensy.UserData = struct("Time",[], ...
                         "inletPressureUpstream",[], ...
                         "inletPressureDownstream",[], ...
                         "outletPressureVapor",[], ...
                         "outletPressureLiquid",[], ...
                         "heaterTemperature1",[], ...
                         "heaterTemperature2",[], ...
                         "heaterTemperature3",[], ...
                         "heaterTemperature4",[], ...
                         "heaterTemperature5",[], ...
                         "boilSurfaceTemperature1",[], ...
                         "boilSurfaceTemperature2",[], ...
                         "boilSurfaceTemperature3",[], ...
                         "boilSurfaceTemperature4",[], ...
                         "averageBoilSurfaceTemp",[], ...
                         "inletFlowRate",[], ...
                         "inletFluidTemperature",[]);

                     

% Test GUI
DlgH = figure;
DlgH.Position = [1000 800 100 50]; % [x_pos y_pos height width]
H = uicontrol('Style', 'PushButton', ...
                    'String', 'Break', ...
                    'Callback', 'delete(gcbf)');

while (ishandle(H))
    % Read data from master teensy via serial
    data = str2double(split(readline(teensy), ","));
    teensy.UserData.Time(end+1) = data(1);
    teensy.UserData.inletPressureUpstream(end+1) = data(2);
    teensy.UserData.inletPressureDownstream(end+1) = data(3);
    teensy.UserData.outletPressureVapor(end+1) = data(4);
    teensy.UserData.outletPressureLiquid(end+1) = data(5);
    teensy.UserData.heaterTemperature1(end+1) = data(6);
    teensy.UserData.heaterTemperature2(end+1) = data(7);
    teensy.UserData.heaterTemperature3(end+1) = data(8);
    teensy.UserData.heaterTemperature4(end+1) = data(9);
    teensy.UserData.heaterTemperature5(end+1) = data(10);
    teensy.UserData.boilSurfaceTemperature1(end+1) = data(11);
    teensy.UserData.boilSurfaceTemperature2(end+1) = data(12);
    teensy.UserData.boilSurfaceTemperature3(end+1) = data(13);
    teensy.UserData.boilSurfaceTemperature4(end+1) = data(14);
    teensy.UserData.averageBoilSurfaceTemp(end+1) = data(15);
    teensy.UserData.inletFlowRate(end+1) = data(16);
    teensy.UserData.inletFluidTemperature(end+1) = data(17);
    
    % Display data
    disp(data);
end