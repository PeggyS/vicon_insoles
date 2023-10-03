function thresh_line_endfcn(h_line)

% update the threshold edit box with the new value of the dragged line
ed_obj = findobj(h_line.Parent.Parent, 'Tag', 'threshold_edit');
ed_obj.String = num2str(h_line.YData(1));


% get the app
app_win = findobj('Name', 'Vicon Insole App');
if isempty(app_win)
	app_win = findwind('Vicon Insole App', 'Name');
end
assert(isa(app_win, 'matlab.ui.Figure'), 'did not find Vicon Insole App')
app = app_win.RunningAppInstance;

% save the value in a struct for saving
if contains(h_line.Parent.Tag, '_l_')
	side_str = 'left';
else
	side_str = 'right';
end
app.fsr_event_threshold_struct.(side_str) = h_line.YData(1);

% use the threshold_edit callback to update the events and lines
edit_threshold_callback(ed_obj, [], 'composite', [])