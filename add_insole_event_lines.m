function add_insole_event_lines(app, h_ax, h_ax_list, line_color, evt_var, t_interval)
% only showing events between the time interval
if ~isempty(t_interval)
	event_inds = find(app.event_struct.(evt_var).times >= t_interval(1) & ...
		app.event_struct.(evt_var).times <= t_interval(2));
else
	% all events
	event_inds = 1:length(app.event_struct.(evt_var).times);
end

for t_cnt = event_inds
	
	long_tag = ['line_' evt_var '_' num2str(t_cnt)];

	evt_time = app.event_struct.(evt_var).times(t_cnt);
	h_l = add_event_to_insole_axes(app, h_ax, h_ax_list, evt_time, line_color, long_tag);
	
	if isfield(app.event_struct.(evt_var), 'links') && length(app.event_struct.(evt_var).links) >= t_cnt
		addtarget(app.event_struct.(evt_var).links(t_cnt), h_l);
	else
		app.event_struct.(evt_var).links(t_cnt) = linkprop(h_l, 'XData');
	end
	
	% save the line number in the event_struct
	app.event_struct.(evt_var).line_num(t_cnt) = t_cnt;
	
end


