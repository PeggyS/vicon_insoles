function cal_add_interval(app, side)

% add patch with draggable lines to define the section of data to use

side_txt = side;
side_txt(1) = upper(side_txt(1));
axes_txt = ['UIAxesData' side_txt];


% add a patch from axes xmin to somewhere in the middle. Make it shaded. This is data not to use for calibration.
h_ax = app.(axes_txt);
x_end_left_patch = mean(h_ax.XLim) - 0.1 * diff(h_ax.XLim);
h_patch_left = patch(h_ax, ...
	'XData', [h_ax.XLim(1) h_ax.XLim(1) x_end_left_patch x_end_left_patch], ...
	'YData', [h_ax.YLim(1) h_ax.YLim(2) h_ax.YLim(2) h_ax.YLim(1)], ...
	'FaceColor', [0.8 0.8 0.8], ...
	'FaceAlpha', 0.2, ...
	'Tag', 'left_patch');
% add a line at the right side of the patch that is draggable 
h_patch_left_edge = line(h_ax, [x_end_left_patch x_end_left_patch], h_ax.YLim, ...
	'Color', [0 0 0], 'LineWidth', 1, 'Tag', 'cal_patch_left_side', 'UserData', h_patch_left);
hd = draggable(h_patch_left_edge, 'h');
hd.on_move_callback = @move_cal_patch_line;
hd.on_release_callback = @endmove_cal_patch_line;

% add a patch from somewhere in the middle to axes xmax. Make it shaded. This is data not to use for calibration.
h_ax = app.(axes_txt);
x_end_right_patch = mean(h_ax.XLim) + 0.1 * diff(h_ax.XLim);
h_patch_right = patch(h_ax, ...
	'XData', [x_end_right_patch x_end_right_patch h_ax.XLim(2) h_ax.XLim(2)], ...
	'YData', [h_ax.YLim(1) h_ax.YLim(2) h_ax.YLim(2) h_ax.YLim(1)], ...
	'FaceColor', [0.8 0.8 0.8], ...
	'FaceAlpha', 0.2, ...
	'Tag', 'right_patch');
% add a line at the left side of the patch that is draggable 
h_patch_right_edge = line(h_ax, [x_end_right_patch x_end_right_patch], h_ax.YLim, ...
	'Color', [0 0 0], 'LineWidth', 1, 'Tag', 'cal_patch_right_side', 'UserData', h_patch_right);
hd = draggable(h_patch_right_edge, 'h');
hd.on_move_callback = @move_cal_patch_line;
hd.on_release_callback = @endmove_cal_patch_line;




end % function