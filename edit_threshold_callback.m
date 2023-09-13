function edit_threshold_callback(source, ~, hs_or_to, app)

h_fig = source.Parent;

% get left or right from h_fig
split_tag = strsplit(h_fig.Tag, '_'); % split into: figure insole left|right
l_or_r = split_tag{3};

split_evt = strsplit(hs_or_to, '_'); % split into: hs lat|med
hs_or_to = split_evt{1};
lat_or_med = split_evt{2};
evt_var = [l_or_r(1) hs_or_to];


compute_insole_events(app, l_or_r(1), hs_or_to, str2double(source.String))

% if there already were event lines drawn, remove them
h_lines = findobj(h_fig, '-regexp', 'Tag', ['line_' evt_var '_.*']);
if ~isempty(h_lines)
	remove_event_line_links(h_fig)
	delete(h_lines)
end
% remove line numbers 
if isfield(app.event_struct.(evt_var), 'line_num')
	app.event_struct.(evt_var) = rmfield(app.event_struct.(evt_var), 'line_num');
end

% was a checkbox showing event lines?, redraw them
h_chkbx = findobj(h_fig, '-regexp', 'Tag', ['show_' hs_or_to '_.*']);
for c_cnt = 1:length(h_chkbx)
	if h_chkbx(c_cnt).Value == 1
		pb_show_insole_events_callback(h_chkbx(c_cnt), [], [hs_or_to '_' lat_or_med], app)
	end
end

return

