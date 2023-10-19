function coeff = cal_compute_fit_coef(app, side)

coeff = []; %#ok<NASGU> 

% axes and data line tag depends on the left or right side
switch side
	case 'left'
		h_ax = app.UIAxesDataLeft;
		fsr_tag = 'line_fsr_l_composite';
		fp_tag  = 'line_fp_l';
		h_chkbx = app.LeftAdjusttimeintervaltouseCheckBox;
	case 'right'
		h_ax = app.UIAxesDataRight;
		fsr_tag = 'line_fsr_r_composite';
		fp_tag  = 'line_fp_r';
		h_chkbx = app.RightAdjusttimeintervaltouseCheckBox;
	otherwise
		error('unknown side')
end

% get the data
fsr_line = findobj(h_ax, 'Tag', fsr_tag);
fp_line = findobj(h_ax, 'Tag', fp_tag);

% verify the x (time) data are the same
assert(all(fsr_line.XData==fp_line.XData), 'mismatch between FSR and FP time vectors')

% if there is a time interval to use
if h_chkbx.Value == 1
	h_left = findobj(h_ax, 'Tag', 'cal_patch_left_side');
	h_right = findobj(h_ax, 'Tag', 'cal_patch_right_side');
	msk = fsr_line.XData > h_left.XData(1) & fsr_line.XData < h_right.XData(1);
	fsr_data = fsr_line.YData(msk);
	fp_data = fp_line.YData(msk);
else
	fsr_data = fsr_line.YData;
	fp_data = fp_line.YData;
end

% compute linear fit
coeff = polyfit(fsr_data, fp_data, 1);


end % function