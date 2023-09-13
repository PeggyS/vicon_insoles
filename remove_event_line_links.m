function remove_event_line_links(h_fig)


app_win = findobj('Name', 'Vicon Insole App');
if isempty(app_win)
	app_win = findwind('Vicon Insole App', 'Name');
end
assert(isa(app_win, 'matlab.ui.Figure'), 'did not find Vicon Insole App')
app = app_win.RunningAppInstance;

side = lower(h_fig.Name(1));
evt_var = [side 'hs'];
if isfield(app.event_struct.(evt_var), 'links')
	app.event_struct.(evt_var) = rmfield(app.event_struct.(evt_var), 'links');
end
evt_var = [side 'to'];
if isfield(app.event_struct.(evt_var), 'links')
	app.event_struct.(evt_var) = rmfield(app.event_struct.(evt_var), 'links');
end
