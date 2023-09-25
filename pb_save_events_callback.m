function pb_save_events_callback(~, ~, h_fig, app)

% % get the app 
% app_win = findobj('Name', 'Vicon Insole App');
% if isempty(app_win)
% 	app_win = findwind('Vicon Insole App', 'Name');
% end
% assert(isa(app_win, 'matlab.ui.Figure'), 'did not find Vicon Insole App')
% 
% app = app_win.RunningAppInstance;

name_split = strsplit(lower(h_fig.Name));
side = name_split{1}(1);

vicon_fname = app.EditFieldViconFilename.Value;

% vicon heel strike & toe off events
evt_list = {'hs' 'to'};
for e_cnt = 1:length(evt_list)
	evt = evt_list{e_cnt};
	
	save_filename = get_event_file(vicon_fname, side, evt, 'write');
	if isempty(save_filename)
		disp(['No ' side evt ' events being saved'])
	else 
		
		% create a table with the hs or to events for this side
		evt_var = [side(1) evt];
		if size(app.event_struct.(evt_var).times,1) < size(app.event_struct.(evt_var).times,2)
			tmp = app.event_struct.(evt_var).times';
		else
			tmp = app.event_struct.(evt_var).times;
		end
		tbl = table(tmp, 'VariableNames', {'time'});
		out_tbl = sortrows(tbl, 'time');
		
		% save the event table
		writetable(out_tbl, save_filename);

		% check the box in the app - showing hs or to events are now present/saved
		chkbox_var = [upper(evt) 'CheckBox'];
		app.(chkbox_var).Value = 1;
	end
	
end % hs & to events

% eeg events relative to vicon start time = 0
if ~isempty(app.eeg_events)
	eeg_fname = app.EditFieldEegFilename.Value;
	event_filename = get_nirs_event_file(eeg_fname, 'write');
	if isempty(event_filename)
		disp('No eeg events being saved')
	else
		write_struct(event_filename, app.eeg_events)
	end
end

