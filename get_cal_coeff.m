function coeff = get_cal_coeff(app)

coeff = [];

[save_loc, ~, ~] = fileparts(app.vicon_data.filename);
% if the current directory has '/data/' in it then change it
% '/analysis/' 
if contains(save_loc, [filesep 'data' filesep], 'IgnoreCase', true)
	save_loc = strrep(lower(save_loc), [filesep 'data' filesep], [filesep 'analysis' filesep]);
	% if it doesn't exist, inform the user there is no calibration data
	if ~exist(save_loc, 'dir')
		msg = ['No insole calibration data. Folder ' save_loc ' does not exist.'];
		uialert(app.ViconInsoleAppUIFigure, msg, 'Calibration Error', 'Icon', 'error' )
		return
	end
end

% file name .xml (using built-in read and writestruct) 
fname = fullfile(save_loc, 'insole_cal_coeffs.xml');
if ~exist(fname, 'file')
	msg = ['No insole calibration data in ' save_loc ];
	uialert(app.ViconInsoleAppUIFigure, msg, 'Calibration Error', 'Icon', 'error')
	return
end

% read in struct
coeff = readstruct(fname);

% verify there are 2 fields, left & right and both contain a vector of 2 values
fld_names = fieldnames(coeff);
assert(length(fld_names) >= 2 && length(fld_names) <= 3, 'Error getting insole calibration coefficients. 2 or 3 fields were not found.')
assert(any(contains(fld_names, 'left')), 'Error getting insole calibration coefficients. left field not found.')
assert(any(contains(fld_names, 'right')), 'Error getting insole calibration coefficients. right field not found.')
assert(length(coeff.(fld_names{1})) == 2, ['Error getting insole calibration coefficients. ' ...
	fld_names{1} ' is not length = 2.'])
assert(length(coeff.(fld_names{2})) == 2, ['Error getting insole calibration coefficients. ' ...
	fld_names{2} ' is not length = 2.'])