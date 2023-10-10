function cal_show_fp(app, h_ax, side)
% h_ax = handle of axes to draw in
% side = 'left' or 'right'
% Assumption: left foot is on FP1, right foot is on FP2

% time 
% Frame = sec/100; Sub_Frame = milliseconds after the frame
t = app.vicon_data.devices.tbl.Frame / 100 + app.vicon_data.devices.tbl.Sub_Frame/1000;

% fp num and label depends on radio button
switch side
	case 'left'
		if app.LeftInsoleFP1Button.Value == 1
			y_lab = 'FP1 (N)';
			fp_num = 1;
		else
			y_lab = 'FP2 (N)';
			fp_num = 2;
		end
	case 'right'
		if app.RightInsoleFP1Button.Value == 1
			y_lab = 'FP1 (N)';
			fp_num = 1;
		else
			y_lab = 'FP2 (N)';
			fp_num = 2;
		end
	otherwise
		y_lab = '?';
		return
end

% fp variable - force in vertical, Z, direction
fp_var = ['FP' num2str(fp_num) '_Force_Fz_N'];
fp_data = -1 * app.vicon_data.devices.tbl.(fp_var);

% add y-axis on the right
yyaxis(h_ax, 'right')
ylabel(h_ax, y_lab)

l_tag = ['line_fp_' lower(side(1))];

h_line = findobj(h_ax, 'Tag', l_tag);
if isgraphics(h_line)
	% update the existing line
	h_line.XData = t;
	h_line.YData = fp_data;
else
	% create the line
	line(h_ax, t, fp_data, 'Tag', l_tag, 'Color', [0.9 0 0.2]);
end


end