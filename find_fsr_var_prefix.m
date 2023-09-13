function var_prefix = find_fsr_var_prefix(tbl)
% FIND_FSR_VAR_PREFIX - find the variable name prefix for insole fsr channels
%
% variants of fsr variable prefix:
% Imported_Analog_EMG_#1_Voltage
% Imported_Analog_EMG_Voltage
% Analog_EMG_Voltage
% Analog_EMG_#1_Voltage
tmp = regexpi(tbl.Properties.VariableNames, '.*_emg_.*Voltage_', 'match');
matching_var_ind = find(~cellfun(@isempty, tmp), 1);
var_prefix = char(tmp{matching_var_ind});
return