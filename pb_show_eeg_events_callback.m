function pb_show_eeg_events_callback(source, ~, app)

h_fig = source.Parent;

% showing or not showing
if source.Value

	% show if lines already created
	h_lines = findobj(h_fig, '-regexp', 'Tag', 'line_eeg_evt_.*');
	if ~isempty(h_lines)
		set(h_lines, 'Visible', 'on');
	else
		%create the lines

		% axes
		h_all_axes = findobj(h_fig, 'Type', 'axes');
				
		% if there are events
		if ~isempty(app.eeg_events)
			% add lines for events
			add_eeg_event_lines(app, h_all_axes);
		end
	end
else
	% not showing - hide the lines
	h_lines = findobj(h_fig, '-regexp', 'Tag', 'line_eeg_evt_.*');
	if ~isempty(h_lines)
		set(h_lines, 'Visible', 'off');
	end
end
return

