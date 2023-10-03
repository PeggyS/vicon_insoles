function get_events_from_default_files(app)

vicon_fname = app.EditFieldViconFilename.Value;
evt_list = {'hs' 'to'};
s_list = {'l' 'r'};
for s_cnt = 1:length(s_list)
	side = s_list{s_cnt};
	for e_cnt = 1:length(evt_list)
		hs_or_to = evt_list{e_cnt};
		
		event_filename = get_event_file(vicon_fname, side, hs_or_to, 'read');
		
		evt_var = [side(1) hs_or_to];
		chkbox_var = [upper(evt_var) 'CheckBox'];
		if exist(event_filename, 'file')			
			tbl = readtable(event_filename);
			app.event_struct.(evt_var).times = tbl.time';
			app.(chkbox_var).Value  = 1;
		else
			app.event_struct.(evt_var).times = [];
			app.(chkbox_var).Value  = 0;
		end
	end
end
	
return