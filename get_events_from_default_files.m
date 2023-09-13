function get_events_from_default_files(app)

vicon_fname = app.EditFieldViconFilename.Value;
evt_list = {'hs' 'to'};
s_list = {'l' 'r'};
for s_cnt = 1:length(s_list)
	side = s_list{s_cnt};
	for e_cnt = 1:length(evt_list)
		hs_or_to = evt_list{e_cnt};
		
		event_filename = get_event_file(vicon_fname, side, hs_or_to, 'read');
		
		if exist(event_filename, 'file')
			evt_var = [side(1) hs_or_to];
			tbl = readtable(event_filename);
			app.event_struct.(evt_var).times = tbl.time';
		end
	end
end
	
return