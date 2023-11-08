function h_l = add_event_to_insole_axes(app, h_ax_cmenu, h_ax_list, evt_time, line_color, long_tag)

% h_ax is the only axes that gets the context menu
h_l = gobjects(size(h_ax_list)); % empty array of line handles to return

% datacursor manager for datatips
% dcm = datacursormode(h_ax_list(1).Parent);

for ax_cnt = 1:length(h_ax_list)
	h_ax = h_ax_list(ax_cnt);
	
	% vertical line for to & hs
	h_l(ax_cnt) = line(h_ax, [evt_time evt_time], h_ax.YLim, ...
		'Color', line_color, 'LineWidth', 2, 'Tag', long_tag, 'LineStyle', ':');

	if h_ax == h_ax_cmenu
		h_l(ax_cnt).LineStyle = '-';
% 		% datatip to display the value of the visible data line at the vertical line
% 		h_force_line = findobj(h_ax, '-regexp', 'Tag', 'line.*force_est');
% 		dt = dcm.createDatatip(h_force_line);
% 		set(dt, 'MarkerSize',7, 'MarkerFaceColor','none', ...
%                   'MarkerEdgeColor','r', 'Marker','o', 'HitTest','on', 'Draggable', 'off');
% 		% move datatip to correct position
% 		idx = find(dt.DataSource.XData >= h_l.XData(1), 1, 'first');
% 		dt.Position = [dt.DataSource.XData(idx) dt.DataSource.YData(idx) 0];
% 
% 		% save datatip in vertical line userdata
% 		h_l(ax_cnt).UserData.datatip = dt;
% 
% 		% add deletefcn to remove the datatip when the line is deleted
% 		h_l.DeleteFcn = @line_delete_dt_fcn;

% 		val_str = get_line_display_data(h_l(ax_cnt));
% 		h_txt = text(h_ax, evt_time, mean(h_ax.YLim), val_str, 'Visible', 'off');
		
		% add context menu to the line
		axes(h_ax) %#ok<LAXES>
% 		createInsoleLineCMenu(app, h_l(ax_cnt), h_txt);
		createInsoleLineCMenu(app, h_l(ax_cnt));
		% by default, turn on draggable
		menuDraggable_Callback(h_l(ax_cnt).UserData.hMenuDrag, [], h_l(ax_cnt), app)
	end
end
return
