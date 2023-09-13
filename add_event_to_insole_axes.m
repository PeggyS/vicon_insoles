function h_l = add_event_to_insole_axes(app, h_ax_cmenu, h_ax_list, evt_time, line_color, long_tag)

% h_ax is the only axes that gets the context menu
h_l = gobjects(size(h_ax_list)); % empty array of line handles to return

for ax_cnt = 1:length(h_ax_list)
	h_ax = h_ax_list(ax_cnt);
	
	% vertical line for to & hs
	h_l(ax_cnt) = line(h_ax, [evt_time evt_time], h_ax.YLim, ...
		'Color', line_color, 'LineWidth', 2, 'Tag', long_tag, 'LineStyle', ':');

	if h_ax == h_ax_cmenu
		h_l(ax_cnt).LineStyle = '-';
		% text to display the value of the visible data line at the vertical line
		val_str = get_line_display_data(h_l(ax_cnt));
		h_txt = text(h_ax, evt_time, mean(h_ax.YLim), val_str, 'Visible', 'off');
		% add context menu to the line
		axes(h_ax) %#ok<LAXES>
		createInsoleLineCMenu(app, h_l(ax_cnt), h_txt);
		% by default, turn on draggable
		menuDraggable_Callback(h_l(ax_cnt).UserData.hMenuDrag, [], h_l(ax_cnt), app)
	end
end
return
