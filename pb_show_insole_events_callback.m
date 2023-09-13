function pb_show_insole_events_callback(source, ~, hs_or_to, app)

h_fig = source.Parent;

% get left or right from h_fig
split_tag = strsplit(h_fig.Tag, '_'); % split into: figure insole left|right
l_or_r = split_tag{3};

split_evt = strsplit(hs_or_to, '_'); % split into: hs lat|med
hs_or_to = split_evt{1};
lat_or_med = split_evt{2};
evt_var = [l_or_r(1) hs_or_to];

% showing or not showing
if source.Value
	% show
	% check if the other checkbox has already created lines
	other_chkbx_tag = get_other_chkbx_tag(source.Tag, lat_or_med);
	other_chkbx = findobj(h_fig, 'Tag', other_chkbx_tag);
	if ~isempty(other_chkbx) && isfield(other_chkbx.UserData, 'hasLines') && other_chkbx.UserData.hasLines
		% other checkbox has lines, remove them 
		h_lines = findobj(h_fig, '-regexp', 'Tag', ['line_' evt_var '_.*']);
		remove_event_line_links(h_fig)
		delete(h_lines)
		other_chkbx.UserData.hasLines = false;
		other_chkbx.Value = 0;
	end
	
	% show if lines already created
	h_lines = findobj(h_fig, '-regexp', 'Tag', ['line_' evt_var '_.*']);
	if ~isempty(h_lines)
		set(h_lines, 'Visible', 'on');
	else
		%create the lines

		% axes
		h_all_axes = findobj(h_fig, 'Type', 'axes');
		switch hs_or_to
			case 'hs'
				h_ax = findobj(h_fig, 'Tag', ['axes_' l_or_r(1) '_' lat_or_med '_heel']);
				if isempty(h_ax)
					h_ax = findobj(h_fig, 'Tag', ['axes_' l_or_r(1) '_composite']);
					assert(~isempty(h_ax), 'axes to display hs lines not found')
				end
				evt_color = 'k';
			case 'to'
				h_ax = findobj(h_fig, 'Tag', ['axes_' l_or_r(1) '_' lat_or_med '_toe']);
				if isempty(h_ax)
					h_ax = findobj(h_fig, 'Tag', ['axes_' l_or_r(1) '_composite']);
					assert(~isempty(h_ax), 'axes to display to lines not found')
				end
				evt_color = 'g';
			otherwise
				error('unkown event %s', hs_or_to)
		end
				
		% if there are events
		if ~isempty(app.event_struct.(evt_var).times)
			% add lines for events
			add_insole_event_lines(app, h_ax, h_all_axes, evt_color, evt_var, []);
			% save that this checkbox has created lines
			source.UserData.hasLines = true;
		end
	end
else
	% not showing - hide the lines
	h_lines = findobj(h_fig, '-regexp', 'Tag', ['line_' evt_var '_.*']);
	if ~isempty(h_lines)
		set(h_lines, 'Visible', 'off');
	end
end
return

% ------------
function other_chkbx = get_other_chkbx_tag(this_tag, lat_or_med)
switch lat_or_med
	case 'lat'
		other_chkbx = strrep(this_tag, 'lat', 'med');
	case 'med'
		other_chkbx = strrep(this_tag, 'med', 'lat');
end
return