function compute_gait_cycle_info(app)

% define inv and uninv sides
if strcmpi(app.caller_app.side(1), 'r')
	inv_side = 'r';
	uninv_side = 'l';
else
	inv_side = 'l';
	uninv_side = 'r';
end

% event times (sort them, so they are in order)
all_inv_hs_times = sort(app.caller_app.event_struct.([inv_side 'hs']).times);
all_inv_to_times = sort(app.caller_app.event_struct.([inv_side 'to']).times);
all_uninv_hs_times = sort(app.caller_app.event_struct.([uninv_side 'hs']).times);
all_uninv_to_times = sort(app.caller_app.event_struct.([uninv_side 'to']).times);

% if there are eeg events, which block of trials/walks in the eeg data?
if isfield(app.caller_app.eeg_events, 'vicon_start')
	eeg_block = app.caller_app.BlockNumberEditField.Value;

	% compute gait cycle info between each walk & turn_stop that are between vicon_start  & stop
	vicon_start = app.caller_app.eeg_events.vicon_start(eeg_block);
	vicon_stop  = app.caller_app.eeg_events.vicon_stop(eeg_block);
	walk_times = app.caller_app.eeg_events.walk(app.caller_app.eeg_events.walk > vicon_start & ...
		app.caller_app.eeg_events.walk < vicon_stop) - vicon_start;
	turn_times = app.caller_app.eeg_events.turn_stop(app.caller_app.eeg_events.turn_stop > vicon_start & ...
		app.caller_app.eeg_events.turn_stop < vicon_stop) - vicon_start;
	for trial_cnt = 1:length(turn_times)
		trial_inv_hs_times = all_inv_hs_times(all_inv_hs_times > walk_times(trial_cnt) & ...
			all_inv_hs_times < turn_times(trial_cnt));
		trial_inv_to_times = all_inv_to_times(all_inv_to_times > walk_times(trial_cnt) & ...
			all_inv_to_times < turn_times(trial_cnt));
		trial_uninv_hs_times = all_uninv_hs_times(all_uninv_hs_times > walk_times(trial_cnt) & ...
			all_uninv_hs_times < turn_times(trial_cnt));
		trial_uninv_to_times = all_uninv_to_times(all_uninv_to_times > walk_times(trial_cnt) & ...
			all_uninv_to_times < turn_times(trial_cnt));

		if ~isempty(trial_inv_hs_times) % in case there are no hs times, don't compute gait cycle info
			if isempty(app.gc_data_tbl)
				app.gc_data_tbl = compute_gc_data_tbl(app, trial_inv_hs_times, trial_inv_to_times, ...
					trial_uninv_hs_times, trial_uninv_to_times);
			else
				tmp_tbl = compute_gc_data_tbl(app, trial_inv_hs_times, trial_inv_to_times, ...
					trial_uninv_hs_times, trial_uninv_to_times);
				app.gc_data_tbl = vertcat(app.gc_data_tbl, tmp_tbl);
			end
		end % if not hs times
	end
else
	app.gc_data_tbl = compute_gc_data_tbl(app, all_inv_hs_times, all_inv_to_times, ...
		all_uninv_hs_times, all_uninv_to_times);
end


end % function