function complete_event_struct(app)
% after reading in existing event files, compute the ones not read in
evt_list = {'hs' 'to'};
s_list = {'l' 'r'};
for s_cnt = 1:length(s_list)
	side = s_list{s_cnt};
	for e_cnt = 1:length(evt_list)
		hs_or_to = evt_list{e_cnt};
		
		if ~isfield(app.event_struct, [side hs_or_to])
			compute_insole_events(app, side, hs_or_to)
		end
	end
end
return