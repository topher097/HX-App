% Variables
BAUD            = 115200;
comPort         = 'COM6';
plotSeconds     = 30;
plotUpdateTime  = 0.5;
readVarCount    = 27;
readVarType     = "string";
sendVarCount    = 13;
sendVarType     = "double";
       
% Save configuration.mat file
save('configuration.mat', 'BAUD', 'comPort', 'plotSeconds', 'plotUpdateTime', 'readVarCount', ...
     'readVarType', 'sendVarCount', 'sendVarType', '-v7.3');
clc;
clear;
home;