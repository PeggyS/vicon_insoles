function draw_hs_to_events(app)


% define inv and uninv sides
if strcmpi(app.caller_app.side(1), 'r')
	inv_side = 'r';
	uninv_side = 'l';
else
	inv_side = 'l';
	uninv_side = 'r';
end

inv_hs = [inv_side 'hs'];
inv_to = [inv_side 'to'];
uninv_hs = [uninv_side 'hs'];
uninv_to = [uninv_side 'to'];

% inv hs
for e_cnt = 1:length(app.caller_app.event_struct.(inv_hs).times)
	t = app.caller_app.event_struct.(inv_hs).times(e_cnt);

	line(app.UIAxes_inv_heel, [t t], app.UIAxes_inv_heel.YLim, 'Color', 'k', 'LineWidth', 1)
	line(app.UIAxes_inv_toe, [t t], app.UIAxes_inv_toe.YLim, 'Color', 'k', 'LineWidth', 1)
end
% inv to
for e_cnt = 1:length(app.caller_app.event_struct.(inv_to).times)
	t = app.caller_app.event_struct.(inv_to).times(e_cnt);

	line(app.UIAxes_inv_heel, [t t], app.UIAxes_inv_heel.YLim, 'Color', 'g', 'LineWidth', 1)
	line(app.UIAxes_inv_toe, [t t], app.UIAxes_inv_toe.YLim, 'Color', 'g', 'LineWidth', 1)
end
% uninv hs
for e_cnt = 1:length(app.caller_app.event_struct.(uninv_hs).times)
	t = app.caller_app.event_struct.(uninv_hs).times(e_cnt);

	line(app.UIAxes_uninv_heel, [t t], app.UIAxes_uninv_heel.YLim, 'Color', 'k', 'LineWidth', 1)
	line(app.UIAxes_uninv_toe, [t t], app.UIAxes_uninv_toe.YLim, 'Color', 'k', 'LineWidth', 1)
end
% uninv to
for e_cnt = 1:length(app.caller_app.event_struct.(uninv_to).times)
	t = app.caller_app.event_struct.(uninv_to).times(e_cnt);

	line(app.UIAxes_uninv_heel, [t t], app.UIAxes_uninv_heel.YLim, 'Color', 'g', 'LineWidth', 1)
	line(app.UIAxes_uninv_toe, [t t], app.UIAxes_uninv_toe.YLim, 'Color', 'g', 'LineWidth', 1)
end


end % function