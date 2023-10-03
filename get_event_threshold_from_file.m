function get_event_threshold_from_file(app)

vicon_fname = app.EditFieldViconFilename.Value;

% get the default file name
threshold_filename = get_threshold_file(vicon_fname,  'read');


% read in the struct
if exist(threshold_filename, 'file')
	app.fsr_event_threshold_struct = readstruct(threshold_filename);
end


end