function menuAddEvent_Callback(hObject, ~, h_ax)
% hObject    handle to menuDraggable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% hLine    handle to the axes owning this menu

% get left or right from axes tag
	if contains(h_ax.Tag, 'axes_l')
		side = 'l';
	else
		side = 'r';
	end

% get the app 
% get the app 
app_win = findobj('Name', 'Vicon Insole App');
if isempty(app_win)
	app_win = findwind('Vicon Insole App', 'Name');
end
assert(isa(app_win, 'matlab.ui.Figure'), 'did not find Vicon Insole App')
app = app_win.RunningAppInstance;

% all axes to add an event
h_ax_list = findobj(h_ax.Parent, 'Type', 'axes');

% x position to add the event is at cursor position
cursor_pos = get(h_ax, 'CurrentPoint');
evt_time = cursor_pos(1);

switch hObject.Tag
	case 'menuAddHS'
		evt_var = [side 'hs'];
		line_color = 'k';
	case 'menuAddTO'
		evt_var = [side 'to'];
		line_color = [0 0.8 0.1];
end

new_event_num = max(app.event_struct.(evt_var).line_num) + 1;
app.event_struct.(evt_var).times(end+1) = evt_time;

long_tag = ['line_' evt_var '_' num2str(new_event_num)];

% add the line to each axes
h_l = add_event_to_insole_axes(app, h_ax, h_ax_list, evt_time, line_color, long_tag);

% link the xdata
app.event_struct.(evt_var).links(end+1) = linkprop(h_l, 'XData');

% save the line number in the event_struct
app.event_struct.(evt_var).line_num(end+1) = new_event_num;


% update the HS or TO uitable
switch evt_var
	case 'lhs'
		tbl_var = 'LeftHs';
	case 'rhs'
		tbl_var = 'RightTo';
	case 'lto'
		tbl_var = 'LeftTo';
	case 'rto'
		tbl_var = 'RightTo';
end
update_evt_table(app, tbl_var)

return
