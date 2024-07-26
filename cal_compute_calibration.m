function cal_compute_calibration(app)

% compute linear fit between FSR V & FP N
app.coeff_left = cal_compute_fit_coef(app, 'left');
app.Coeff_1_LeftEditField.Value = app.coeff_left(1);
app.Coeff_2_LeftEditField.Value = app.coeff_left(2);
app.coeff_right = cal_compute_fit_coef(app, 'right');
app.Coeff_1_RightEditField.Value = app.coeff_right(1);
app.Coeff_2_RightEditField.Value = app.coeff_right(2);

end