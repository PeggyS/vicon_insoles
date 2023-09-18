function coeff = get_cal_coeff(app)

[save_loc, ~, ~] = fileparts(app.vicon_data.filename);
% if the current directory has '/data/' in it then change it
% '/analysis/' 
if contains(save_loc, [filesep 'data' filesep], 'IgnoreCase', true)
	save_loc = strrep(lower(save_loc), [filesep 'data' filesep], [filesep 'analysis' filesep]);
	% if it doesn't exist, inform the user there is no calibration data
	if ~exist(save_loc, 'dir')

	end
end