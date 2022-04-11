load configuration.mat

% Variables
BAUD            = 115200;
comPort         = 'COM6';
plotSeconds     = 30;
plotUpdateTime  = 1.0;
readVarCount    = 30;
readVarType     = "string";
sendVarCount    = 13;
sendVarType     = "double";
       
% Save configuration.mat file
save('configuration.mat', 'BAUD', 'comPort', 'plotSeconds', 'plotUpdateTime', 'readVarCount', ...
     'readVarType', 'sendVarCount', 'sendVarType', '-v7.3');
Kp = 1;
Kd = 0.5;
Ki = 0;
save('PIDvalues.mat', 'Kp', 'Ki', 'Kd', '-V7.3');

clc;
clear;
home;
