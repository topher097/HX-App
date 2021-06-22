% Variables
BAUD            = 115200;
comPort         = 'COM6';
plotSeconds     = 20;
readVarCount    = 25;
readVarType     = "string";
sendVarCount    = 12;
sendVarType     = "double";
       
% Save configuration.mat file
save('configuration.mat', 'BAUD', 'comPort', 'plotSeconds', 'readVarCount', ...
     'readVarType', 'sendVarCount', 'sendVarType', '-v7.3');
clc;
clear;
home;