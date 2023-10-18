function coeff = cal_compute_fit_coef(app, side)

coeff = []; %#ok<NASGU> 

% axes and data line tag depends on the left or right side
switch side
	case 'left'
		h_ax = app.UIAxesDataLeft;
		fsr_tag = 'line_fsr_l_composite';
		fp_tag  = 'line_fp_l';
	case 'right'
		h_ax = app.UIAxesDataRight;
		fsr_tag = 'line_fsr_r_composite';
		fp_tag  = 'line_fp_r';
	otherwise
		error('unknown side')
end

% get the data
fsr_line = findobj(h_ax, 'Tag', fsr_tag);
fp_line = findobj(h_ax, 'Tag', fp_tag);

% verify the x (time) data are the same
assert(all(fsr_line.XData==fp_line.XData), 'mismatch between FSR and FP time vectors')

% compute linear fit
coeff = polyfit(fsr_line.YData, fp_line.YData, 1);


end % function