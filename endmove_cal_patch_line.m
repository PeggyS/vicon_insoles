function endmove_cal_patch_line(h_line)

% find app
% app_win = findobj('Name', 'Calibrate Insoles');
% if isempty(app_win)
% 	app_win = findwind('Calibrate Insoles', 'Name');
% end
% assert(isa(app_win, 'matlab.ui.Figure'), 'did not find Calibrate Insoles App')
% app = app_win.RunningAppInstance;
h_ax = h_line.Parent;
app = h_ax.Parent.RunningAppInstance;

if contains(h_ax.Title.String, 'Left')
	app.coeff_left = cal_compute_fit_coef(app, 'left');
	app.Coeff_1_LeftEditField.Value = app.coeff_left(1);
	app.Coeff_2_LeftEditField.Value = app.coeff_left(2);
	% show fit
	cal_show_fsr_force_est(app, 'left')
else
	app.coeff_right = cal_compute_fit_coef(app, 'right');
	app.Coeff_1_RightEditField.Value = app.coeff_right(1);
	app.Coeff_2_RightEditField.Value = app.coeff_right(2);
	% show fit
	cal_show_fsr_force_est(app, 'right')
end



end % function