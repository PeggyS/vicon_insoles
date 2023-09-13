function cal_show_fsr_force_est(app, side)

% axes depends on the left or right side
switch side
	case 'left'
		h_ax = app.UIAxesDataLeft;
		fsr_tag = 'line_fsr_l_composite';
		coeff_var = 'coeff_left';
		l_tag = 'line_fsr_force_est_l';
	case 'right'
		h_ax = app.UIAxesDataRight;
		fsr_tag = 'line_fsr_r_composite';
		coeff_var = 'coeff_right';
		l_tag = 'line_fsr_force_est_r';
	otherwise
		error('unknown side')
end

% use the scale on the right side of axes
yyaxis(h_ax, 'right')

% get FSR data
fsr_line = findobj(h_ax, 'Tag', fsr_tag);

% estimate force data using linear fit coefficients
force_est = polyval(app.(coeff_var), fsr_line.YData);

% update or add line to axes
h_line = findobj(h_ax, 'Tag', l_tag);
if isgraphics(h_line)
	% update the existing line
	h_line.YData = force_est;
else
	% create the line
	line(h_ax, fsr_line.XData, force_est, 'Tag', l_tag, ...
		'LineWidth', 2, 'LineStyle', '--');
end


end % function