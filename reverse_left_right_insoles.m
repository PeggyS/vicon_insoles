function reverse_left_right_insoles(app)

% save copy of original data
app.vicon_data_unreversed = app.vicon_data;

% keyboard

old_var_names = app.vicon_data.devices.tbl.Properties.VariableNames;
new_var_names = old_var_names;

l_var_msk = contains(old_var_names, '_L_', 'IgnoreCase', true);
r_var_msk = contains(old_var_names, '_R_', 'IgnoreCase', true);

new_var_names(l_var_msk) = strrep(old_var_names(l_var_msk), '_L_', '_R_');
new_var_names(r_var_msk) = strrep(old_var_names(r_var_msk), '_R_', '_L_');

app.vicon_data.devices.tbl.Properties.VariableNames = new_var_names;
end