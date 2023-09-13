function menuDeleteInsoleEvent_Callback(~, ~, h_line)
% hObject    handle to menuDeleteEvent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h_ine    handle to the line owning this menu

% update the handles.event_struct and any other lines with this tag in figures other 

% remove the event from the event_struct with the x data of this line

% get the app 
app_win = findobj('Name', 'Vicon Insole App');
if isempty(app_win)
	app_win = findwind('Vicon Insole App', 'Name');
end
assert(isa(app_win, 'matlab.ui.Figure'), 'did not find Vicon Insole App')
app = app_win.RunningAppInstance;

event = regexp(h_line.Tag, '_', 'split'); % splits the line tag into 'line', 'rhs', '2' 

a = app.event_struct.(event{2}).times;
if length(a) ~= length(unique(a))
	keyboard
end
% find the event by matching time
evt_ind = find(app.event_struct.(event{2}).times == h_line.XData(1));
assert(length(evt_ind)==1, 'error finding time = %f, in event_struct.%s', h_line.XData(1), event{2})

% remove the event from the struct
app.event_struct.(event{2}).times(evt_ind) = [];
app.event_struct.(event{2}).links(evt_ind) = [];
app.event_struct.(event{2}).line_num(evt_ind) = [];

% remove any lines with this tag in figures
h_all_lines = findobj(h_line.Parent.Parent, 'Tag', h_line.Tag);

delete(h_all_lines)

b = app.event_struct.(event{2}).times;
if length(b) ~= length(unique(b))
	keyboard
end

% update the HS or TO uitable
switch event{2}
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
		
