clc; clear; home;
close all;

disp("Starting...");

% Declare vars
readVarCount = 24;          % number of variables to be read from serial
sendVarCount = 4;           % number of variables to be sent by serial
readVarType = "string";     % datatype of variables read from serial
sendVarType = "double";     % datatype of variables sent by serial
BAUD = 115200;              % baud rate of serial connection
load('comPort.mat');        % loads COM port last used, ex: "COM5"  

% Get user input for COM port to use
portsAvailable = serialportlist("available");       % Lists the available COM ports
setCOMPort = 0;
if ~(isempty(portsAvailable))
    disp("Ports available:");
    disp(portsAvailable);
    while ~(setCOMPort)
        prompt = strcat("Please input COM port to use (press enter to use last used: ", comPort, "): ");
        inputStr = input(prompt, 's');
        if ~(inputStr == "")
            if (any(strcmp(portsAvailable, inputStr)))
                comPort = inputStr;
                disp(strcat("Using ", comPort, " port for serial connection"));
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
%comPortFile = matfile('comPort.mat', 'Writable', true);
save comPort.mat comPort -v7.3;         % Save comPort variable for use next time
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
                         "inletFluidTemperature",[], ...
                         "frequency1",[], ...
                         "frequency2",[], ...
                         "amplitude1",[], ...
                         "amplitude2",[], ...
                         "phase1",[], ...
                         "phase2",[], ...
                         "enable1",[], ...
                         "enable2",[], ...
                         "endTesting",[]);

% Test GUI
DlgH = figure;
DlgH.Position = [1000 800 100 50]; % [x_pos y_pos height width]
H = uicontrol('Style', 'PushButton', ...
                    'String', 'Break', ...
                    'Callback', 'delete(gcbf)');
%disp("ready");
%while (ishandle(H))
while (ishandle(H))
    % Read data from master teensy via serial
    if (teensy.NumBytesAvailable > 0)
        data = str2double(split(readline(teensy), ","));
        disp(data);
        i = 1;
        teensy.UserData.Time(end+1)                     = data(i); i=i+1;
        teensy.UserData.inletPressureUpstream(end+1)    = data(i); i=i+1;
        teensy.UserData.inletPressureDownstream(end+1)  = data(i); i=i+1;
        teensy.UserData.outletPressureVapor(end+1)      = data(i); i=i+1;
        teensy.UserData.outletPressureLiquid(end+1)     = data(i); i=i+1;
        teensy.UserData.heaterTemperature1(end+1)       = data(i); i=i+1;
        teensy.UserData.heaterTemperature2(end+1)       = data(i); i=i+1;
        teensy.UserData.heaterTemperature3(end+1)       = data(i); i=i+1;
        teensy.UserData.heaterTemperature4(end+1)       = data(i); i=i+1;
        teensy.UserData.heaterTemperature5(end+1)       = data(i); i=i+1;
        teensy.UserData.boilSurfaceTemperature1(end+1)  = data(i); i=i+1;
        teensy.UserData.boilSurfaceTemperature2(end+1)  = data(i); i=i+1;
        teensy.UserData.boilSurfaceTemperature3(end+1)  = data(i); i=i+1;
        teensy.UserData.boilSurfaceTemperature4(end+1)  = data(i); i=i+1;
        teensy.UserData.averageBoilSurfaceTemp(end+1)   = data(i); i=i+1;
        teensy.UserData.inletFlowRate(end+1)            = data(i); i=i+1;
        teensy.UserData.inletFluidTemperature(end+1)    = data(i); i=i+1;
        teensy.UserData.frequency1(end+1)               = data(i); i=i+1;
        teensy.UserData.frequency2(end+1)               = data(i); i=i+1;
        teensy.UserData.amplitude1(end+1)               = data(i); i=i+1;
        teensy.UserData.amplitude2(end+1)               = data(i); i=i+1;
        teensy.UserData.phase1(end+1)                   = data(i); i=i+1;
        teensy.UserData.phase2(end+1)                   = data(i); i=i+1;
        teensy.UserData.enable1(end+1)                  = data(i); i=i+1;
        teensy.UserData.enable2(end+1)                  = data(i); i=i+1;
        teensy.UserData.endTesting(end+1)               = data(i); i=i+1;

        % Display data
        disp(data);
    end
    %disp(teensy.UserData);
end