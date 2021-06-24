classdef hxV1 < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        GridLayout                     matlab.ui.container.GridLayout
        LeftPanel                      matlab.ui.container.Panel
        Amplitude1                     matlab.ui.control.NumericEditField
        AmplitudeVEditFieldLabel       matlab.ui.control.Label
        Phase1                         matlab.ui.control.NumericEditField
        PhasedegEditFieldLabel         matlab.ui.control.Label
        Frequency1                     matlab.ui.control.NumericEditField
        FrequencyHzEditFieldLabel      matlab.ui.control.Label
        ConnectionSettingsPanel        matlab.ui.container.Panel
        Warning                        matlab.ui.control.Label
        UseDefaultConnectionSettingsCheckBox  matlab.ui.control.CheckBox
        ConnectButton                  matlab.ui.control.Button
        BaudrateDropDown               matlab.ui.control.DropDown
        BaudrateDropDownLabel          matlab.ui.control.Label
        COMPortDropDown                matlab.ui.control.DropDown
        COMPortDropDownLabel           matlab.ui.control.Label
        RefreshButton                  matlab.ui.control.Button
        StartStopSwitch                matlab.ui.control.Switch
        Label                          matlab.ui.control.Label
        RopeHeaterSwitch               matlab.ui.control.Switch
        RopeHeaterSwitchLabel          matlab.ui.control.Label
        HeaterSwitch                   matlab.ui.control.Switch
        HeaterModulesSwitchLabel       matlab.ui.control.Label
        InletFluidTemp                 matlab.ui.control.NumericEditField
        InletFluidTempCEditFieldLabel  matlab.ui.control.Label
        Amplitude2                     matlab.ui.control.NumericEditField
        AmplitudeVEditField_2Label     matlab.ui.control.Label
        Phase2                         matlab.ui.control.NumericEditField
        PhasedegEditField_2Label       matlab.ui.control.Label
        Frequency2                     matlab.ui.control.NumericEditField
        FrequencyHzEditField_2Label    matlab.ui.control.Label
        HeatFlux                       matlab.ui.control.NumericEditField
        HeatFluxWcm2EditFieldLabel     matlab.ui.control.Label
        Piezo2Switch                   matlab.ui.control.Switch
        Piezo2SwitchLabel              matlab.ui.control.Label
        Piezo1Switch                   matlab.ui.control.Switch
        Piezo1SwitchLabel              matlab.ui.control.Label
        UpdateTeensyButton             matlab.ui.control.Button
        TeensyUpdateAvailable          matlab.ui.control.Lamp
        HeaterControlsLabel            matlab.ui.control.Label
        Piezo2PropertiesLabel          matlab.ui.control.Label
        Piezo1PropertiesLabel          matlab.ui.control.Label
        CenterPanel                    matlab.ui.container.Panel
        outPressure                    matlab.ui.control.UIAxes
        flowRate                       matlab.ui.control.UIAxes
        bsTemp                         matlab.ui.control.UIAxes
        RightPanel                     matlab.ui.container.Panel
        InletFluidTempCGauge           matlab.ui.control.Gauge
        InletFluidTempCGaugeLabel      matlab.ui.control.Label
        DebugTextArea                  matlab.ui.control.TextArea
        DebugTextAreaLabel             matlab.ui.control.Label
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
        twoPanelWidth = 768;
    end


    properties (Access = private)
        variables           % object for variables used throughout app
        teensy              % Teensy object
        configuration       % variables from the configuration.mat file
        iTextBox            % Debug box line
        default             % Connection settings
        plotTimer           % Timer object to update plots at certain interval
    end
    
    methods (Access = private)    

        function initTeensy(app, comPort, baudRate)
            DisplayDebug(app, 'Start Teensy init');
            app.configuration.comPort       = comPort;
            app.configuration.BAUD          = baudRate;
            app.teensy = serialport(comPort, baudRate);     % Create teensy opject
            configureTerminator(app.teensy, "CR/LF");       % Terminator set in teensy code
            flush(app.teensy);                              % Flush serial bits
            app.Baudrate.Value              = baudRate;
            app.COMPort.Value               = comPort;
            DisplayDebug(app, 'Initiated Teensy obj');
            app.ConnectionSettingsPanel.BackgroundColor(0.94,0.94,0.94);        % Set background to grey once connected
        end

        function DisplayDebug(app, message)
            app.iTextBox = app.iTextBox + 1;
            app.DebugTextArea.Value(app.iTextBox) = {message};
        end

        function initDataAquisition(app)
            app.teensy.UserData = struct("Time",[], ...
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
                "enable2",[]);
        end

        function saveData(app)
            hi=1+3;
        end

        function sendDataTeensy(app)
            % Get current values for vars to send
            if (app.Piezo1Switch.Value == "On")
                app.variables.enable1 = 1;
            else
                app.variables.enable1 = 0;
            end
            if (app.Piezo2Switch.Value == "On")
                app.variables.enable2 = 1;
            else
                app.variables.enable2 = 0;
            end
            app.variables.frequency1        = app.Frequency1.Value;
            app.variables.amplitude1        = app.Amplitude1.Value;
            app.variables.phase1            = app.Phase1.Value;
            app.variables.frequency2        = app.Frequency2.Value;
            app.variables.amplitude2        = app.Amplitude2.Value;
            app.variables.phase2            = app.Phase2.Value;
            app.variables.heatFlux          = app.HeatFlux.Value;
            app.variables.inletFluidTemp    = app.InletFluidTemp.Value;
            if (app.HeaterSwitch.Value == "On")
                app.variables.enableHeaters = 1;
            else
                app.variables.enableHeaters = 0;
            end
            if (app.RopeHeaterSwitch.Value == "On")
                app.variables.enableRopeHeater = 1;
            else
                app.variables.enableRopeHeater = 0;
            end
            % Create list of variables to send to Teensy
            sendList         = [app.variables.enable1, ...
                app.variables.frequency1, ...
                app.variables.amplitude1, ...
                app.variables.phase1, ...
                app.variables.enable2, ...
                app.variables.frequency2, ...
                app.variables.amplitude2, ...
                app.variables.phase2, ...
                app.variables.heatFlux, ...
                app.variables.inletFluidTemp, ...
                app.variables.enableHeaters, ...
                app.variables.enableRopeHeater];
            % Construct string to send via serial
            sendString = "";
            for i=1:length(sendList)
                sendString = sendString + num2str(sendList(i));
            end
            sendString = sendString + "CR/LF";
            app.teensy.writeLine(sendString);       % Send string via serial
        end

        function runDataAquisition(app)
            firstData = true;
            while (app.StartStopSwitch.Value == "Start")
                if (app.teensy.NumBytesAvailable > 0)
                    data = str2double(split(readline(app.teensy), ","));
                    i = 1;
                    app.teensy.UserData.Time(end+1)                     = data(i); i=i+1;
                    app.teensy.UserData.inletPressureUpstream(end+1)    = data(i); i=i+1;
                    app.teensy.UserData.inletPressureDownstream(end+1)  = data(i); i=i+1;
                    app.teensy.UserData.outletPressureVapor(end+1)      = data(i); i=i+1;
                    app.teensy.UserData.outletPressureLiquid(end+1)     = data(i); i=i+1;
                    app.teensy.UserData.heatFlux(end+1)                 = data(i); i=i+1;
                    app.teensy.UserData.heaterTemperature1(end+1)       = data(i); i=i+1;
                    app.teensy.UserData.heaterTemperature2(end+1)       = data(i); i=i+1;
                    app.teensy.UserData.heaterTemperature3(end+1)       = data(i); i=i+1;
                    app.teensy.UserData.heaterTemperature4(end+1)       = data(i); i=i+1;
                    app.teensy.UserData.heaterTemperature5(end+1)       = data(i); i=i+1;
                    app.teensy.UserData.boilSurfaceTemperature1(end+1)  = data(i); i=i+1;
                    app.teensy.UserData.boilSurfaceTemperature2(end+1)  = data(i); i=i+1;
                    app.teensy.UserData.boilSurfaceTemperature3(end+1)  = data(i); i=i+1;
                    app.teensy.UserData.boilSurfaceTemperature4(end+1)  = data(i); i=i+1;
                    app.teensy.UserData.averageBoilSurfaceTemp(end+1)   = data(i); i=i+1;
                    app.teensy.UserData.inletFlowRate(end+1)            = data(i); i=i+1;
                    app.teensy.UserData.inletFluidTemperature(end+1)    = data(i); i=i+1;
                    app.teensy.UserData.frequency1(end+1)               = data(i); i=i+1;
                    app.teensy.UserData.frequency2(end+1)               = data(i); i=i+1;
                    app.teensy.UserData.amplitude1(end+1)               = data(i); i=i+1;
                    app.teensy.UserData.amplitude2(end+1)               = data(i); i=i+1;
                    app.teensy.UserData.phase1(end+1)                   = data(i); i=i+1;
                    app.teensy.UserData.phase2(end+1)                   = data(i); i=i+1;
                    app.teensy.UserData.enable1(end+1)                  = data(i); i=i+1;
                    app.teensy.UserData.enable2(end+1)                  = data(i); i=i+1;
                    app.teensy.UserData.endTesting(end+1)               = data(i);
                end

                % If first data, update values on UI
                if (firstData)
                    app.Piezo1Switch.Value          = app.teensy.UserData.enable1(end);
                    app.Frequency1.Value            = app.teensy.UserData.frequency1(end);
                    app.Amplitude1.Value            = app.teensy.UserData.amplitude1(end);
                    app.Phase1.Value                = app.teensy.UserData.phase1(end);
                    app.Piezo2Switch.Value          = app.teensy.UserData.enable2(end);
                    app.Frequency2.Value            = app.teensy.UserData.frequency2(end);
                    app.Amplitude2.Value            = app.teensy.UserData.amplitude2(end);
                    app.Phase2.Value                = app.teensy.UserData.phase2(end);
                    app.HeatFlux.Value              = app.teensy.UserData.heatFlux(end);
                    app.InletFluidTemp.Value        = app.teensy.UserData.inletFluidTemperature(end);
                    app.TeensyUpdateAvailable.Color(0,1,0);
                    firstData = false;
                end
            end
        end

        function updatePlots(app, ~, event)
            % Outlet pressure plot
            %outPressureAxes = axes(app.outPressure.Children);
            %app.outPressure.a
            disp("update plot");
        end

        function getSerialPortList(app)
            disp("serial");
            DisplayDebug(app, 'Fetching connect settings');
            serialPortList = serialportlist("available");
            list = ["Select"]; %#ok<NBRAK>
            for i=1:length(serialPortList)
                list(end+1) = serialPortList(i); %#ok<AGROW>
            end
            app.configuration.comList = list;
            app.BaudrateDropDown.Items    = ["Select", "1200", "2400", "4800", "9600", "19200", "38400", "57600", "115200"];
            app.COMPortDropDown.Items     = app.configuration.comList;
            DisplayDebug(app, 'Fetched connect settings');
        end

    end



    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            clear; close all; clc; home;
            app.iTextBox = 0;
            mess = "hello";
            %message = returnMessage(app, mess);
            disp(mess);

            % Load the last variables saved in the configuration.mat file
            load configuration.mat BAUD comPort plotSeconds plotUpdateTime readVarCount readVarType sendVarCount sendVarType;
            % Save the variables from configuration.mat in the  
            % configuration property
            app.configuration.comPort           = comPort;
            app.configuration.BAUD              = BAUD;
            app.configuration.readVarCount      = readVarCount;
            app.configuration.sendVarCount      = sendVarCount;
            app.configuration.readVarType       = readVarType;
            app.configuration.sendVarType       = sendVarType;
            app.configuration.plotSeconds       = plotSeconds;        %seconds
            app.configuration.plotUpdateTime    = plotUpdateTime;     %seconds
            
            % Create timer object for updating plots
            app.plotTimer = timer(...
            'ExecutionMode', 'fixedRate', ...      % Run timer repeatedly
            'Period', 5, ...                       % Period is 5 seconds
            'BusyMode', 'queue',...                % Queue timer callbacks when busy
            'TimerFcn', @app.updatePlots);         % Callback that runs every period
                        
            % Set background of COM port options to red
            app.ConnectionSettingsPanel.BackgroundColor = [0.95 0.39 0.39];
            % Get and udpate the COM port options for the drop down lists
            getSerialPortList(app);
            %DisplayDebug(app, 'test');
            initTeensy(app, A.comPort, A.BAUD);


        end

        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
            currentFigureWidth = app.UIFigure.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 3x1 grid
                app.GridLayout.RowHeight = {692, 692, 692};
                app.GridLayout.ColumnWidth = {'1x'};
                app.CenterPanel.Layout.Row = 1;
                app.CenterPanel.Layout.Column = 1;
                app.LeftPanel.Layout.Row = 2;
                app.LeftPanel.Layout.Column = 1;
                app.RightPanel.Layout.Row = 3;
                app.RightPanel.Layout.Column = 1;
            elseif (currentFigureWidth > app.onePanelWidth && currentFigureWidth <= app.twoPanelWidth)
                % Change to a 2x2 grid
                app.GridLayout.RowHeight = {692, 692};
                app.GridLayout.ColumnWidth = {'1x', '1x'};
                app.CenterPanel.Layout.Row = 1;
                app.CenterPanel.Layout.Column = [1,2];
                app.LeftPanel.Layout.Row = 2;
                app.LeftPanel.Layout.Column = 1;
                app.RightPanel.Layout.Row = 2;
                app.RightPanel.Layout.Column = 2;
            else
                % Change to a 1x3 grid
                app.GridLayout.RowHeight = {'1x'};
                app.GridLayout.ColumnWidth = {267, '1x', 303};
                app.LeftPanel.Layout.Row = 1;
                app.LeftPanel.Layout.Column = 1;
                app.CenterPanel.Layout.Row = 1;
                app.CenterPanel.Layout.Column = 2;
                app.RightPanel.Layout.Row = 1;
                app.RightPanel.Layout.Column = 3;
            end
        end

        % Value changed function: Frequency1
        function Frequency1ValueChanged(app, event)
            app.TeensyUpdateAvailable.Color = [1,0,0];         % Change update lamp to red
        end

        % Value changed function: Frequency2
        function Frequency2ValueChanged(app, event)
            app.TeensyUpdateAvailable.Color = [1,0,0];         % Change update lamp to red
        end

        % Value changed function: Piezo1Switch
        function Piezo1SwitchValueChanged(app, event)
            app.TeensyUpdateAvailable.Color = [1,0,0];         % Change update lamp to red
        end

        % Value changed function: Piezo2Switch
        function Piezo2SwitchValueChanged(app, event)
            app.TeensyUpdateAvailable.Color = [1,0,0];         % Change update lamp to red
        end

        % Value changed function: Phase1
        function Phase1ValueChanged(app, event)
            app.TeensyUpdateAvailable.Color = [1,0,0];         % Change update lamp to red
        end

        % Value changed function: Phase2
        function Phase2ValueChanged(app, event)
            app.TeensyUpdateAvailable.Color = [1,0,0];         % Change update lamp to red
        end

        % Value changed function: Amplitude1
        function Amplitude1ValueChanged(app, event)
            app.TeensyUpdateAvailable.Color = [1,0,0];         % Change update lamp to red
        end

        % Value changed function: Amplitude2
        function Amplitude2ValueChanged(app, event)
            app.TeensyUpdateAvailable.Color = [1,0,0];         % Change update lamp to red
        end

        % Value changed function: HeatFlux
        function HeatFluxValueChanged(app, event)
            app.TeensyUpdateAvailable.Color = [1,0,0];         % Change update lamp to red
        end

        % Value changed function: InletFluidTemp
        function InletFluidTempValueChanged(app, event)
            app.TeensyUpdateAvailable.Color = [1,0,0];         % Change update lamp to red
        end

        % Value changed function: HeaterSwitch
        function HeaterSwitchValueChanged(app, event)
            app.TeensyUpdateAvailable.Color = [1,0,0];         % Change update lamp to red
        end

        % Value changed function: RopeHeaterSwitch
        function RopeHeaterSwitchValueChanged(app, event)
            app.TeensyUpdateAvailable.Color = [1,0,0];         % Change update lamp to red
        end

        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)
            % Stop the timer for plot update if it's on
            try
                if strcmp(app.plotTimer.Running, 'on')
                    stop(app.plotTimer);
                end 
            catch error
                disp(error);
            end
            % Close app
            delete(app)
        end

        % Value changed function: StartStopSwitch
        function StartStopSwitchValueChanged(app, event)
            value = app.StartStopSwitch.Value;
            if (value == "Start")
                % Create file name for test
                app.variables.fileName = append('HX1_', datestr(now,'mm-dd-yy__HH_MM_SS.FFF'));
                % Start the timer for plot update
                if strcmp(app.plotTimer.Running, 'off')
                    start(app.plotTimer);
                end
                % Start the data aquisistion
                DisplayDebug(app, 'Starting data aquisition');
                runDataAquisition(app);
            else
                % Stop the timer for plot update
                stop(app.plotTimer);
                % Save the data
                DisplayDebug(app, 'Stopping and saving data');
                saveData(app);
                % Re-Initiate the data struct
                initDataAquisition(app);
                DisplayDebug(app, 'Reset data struct');
            end
        end

        % Button pushed function: UpdateTeensyButton
        function UpdateTeensyButtonPushed(app, event)
            DisplayDebug(app, 'Pushing data to Teensy');
            sendDataTeensy(app);                            % Update the teensy with current values
            DisplayDebug(app, 'Pushed data to Teensy');
            app.TeensyUpdateAvailable.Color = [0,1,0];         % Change update lamp to green
        end

        % Button pushed function: ConnectButton
        function ConnectButtonPushed(app, event)
            % Check if the variables are valid
            comPort = app.COMPortDropDown.Value;
            baudRate = app.BaudrateDropDown.Value;
            goodComPort = false;
            goodBaudRate = false;

            if (any(strcmp(app.configuration.comList, comPort)))
                goodComPort = true;
            end
            if ~(strcmp("Select", baudRate))
                goodBaudRate = true;
                baudRate = str2num(baudRate); %#ok<ST2NM>
            end

            % Send data to the main app if good
            if (goodComPort && goodBaudRate)
                initTeensy(app, comPort, baudRate);
            else
                app.Warning.Visible = 1;
                app.Warning.Text = "Given inputs are not legal, please select legal values";
            end
        end

        % Value changed function: 
        % UseDefaultConnectionSettingsCheckBox
        function UseDefaultConnectionSettingsCheckBoxValueChanged(app, event)
            value = app.UseDefaultConnectionSettingsCheckBox.Value;
            if value == 1
                % Check if the default COM port is in current list, if not dispaly error
                comPort = app.configuration.comPort;
                if ~(any(strcmp(app.configuration.comList, comPort)))
                    app.Warning.Text = "Default COM port is not available";
                    app.UseDefaultConnectionSettingsCheckBox = 0;
                else
                    app.BaudrateDropDown.Value    = app.configuration.BAUD;
                    app.COMPortDropDown.Value     = app.configuration.comPort;
                    app.Warning.Visible           = 0;
                end
            else
                getSerialPortList(app);
                app.BaudrateDropDown.Items    = ["Select", "1200", "2400", "4800", "9600", "19200", "38400", "57600", "115200"];
                app.COMPortDropDown.Items     = app.configuration.comList;
                app.BaudrateDropDown.Value    = "Select";
                app.COMPortDropDown.Value     = "Select";
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Position = [100 100 1423 692];
            app.UIFigure.Name = 'UI Figure';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {267, '1x', 303};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Scrollable = 'on';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;

            % Create Piezo1PropertiesLabel
            app.Piezo1PropertiesLabel = uilabel(app.LeftPanel);
            app.Piezo1PropertiesLabel.FontSize = 16;
            app.Piezo1PropertiesLabel.FontWeight = 'bold';
            app.Piezo1PropertiesLabel.Position = [58 621 144 22];
            app.Piezo1PropertiesLabel.Text = 'Piezo 1 Properties';

            % Create Piezo2PropertiesLabel
            app.Piezo2PropertiesLabel = uilabel(app.LeftPanel);
            app.Piezo2PropertiesLabel.FontSize = 16;
            app.Piezo2PropertiesLabel.FontWeight = 'bold';
            app.Piezo2PropertiesLabel.Position = [59 518 144 22];
            app.Piezo2PropertiesLabel.Text = 'Piezo 2 Properties';

            % Create HeaterControlsLabel
            app.HeaterControlsLabel = uilabel(app.LeftPanel);
            app.HeaterControlsLabel.HorizontalAlignment = 'center';
            app.HeaterControlsLabel.FontSize = 16;
            app.HeaterControlsLabel.FontWeight = 'bold';
            app.HeaterControlsLabel.Position = [65 352 126 22];
            app.HeaterControlsLabel.Text = 'Heater Controls';

            % Create TeensyUpdateAvailable
            app.TeensyUpdateAvailable = uilamp(app.LeftPanel);
            app.TeensyUpdateAvailable.Position = [188 210 20 20];

            % Create UpdateTeensyButton
            app.UpdateTeensyButton = uibutton(app.LeftPanel, 'push');
            app.UpdateTeensyButton.ButtonPushedFcn = createCallbackFcn(app, @UpdateTeensyButtonPushed, true);
            app.UpdateTeensyButton.FontSize = 16;
            app.UpdateTeensyButton.FontWeight = 'bold';
            app.UpdateTeensyButton.Position = [47 207 128 26];
            app.UpdateTeensyButton.Text = 'Update Teensy';

            % Create Piezo1SwitchLabel
            app.Piezo1SwitchLabel = uilabel(app.LeftPanel);
            app.Piezo1SwitchLabel.HorizontalAlignment = 'center';
            app.Piezo1SwitchLabel.Position = [50 378 46 22];
            app.Piezo1SwitchLabel.Text = 'Piezo 1';

            % Create Piezo1Switch
            app.Piezo1Switch = uiswitch(app.LeftPanel, 'slider');
            app.Piezo1Switch.ValueChangedFcn = createCallbackFcn(app, @Piezo1SwitchValueChanged, true);
            app.Piezo1Switch.Position = [49 412 45 20];

            % Create Piezo2SwitchLabel
            app.Piezo2SwitchLabel = uilabel(app.LeftPanel);
            app.Piezo2SwitchLabel.HorizontalAlignment = 'center';
            app.Piezo2SwitchLabel.Position = [167 378 46 22];
            app.Piezo2SwitchLabel.Text = 'Piezo 2';

            % Create Piezo2Switch
            app.Piezo2Switch = uiswitch(app.LeftPanel, 'slider');
            app.Piezo2Switch.ValueChangedFcn = createCallbackFcn(app, @Piezo2SwitchValueChanged, true);
            app.Piezo2Switch.Position = [166 412 45 20];

            % Create HeatFluxWcm2EditFieldLabel
            app.HeatFluxWcm2EditFieldLabel = uilabel(app.LeftPanel);
            app.HeatFluxWcm2EditFieldLabel.Position = [26 330 114 22];
            app.HeatFluxWcm2EditFieldLabel.Text = 'Heat Flux (W/cm^2)';

            % Create HeatFlux
            app.HeatFlux = uieditfield(app.LeftPanel, 'numeric');
            app.HeatFlux.ValueChangedFcn = createCallbackFcn(app, @HeatFluxValueChanged, true);
            app.HeatFlux.Position = [150 330 85 22];

            % Create FrequencyHzEditField_2Label
            app.FrequencyHzEditField_2Label = uilabel(app.LeftPanel);
            app.FrequencyHzEditField_2Label.HorizontalAlignment = 'right';
            app.FrequencyHzEditField_2Label.Position = [22 497 88 22];
            app.FrequencyHzEditField_2Label.Text = {'Frequency (Hz)'; ''};

            % Create Frequency2
            app.Frequency2 = uieditfield(app.LeftPanel, 'numeric');
            app.Frequency2.ValueChangedFcn = createCallbackFcn(app, @Frequency2ValueChanged, true);
            app.Frequency2.Position = [151 497 83 22];

            % Create PhasedegEditField_2Label
            app.PhasedegEditField_2Label = uilabel(app.LeftPanel);
            app.PhasedegEditField_2Label.Position = [27 471 113 22];
            app.PhasedegEditField_2Label.Text = {'Phase (deg)'; ''};

            % Create Phase2
            app.Phase2 = uieditfield(app.LeftPanel, 'numeric');
            app.Phase2.ValueChangedFcn = createCallbackFcn(app, @Phase2ValueChanged, true);
            app.Phase2.Position = [151 471 83 22];

            % Create AmplitudeVEditField_2Label
            app.AmplitudeVEditField_2Label = uilabel(app.LeftPanel);
            app.AmplitudeVEditField_2Label.Position = [27 445 113 22];
            app.AmplitudeVEditField_2Label.Text = 'Amplitude (V)';

            % Create Amplitude2
            app.Amplitude2 = uieditfield(app.LeftPanel, 'numeric');
            app.Amplitude2.ValueChangedFcn = createCallbackFcn(app, @Amplitude2ValueChanged, true);
            app.Amplitude2.Position = [151 445 83 22];

            % Create InletFluidTempCEditFieldLabel
            app.InletFluidTempCEditFieldLabel = uilabel(app.LeftPanel);
            app.InletFluidTempCEditFieldLabel.Position = [26 304 114 22];
            app.InletFluidTempCEditFieldLabel.Text = 'Inlet Fluid Temp (C)';

            % Create InletFluidTemp
            app.InletFluidTemp = uieditfield(app.LeftPanel, 'numeric');
            app.InletFluidTemp.ValueChangedFcn = createCallbackFcn(app, @InletFluidTempValueChanged, true);
            app.InletFluidTemp.Position = [150 304 85 22];

            % Create HeaterModulesSwitchLabel
            app.HeaterModulesSwitchLabel = uilabel(app.LeftPanel);
            app.HeaterModulesSwitchLabel.HorizontalAlignment = 'center';
            app.HeaterModulesSwitchLabel.Position = [29 235 90 22];
            app.HeaterModulesSwitchLabel.Text = 'Heater Modules';

            % Create HeaterSwitch
            app.HeaterSwitch = uiswitch(app.LeftPanel, 'slider');
            app.HeaterSwitch.ValueChangedFcn = createCallbackFcn(app, @HeaterSwitchValueChanged, true);
            app.HeaterSwitch.Position = [50 272 45 20];

            % Create RopeHeaterSwitchLabel
            app.RopeHeaterSwitchLabel = uilabel(app.LeftPanel);
            app.RopeHeaterSwitchLabel.HorizontalAlignment = 'center';
            app.RopeHeaterSwitchLabel.Position = [154 235 74 22];
            app.RopeHeaterSwitchLabel.Text = 'Rope Heater';

            % Create RopeHeaterSwitch
            app.RopeHeaterSwitch = uiswitch(app.LeftPanel, 'slider');
            app.RopeHeaterSwitch.ValueChangedFcn = createCallbackFcn(app, @RopeHeaterSwitchValueChanged, true);
            app.RopeHeaterSwitch.Position = [167 272 45 20];

            % Create Label
            app.Label = uilabel(app.LeftPanel);
            app.Label.HorizontalAlignment = 'center';
            app.Label.Position = [143 621 25 22];
            app.Label.Text = '';

            % Create StartStopSwitch
            app.StartStopSwitch = uiswitch(app.LeftPanel, 'slider');
            app.StartStopSwitch.Items = {'Stop & Save', 'Start'};
            app.StartStopSwitch.ValueChangedFcn = createCallbackFcn(app, @StartStopSwitchValueChanged, true);
            app.StartStopSwitch.Position = [125 654 45 20];
            app.StartStopSwitch.Value = 'Stop & Save';

            % Create ConnectionSettingsPanel
            app.ConnectionSettingsPanel = uipanel(app.LeftPanel);
            app.ConnectionSettingsPanel.TitlePosition = 'centertop';
            app.ConnectionSettingsPanel.Title = 'Connection Settings';
            app.ConnectionSettingsPanel.BackgroundColor = [0.9412 0.9412 0.9412];
            app.ConnectionSettingsPanel.FontWeight = 'bold';
            app.ConnectionSettingsPanel.FontSize = 16;
            app.ConnectionSettingsPanel.Position = [11 10 246 187];

            % Create RefreshButton
            app.RefreshButton = uibutton(app.ConnectionSettingsPanel, 'push');
            app.RefreshButton.Position = [5 46 100 22];
            app.RefreshButton.Text = 'Refresh';

            % Create COMPortDropDownLabel
            app.COMPortDropDownLabel = uilabel(app.ConnectionSettingsPanel);
            app.COMPortDropDownLabel.HorizontalAlignment = 'right';
            app.COMPortDropDownLabel.Position = [36 134 59 22];
            app.COMPortDropDownLabel.Text = 'COM Port';

            % Create COMPortDropDown
            app.COMPortDropDown = uidropdown(app.ConnectionSettingsPanel);
            app.COMPortDropDown.Position = [110 134 100 22];

            % Create BaudrateDropDownLabel
            app.BaudrateDropDownLabel = uilabel(app.ConnectionSettingsPanel);
            app.BaudrateDropDownLabel.HorizontalAlignment = 'right';
            app.BaudrateDropDownLabel.Position = [41 108 54 22];
            app.BaudrateDropDownLabel.Text = 'Baudrate';

            % Create BaudrateDropDown
            app.BaudrateDropDown = uidropdown(app.ConnectionSettingsPanel);
            app.BaudrateDropDown.Position = [110 108 100 22];

            % Create ConnectButton
            app.ConnectButton = uibutton(app.ConnectionSettingsPanel, 'push');
            app.ConnectButton.ButtonPushedFcn = createCallbackFcn(app, @ConnectButtonPushed, true);
            app.ConnectButton.Position = [120 46 121 22];
            app.ConnectButton.Text = 'Connect';

            % Create UseDefaultConnectionSettingsCheckBox
            app.UseDefaultConnectionSettingsCheckBox = uicheckbox(app.ConnectionSettingsPanel);
            app.UseDefaultConnectionSettingsCheckBox.ValueChangedFcn = createCallbackFcn(app, @UseDefaultConnectionSettingsCheckBoxValueChanged, true);
            app.UseDefaultConnectionSettingsCheckBox.Text = 'Use Default Connection Settings';
            app.UseDefaultConnectionSettingsCheckBox.Position = [10 79 196 22];

            % Create Warning
            app.Warning = uilabel(app.ConnectionSettingsPanel);
            app.Warning.Position = [10 3 226 36];
            app.Warning.Text = '';

            % Create FrequencyHzEditFieldLabel
            app.FrequencyHzEditFieldLabel = uilabel(app.LeftPanel);
            app.FrequencyHzEditFieldLabel.HorizontalAlignment = 'right';
            app.FrequencyHzEditFieldLabel.Position = [21 600 88 22];
            app.FrequencyHzEditFieldLabel.Text = {'Frequency (Hz)'; ''};

            % Create Frequency1
            app.Frequency1 = uieditfield(app.LeftPanel, 'numeric');
            app.Frequency1.ValueChangedFcn = createCallbackFcn(app, @Frequency1ValueChanged, true);
            app.Frequency1.Position = [150 600 83 22];

            % Create PhasedegEditFieldLabel
            app.PhasedegEditFieldLabel = uilabel(app.LeftPanel);
            app.PhasedegEditFieldLabel.Position = [26 574 113 22];
            app.PhasedegEditFieldLabel.Text = {'Phase (deg)'; ''};

            % Create Phase1
            app.Phase1 = uieditfield(app.LeftPanel, 'numeric');
            app.Phase1.ValueChangedFcn = createCallbackFcn(app, @Phase1ValueChanged, true);
            app.Phase1.Position = [150 574 83 22];

            % Create AmplitudeVEditFieldLabel
            app.AmplitudeVEditFieldLabel = uilabel(app.LeftPanel);
            app.AmplitudeVEditFieldLabel.Position = [26 548 113 22];
            app.AmplitudeVEditFieldLabel.Text = 'Amplitude (V)';

            % Create Amplitude1
            app.Amplitude1 = uieditfield(app.LeftPanel, 'numeric');
            app.Amplitude1.ValueChangedFcn = createCallbackFcn(app, @Amplitude1ValueChanged, true);
            app.Amplitude1.Position = [150 548 83 22];

            % Create CenterPanel
            app.CenterPanel = uipanel(app.GridLayout);
            app.CenterPanel.Layout.Row = 1;
            app.CenterPanel.Layout.Column = 2;

            % Create bsTemp
            app.bsTemp = uiaxes(app.CenterPanel);
            title(app.bsTemp, 'Boil Surface Temp')
            xlabel(app.bsTemp, 'Time (s)')
            ylabel(app.bsTemp, 'Temperature (C)')
            app.bsTemp.XGrid = 'on';
            app.bsTemp.YGrid = 'on';
            app.bsTemp.FontSize = 10;
            app.bsTemp.Position = [7 488 812 195];

            % Create flowRate
            app.flowRate = uiaxes(app.CenterPanel);
            title(app.flowRate, 'Flow Rate')
            xlabel(app.flowRate, 'Time (s)')
            ylabel(app.flowRate, 'Instantaneous Flow Rate (mL/min)')
            app.flowRate.XGrid = 'on';
            app.flowRate.YGrid = 'on';
            app.flowRate.FontSize = 10;
            app.flowRate.Position = [7 274 812 201];

            % Create outPressure
            app.outPressure = uiaxes(app.CenterPanel);
            title(app.outPressure, 'Outlet Pressure')
            xlabel(app.outPressure, 'Time (s)')
            ylabel(app.outPressure, 'Pressure (psia)')
            app.outPressure.XGrid = 'on';
            app.outPressure.YGrid = 'on';
            app.outPressure.FontSize = 10;
            app.outPressure.Position = [8 72 810 185];

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 3;

            % Create DebugTextAreaLabel
            app.DebugTextAreaLabel = uilabel(app.RightPanel);
            app.DebugTextAreaLabel.HorizontalAlignment = 'center';
            app.DebugTextAreaLabel.Position = [132 296 41 22];
            app.DebugTextAreaLabel.Text = 'Debug';

            % Create DebugTextArea
            app.DebugTextArea = uitextarea(app.RightPanel);
            app.DebugTextArea.Position = [8 10 289 285];

            % Create InletFluidTempCGaugeLabel
            app.InletFluidTempCGaugeLabel = uilabel(app.RightPanel);
            app.InletFluidTempCGaugeLabel.HorizontalAlignment = 'center';
            app.InletFluidTempCGaugeLabel.FontWeight = 'bold';
            app.InletFluidTempCGaugeLabel.Position = [13 533 120 22];
            app.InletFluidTempCGaugeLabel.Text = 'Inlet Fluid Temp. (C)';

            % Create InletFluidTempCGauge
            app.InletFluidTempCGauge = uigauge(app.RightPanel, 'circular');
            app.InletFluidTempCGauge.Limits = [30 70];
            app.InletFluidTempCGauge.Position = [12 560 120 120];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = hxV1

            runningApp = getRunningApp(app);

            % Check for running singleton app
            if isempty(runningApp)

                % Create UIFigure and components
                createComponents(app)

                % Register the app with App Designer
                registerApp(app, app.UIFigure)

                % Execute the startup function
                runStartupFcn(app, @startupFcn)
            else

                % Focus the running singleton app
                figure(runningApp.UIFigure)

                app = runningApp;
            end

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end