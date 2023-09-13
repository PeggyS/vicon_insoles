function event_filename = get_event_file(vicon_fname, side, hs_or_to, read_or_write)

event_filename = '';

[data_pn, data_fn, ~] = fileparts(vicon_fname);
default_save_loc = strrep(lower(data_pn), [filesep, 'data', filesep], [filesep, 'analysis', filesep]);
if contains(lower(data_fn),'devices')
	default_save_filename = fullfile(default_save_loc, ...
		[strrep(lower(data_fn),'devices', '') side hs_or_to '_events.csv']);
else
	default_save_filename = fullfile(default_save_loc, ...
		[lower(data_fn) '_' side hs_or_to '_events.csv']);
end

if strcmp(read_or_write, 'read')
	if exist(default_save_filename, 'file')
		event_filename = default_save_filename;
		return
	end
	quest = sprintf('Is there an event file: %s ?', default_save_filename);
	tlt = 'Event file';
	ans_butt = questdlg(quest, tlt, 'Yes, I will find it', 'No, compute events', 'No, compute events');
	switch lower(ans_butt(1:3))
		case 'yes'
			disp('Choose event data')
			[fname, pname] = uigetfile('*.csv', 'Choose event csv File');
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
	
	% does the file alread exist? overwrite it?
	if exist(default_save_filename, 'file')
		quest = sprintf('%s already exists. Overwrite it?', default_save_filename);
		tlt = 'Overwrite file';
		ans_butt = questdlg(quest, tlt, 'No');
		switch lower(ans_butt)
			case 'yes'
				event_filename = default_save_filename;
			case 'no'
				disp('choose file to save event data')
				[fname, pname] = uiputfile('*.csv', 'Choose event save csv File');
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