function add_eeg_event_lines(app, h_ax_list)

% which block of events to show?
block_number = app.BlockNumberEditField.Value;
if block_number < 1 || block_number > length(app.eeg_events.vicon_start)
	error('Invalid block number value. EEG data has %d blocks.', length(app.eeg_events.vicon_start))
end

t_start = app.eeg_events.vicon_start(block_number);
t_end =  app.eeg_events.vicon_stop(block_number);

evt_type_list = {'walk', 'turn_stop', 'rest'};
evt_color_list = {[0 0 0.9], [0.8 0 0], [0.2 0.7 0.7]};

for et_cnt = 1:length(evt_type_list)
	evt_var = evt_type_list{et_cnt};
	evt_times = app.eeg_events.(evt_var)(app.eeg_events.(evt_var)>t_start & app.eeg_events.(evt_var) < t_end);

	evt_times = evt_times - t_start;
	
	for t_cnt = 1:length(evt_times)
	
		long_tag = ['line_eeg_evt_' evt_var '_' num2str(t_cnt)];


		for ax_cnt = 1:length(h_ax_list)
			h_ax = h_ax_list(ax_cnt);

			% vertical line 
			h_l(ax_cnt) = line(h_ax, [evt_times(t_cnt) evt_times(t_cnt)], h_ax.YLim, ...
				'Color', evt_color_list{et_cnt}, 'LineWidth', 2, 'Tag', long_tag, 'LineStyle', '-');
		end
	end
end
return

