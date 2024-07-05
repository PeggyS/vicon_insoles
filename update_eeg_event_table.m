function update_eeg_event_table(app)


% app.UITableEegEvents.Data = app.eeg_events

block_num = app.BlockNumberEditField.Value;
if block_num > 0 && block_num <= length(app.eeg_events.vicon_start)
	
	vicon_start = app.eeg_events.vicon_start(block_num);
	vicon_stop = app.eeg_events.vicon_stop(block_num);
	try 
		walk_event_msk = app.eeg_events.walk > vicon_start & app.eeg_events.walk < vicon_stop;
		turn_event_msk = app.eeg_events.turn_stop > vicon_start & app.eeg_events.turn_stop < vicon_stop;
		rest_event_msk = app.eeg_events.rest > vicon_start & app.eeg_events.rest < vicon_stop;
	catch ME
		beep
		disp(ME)
	end
	
	assert(sum(walk_event_msk)>0, 'No walk events')
	
	% data to display in eeg event table
	data = nan(sum(walk_event_msk),4);
	
	b_num = 1:sum(walk_event_msk); % walk number
	data(:,1) = b_num';
	data(:,2) = app.eeg_events.walk(walk_event_msk)' - vicon_start;
	if sum(turn_event_msk)>0
		data(:,3) = app.eeg_events.turn_stop(turn_event_msk)' - vicon_start;
	end
	if sum(rest_event_msk)>0
		try
			data(:,4) = app.eeg_events.rest(rest_event_msk)' - vicon_start;
		catch ME1
% 			keyboard
			% Get last segment of the error identifier.
			idSegLast = regexp(ME1.identifier,'(?<=:)\w+$','match');
			if contains(idSegLast, 'subsassigndimmismatch')
				% guess that the number of rest events is less than the number of turn_stop and walk events
				tmp_data = app.eeg_events.rest(rest_event_msk)' - vicon_start;
				% add nans so dimensions agree
				if length(tmp_data) < size(data,1)
					num_rows_to_add =  size(data,1) - length(tmp_data);
					tmp_data(end+1:end+num_rows_to_add) = nan(num_rows_to_add,1);
				end
				% try again
				try
					data(:,4) = tmp_data;
				catch ME2
					ME2 = addCause(ME2, ME1);
					rethrow(ME2)
				end
			end
		end
	end
	
	app.UITableEegEvents.Data = round(data);
end


return