function update_hs_to_events(h_line)
% update the event_struct with the x data of this line

% get the app from h_line userdata
app = h_line.UserData.app;

event = regexp(h_line.Tag, '_', 'split'); % splits the line tag into 'line', 'rhs', '2' 

% get the index in the event struct for this line number
evt_ind = find(app.event_struct.(event{2}).line_num == str2double(event(3)));
assert(length(evt_ind) == 1, 'found %d evt_ind with line_num %d', length(evt_ind), str2double(event(3)))

app.event_struct.(event{2}).times(evt_ind) = h_line.XData(1);

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


