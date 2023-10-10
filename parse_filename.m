function parse_filename(app)

filename = app.EditFieldViconFilename.Value;
if ~exist(filename, 'file')
	msg = sprintf('File not found: %s', filename);
	uialert(app.ViconInsoleAppUIFigure, msg, 'File name error', 'Icon', 'error')
	return
end

% filename should look like this: /Users/peggy/Documents/BrainLab/tDCS Gait/Data/vicon/s2702tdvg/Pre/Trial15.csv

% subject
tmp_str = regexpi(filename, '/s\d{4}.{0,4}/', 'match');
if ~isempty(tmp_str)
	app.subject = strrep(tmp_str{:},'/','');
else
	app.subject = '';
end

% session
tmp_str = regexpi(filename, '/(pre)|(mid)|(post)|(followup2)|(followup)|(fu2)|(fu)/', 'match');
if ~isempty(tmp_str)
	app.session = lower(strrep(tmp_str{:},'/',''));
else
	app.session = '';
end


% trial number
tmp_str = regexpi(filename, '(?<tr_num>\d+)\.csv', 'names');
if ~isempty(tmp_str)
	app.trial_num = str2double(tmp_str);
else
	app.trial_num = [];
end



