function eeg_events = get_eeg_events(eeg_data)

eeg_events.vicon_start = [];
eeg_events.vicon_stop = [];
eeg_events.walk = [];
eeg_events.turn_stop = [];
eeg_events.rest = [];

% loop through each event 
% depending upon the event type, put its latency in the eeg_event struct
for e_cnt = 1:length(eeg_data.event)
	switch eeg_data.event(e_cnt).type
		case 'V  1'
			ind = eeg_data.event(e_cnt).latency;
			eeg_events.vicon_start = [eeg_events.vicon_start eeg_data.time(ind)];
		case 'W  1'
			ind = eeg_data.event(e_cnt).latency;
			eeg_events.walk = [eeg_events.walk eeg_data.time(ind)];
		case 'T  1'
			ind = eeg_data.event(e_cnt).latency;
			eeg_events.turn_stop = [eeg_events.turn_stop eeg_data.time(ind)];
		case 'R  1'
			ind = eeg_data.event(e_cnt).latency;
			eeg_events.rest = [eeg_events.rest eeg_data.time(ind)];
		case 'X  1'
			ind = eeg_data.event(e_cnt).latency;
			eeg_events.vicon_stop = [eeg_events.vicon_stop eeg_data.time(ind)];
	end
end
return