function update_evt_table(app, evt_table)
if app.BlockNumberEditField.Value > 0
	if app.table_walk_num>0 && ~isempty(app.event_struct)
		label_var = ['Num' evt_table 'Label'];
		evt_var = [lower(evt_table(1)) lower(evt_table(end-1:end))];
		
		vicon_start = app.eeg_events.vicon_start(app.BlockNumberEditField.Value);
		vicon_stop  = app.eeg_events.vicon_stop(app.BlockNumberEditField.Value);
		walk_event_msk = app.eeg_events.walk > vicon_start & app.eeg_events.walk < vicon_stop;
		turn_event_msk = app.eeg_events.turn_stop > vicon_start & app.eeg_events.turn_stop < vicon_stop;
		
		walk_events_rel_to_vicon = app.eeg_events.walk(walk_event_msk) - vicon_start;
		turn_events_rel_to_vicon = app.eeg_events.turn_stop(turn_event_msk) - vicon_start;
		
		hs_to_evt_msk = app.event_struct.(evt_var).times >= walk_events_rel_to_vicon(app.table_walk_num) & ...
			app.event_struct.(evt_var).times <= turn_events_rel_to_vicon(app.table_walk_num);
		events = app.event_struct.(evt_var).times(hs_to_evt_msk);
		
		% make sure events is a column
		if size(events,1) < size(events,2)
			events = events';
		end
		
		num_events = length(events);
		
		
		app.(label_var).Text = num2str(num_events);
		
		table_var = strrep(label_var, 'Num', 'UITable');
		table_var = strrep(table_var, 'Label', '');
		
		app.(table_var).Data = round(sort(events), 2);
	end
end