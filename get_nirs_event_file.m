function event_filename = get_nirs_event_file(eeg_fname, read_or_write)

event_filename = '';

[data_pn, data_fn, ~] = fileparts(eeg_fname);
default_save_loc = strrep(lower(data_pn), [filesep 'data' filesep], [filesep 'analysis' filesep]);
default_save_loc = strrep(lower(default_save_loc), [filesep 'nirs-eeg' filesep], [filesep 'nirs' filesep]);
% if contains(lower(data_fn),'devices')
% 	default_save_filename = fullfile(default_save_loc, ...
% 		[strrep(lower(data_fn),'devices', '') 'events.txt']);
% else
% 	default_save_filename = fullfile(default_save_loc, ...
% 		[lower(data_fn)  'events.txt']);
% end

tmp = regexp(data_fn, '(_\d+)', 'match');
eeg_evt_fname = ['eeg' tmp{1} '_events.txt'];
default_save_filename = fullfile(default_save_loc, eeg_evt_fname);

if strcmp(read_or_write, 'read')
	if exist(default_save_filename, 'file')
		event_filename = default_save_filename;
		return
	end
	quest = sprintf('Is there an event file: %s ?', default_save_filename);
	tlt = 'Event file';
	ans_butt = questdlg(quest, tlt, 'Yes, I will find it', 'No', 'No');
	switch lower(ans_butt(1:3))
		case 'yes'
			disp('Choose event data')
			[fname, pname] = uigetfile('*.txt', 'Choose event txt File');
			if isequal(fname,0) || isequal(pname,0)
				return
			else
				event_filename = fullfile(pname, fname);
			end
	end
	return
end % if finding the file to read

if strcmp(read_or_write, 'write')
	% does the location exist?
	if ~exist(default_save_loc, 'dir')
		try
			mkdir(default_save_loc)
		catch ME
			disp(ME)
		end
	end
	
	% does the file already exist? overwrite it?
	if exist(default_save_filename, 'file')
		quest = sprintf('%s already exists. Overwrite it?', default_save_filename);
		tlt = 'Overwrite file';
		ans_butt = questdlg(quest, tlt, 'No');
		switch lower(ans_butt)
			case 'yes'
				event_filename = default_save_filename;
			case 'no'
				disp('choose file to save event data')
				[fname, pname] = uiputfile('*.txt', 'Choose event save txt File');
				if isequal(fname,0) || isequal(pname,0)
	% 				disp('User pressed cancel')
					return
				else
	% 				disp(['User selected ', fullfile(pathname, filename)])
					event_filename = fullfile(pname, fname);
				end
			case 'cancel'
				return
		end
	else
		event_filename = default_save_filename;
	end
end % if writing the file