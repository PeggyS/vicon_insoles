function compute_insole_events(app, side, hs_or_to, threshold)

if ~isfield(app.vicon_data, 'devices')
	disp('No vicon data to compute events.')
	return
end

if nargin < 4
	threshold = [];
end

% is there insole data to use?
tmp = regexpi(app.vicon_data.devices.tbl.Properties.VariableNames, '.*_emg_.*Voltage_');
if any(~cellfun(@isempty, tmp))
	% time
	t = app.vicon_data.devices.tbl.Frame / 100 + app.vicon_data.devices.tbl.Sub_Frame/1000;
	
	% use insole data
	fsr_list = {'Lat_Heel', 'Med_Heel', 'Lat_Instep', 'Lat_MT', 'Center_MT', 'Med_MT', 'Lat_Toe', 'Med_Toe'};
	all_fsr_data = nan(length(t), length(fsr_list));
	% discover what the fsr variable name prefix is
	var_prefix = find_fsr_var_prefix(app.vicon_data.devices.tbl);
	for cnt = 1:8
		fsr_var = [var_prefix upper(side(1)) '_' fsr_list{cnt} '_V'];
		all_fsr_data(:,cnt) = app.vicon_data.devices.tbl.(fsr_var);
	end

	composite_data = sum(all_fsr_data, 2);

	if isempty(threshold)
		threshold = (max(composite_data) - min(composite_data)) * 0.2 + min(composite_data);
	end
	% compute heel strike & toe off events
	switch hs_or_to
		case 'hs'
% 			data.lat_heel = app.vicon_data.devices.tbl(:, [var_prefix upper(side) '_Lat_Heel_V']);
% 			data.med_heel = app.vicon_data.devices.tbl(:, [var_prefix upper(side) '_Med_Heel_V']);
% 			times = find_hs_times_from_fsrs(t, data, threshold);
			
			times = find_hs_times(t, composite_data, threshold);
		case 'to'
% 			data.lat_toe = app.vicon_data.devices.tbl(:, [var_prefix upper(side) '_Lat_Toe_V']);
% 			data.med_toe = app.vicon_data.devices.tbl(:, [var_prefix upper(side) '_Med_Toe_V']);
			times = find_to_times(t, composite_data, threshold);
		
	end
end

% save info in a struct
app.event_struct.([side hs_or_to]).times = times;

return % compute_insole_events


% % ---------------------------------------------------------------------------
% function [t_heel_strike, t_toe_off] = remove_improbable_events(t_hs, t_to)
% % remove events that are improbably close in time 
% 
% % coordinate the hs & to vectors
% first_hs = t_hs(1);
% first_to_ind = find(t_to > first_hs, 1);
% to_ind_offset = first_to_ind-1;
% 
% num_paired_evts = min([length(t_hs), length(t_to)-(to_ind_offset)]);
% 
% stance_dur = t_to(1+to_ind_offset:num_paired_evts+to_ind_offset) - t_hs(1:num_paired_evts);
% 
% short_stance_inds = find(stance_dur < 0.1);
% all_hs_inds = 1:length(t_hs);
% ok_stance_inds = setdiff(all_hs_inds, short_stance_inds);
% 
% t_heel_strike = t_hs(ok_stance_inds);
% 
% all_to_inds = 1:length(t_to);
% ok_stance_inds = setdiff(all_to_inds, short_stance_inds+to_ind_offset);
% t_toe_off = t_to(ok_stance_inds);
% 
% return

% ---------------------------------------------------------------------------
function [t_heel_strike] = find_hs_times_from_fsrs(t, heel_data, threshold)

% heel strikes from heel data
t_lat_heel_hs = find_hs_times(t', table2array(heel_data.lat_heel)', threshold);
t_med_heel_hs = find_hs_times(t', table2array(heel_data.med_heel)', threshold);
t_heel_strike = [];
if ~isempty(t_lat_heel_hs) 
	t_heel_strike = t_lat_heel_hs;
end
if ~isempty(t_med_heel_hs)
	t_heel_strike = [t_heel_strike t_med_heel_hs];
end
if isempty(t_heel_strike), return, end
% sort the heel strike times and remove ones that are within 0.1 s of another
t_heel_strike = sort(t_heel_strike);
hs_diff = diff(t_heel_strike);
hs_probable_duplicate_msk = hs_diff<0.1;
keep_mask = logical([1 ~hs_probable_duplicate_msk]);
t_heel_strike = t_heel_strike(keep_mask);
return

% ---------------------------------------------------------------------------
function [t_toe_off] = find_to_times_from_fsrs(t, toe_data, threshold)

% toe off times from toe data
t_lat_toe_to = find_to_times(t', table2array(toe_data.lat_toe)', threshold);
t_med_toe_to = find_to_times(t', table2array(toe_data.med_toe)', threshold);
t_toe_off = [];
if ~isempty(t_lat_toe_to)
	t_toe_off = t_lat_toe_to;
end
if ~isempty(t_med_toe_to)
	t_toe_off = [t_toe_off t_med_toe_to];
end
if isempty(t_toe_off), return, end
% sort the toe off times and remove ones that are within 0.1 s of another
t_toe_off = sort(t_toe_off);
to_diff = diff(t_toe_off);
to_probable_duplicate_msk = to_diff<0.1;
keep_mask = logical([~to_probable_duplicate_msk 1]);
t_toe_off = t_toe_off(keep_mask);
return


% --------------
function to_times = find_to_times(t, toe_data, threshold)
if size(toe_data,1) > 1, toe_data = toe_data'; end % force into a row vector
to_times = [];
duration = 0.1;
npts = duration / (t(2)-t(1));
toe_min = min(toe_data);
toe_max = max(toe_data);
if toe_max - toe_min > 0.05
	if isempty(threshold)
		threshold = (toe_max - toe_min)*0.25 + toe_min; 
	end
	% find times when toe is off the ground (<threshold)
	[ind_beg_list, ~] = find_continuous(toe_data < threshold, npts);
	%  
	to_times = t(ind_beg_list);
end
return


% --------------
function hs_times = find_hs_times(t, heel_data, threshold)
if size(heel_data,1) > 1, heel_data = heel_data'; end % force into a row vector
hs_times = [];
duration = 0.1;
npts = duration / (t(2)-t(1));
heel_min = min(heel_data);
heel_max = max(heel_data);
if heel_max - heel_min > 0.05
	if isempty(threshold)
		threshold = (heel_max - heel_min)*0.25 + heel_min; 
	end
	% find times when heel is off the ground (<threshold)
	[~, ind_end_list] = find_continuous(heel_data < threshold, npts);
	%  
	hs_times = t(ind_end_list);
end
return




