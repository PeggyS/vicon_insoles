function handles = find_hs_to_events( handles )
%FIND_HS_TO_EVENTS Determine the heel strike & toe off events from vicon data
%   Detailed explanation goes here
%
%


% Author: Peggy Skelly
% 2017-08-03: create 
% 2021-07-22: add detection of events from insole fsrs


if ~isfield(handles, 'vicon_data')
	disp('No vicon data to compute events.')
	return
end

% is there isole data to use?
tmp = regexpi(handles.vicon_data.devices.tbl.Properties.VariableNames, '.*_emg_.*Voltage_');
if any(~cellfun(@isempty, tmp))
	% time 
	t = handles.vicon_data.devices.tbl.Frame / 100 + handles.vicon_data.devices.tbl.Sub_Frame/1000;

	% use insole data
	% discover what the fsr variable name prefix is
	var_prefix = find_fsr_var_prefix(handles.vicon_data.devices.tbl);
	
	left.lat_toe = handles.vicon_data.devices.tbl(:, [var_prefix 'L_Lat_Toe_V']);
 	left.med_toe = handles.vicon_data.devices.tbl(:, [var_prefix 'L_Med_Toe_V']);
	left.lat_heel = handles.vicon_data.devices.tbl(:, [var_prefix 'L_Lat_Heel_V']);
 	left.med_heel = handles.vicon_data.devices.tbl(:, [var_prefix 'L_Med_Heel_V']);

	right.lat_toe = handles.vicon_data.devices.tbl(:, [var_prefix 'R_Lat_Toe_V']);
 	right.med_toe = handles.vicon_data.devices.tbl(:, [var_prefix 'R_Med_Toe_V']);
	right.lat_heel = handles.vicon_data.devices.tbl(:, [var_prefix 'R_Lat_Heel_V']);
 	right.med_heel = handles.vicon_data.devices.tbl(:, [var_prefix 'R_Med_Heel_V']);

	% compute heel strike & toe off events
	[lhs_times, lto_times] = find_hs_to_times_from_fsrs(handles, t, left);
	[rhs_times, rto_times] = find_hs_to_times_from_fsrs(handles, t, right);
else

	% time
	t = handles.vicon_data.markers.tbl.Frame / handles.vicon_data.markers.samp_freq;
	
	% use toe and heel x, y, z, pos, vel & acc
	left.toe = get_data(handles.vicon_data.markers.tbl, 'LTOE');
	left.heel = get_data(handles.vicon_data.markers.tbl, 'LHEE');
	left.ff_times = handles.event_struct.lff;
	
	right.toe = get_data(handles.vicon_data.markers.tbl, 'RTOE');
	right.heel = get_data(handles.vicon_data.markers.tbl, 'RHEE');
	right.ff_times = handles.event_struct.rff;
	
	% compute heel strike & toe off events
	[lhs_times, lto_times] = find_hs_to_times_from_markers(handles, t, left);
	[rhs_times, rto_times] = find_hs_to_times_from_markers(handles, t, right);
end

% save info in a struct
handles.event_struct.rhs.times = rhs_times;
handles.event_struct.rto.times = rto_times;

handles.event_struct.lhs.times = lhs_times;
handles.event_struct.lto.times = lto_times;

end % find_hs_to_events


% ---------------------------------------------------------------------------
function data = get_data(tbl, marker)
data.x.pos = tbl(:, [marker '_X_mm']);
data.y.pos = tbl(:, [marker '_Y_mm']);
data.z.pos = tbl(:, [marker '_Z_mm']);
data.x.vel = tbl(:, [marker '_X_vel_mm_per_s']);
data.y.vel = tbl(:, [marker '_Y_vel_mm_per_s']);
data.z.vel = tbl(:, [marker '_Z_vel_mm_per_s']);
data.x.acc = tbl(:, [marker '_X_acc_mm_per_s_2']);
data.y.acc = tbl(:, [marker '_Y_acc_mm_per_s_2']);
data.z.acc = tbl(:, [marker '_Z_acc_mm_per_s_2']);
end

% ---------------------------------------------------------------------------
function [t_heel_strike, t_toe_off] = remove_improbable_events(t_hs, t_to, fpy)
% remove events that are improbably close in time and force between hs & to
% is improbably low

% coordinate the hs & to vectors
first_hs = t_hs(1);
first_to_ind = find(t_to > first_hs, 1);
to_ind_offset = first_to_ind-1;

num_paired_evts = min([length(t_hs), length(t_to)-(to_ind_offset)]);

stance_dur = t_to(1+to_ind_offset:num_paired_evts+to_ind_offset) - t_hs(1:num_paired_evts);

short_stance_inds = find(stance_dur < 0.1);
all_hs_inds = 1:length(t_hs);
ok_stance_inds = setdiff(all_hs_inds, short_stance_inds);

t_heel_strike = t_hs(ok_stance_inds);

all_to_inds = 1:length(t_to);
ok_stance_inds = setdiff(all_to_inds, short_stance_inds+to_ind_offset);
t_toe_off = t_to(ok_stance_inds);

end

% ---------------------------------------------------------------------------
function [t_heel_strike, t_toe_off] = find_hs_to_times_from_fsrs(handles, t, toe_heel_data)

% heel strikes from heel data
t_lat_heel_hs = find_hs_times(handles, t', table2array(toe_heel_data.lat_heel)');
t_med_heel_hs = find_hs_times(handles, t', table2array(toe_heel_data.med_heel)');
t_heel_strike = [];
if ~isempty(t_lat_heel_hs) 
	t_heel_strike = t_lat_heel_hs;
end
if ~isempty(t_med_heel_hs)
	t_heel_strike = [t_heel_strike t_med_heel_hs];
end
% sort the heel strike times and remove ones that are within 0.1 s of another
t_heel_strike = sort(t_heel_strike);
hs_diff = diff(t_heel_strike);
hs_probable_duplicate_msk = hs_diff<0.1;
keep_mask = logical([1 ~hs_probable_duplicate_msk]);
t_heel_strike = t_heel_strike(keep_mask);

% toe off times from toe data
t_lat_toe_to = find_to_times(handles, t', table2array(toe_heel_data.lat_toe)');
t_med_toe_to = find_to_times(handles, t', table2array(toe_heel_data.med_toe)');
t_toe_off = [];
if ~isempty(t_lat_toe_to)
	t_toe_off = t_lat_toe_to;
end
if ~isempty(t_med_toe_to)
	t_toe_off = [t_toe_off t_med_toe_to];
end
% sort the toe off times and remove ones that are within 0.1 s of another
t_toe_off = sort(t_toe_off);
to_diff = diff(t_toe_off);
to_probable_duplicate_msk = to_diff<0.1;
keep_mask = logical([~to_probable_duplicate_msk 1]);
t_toe_off = t_toe_off(keep_mask);
return
end

% --------------
function to_times = find_to_times(h, t, toe_data)
if size(toe_data,1) > 1, toe_data = toe_data'; end % force into a row vector
to_times = [];
duration = 0.01;
npts = duration / (t(2)-t(1));
toe_min = min(toe_data);
toe_max = max(toe_data);
if toe_max - toe_min > 0.05
	threshold = (toe_max - toe_min)*0.25 + toe_min; 
	% find times when toe is off the ground (<threshold)
	[ind_beg_list, ind_end_list] = find_continuous(toe_data < threshold, npts);
	%  
	to_times = t(ind_beg_list);
end
return
end

% --------------
function hs_times = find_hs_times(h, t, heel_data)
if size(heel_data,1) > 1, heel_data = heel_data'; end % force into a row vector
hs_times = [];
duration = 0.01;
npts = duration / (t(2)-t(1));
heel_min = min(heel_data);
heel_max = max(heel_data);
if heel_max - heel_min > 0.05
	threshold = (heel_max - heel_min)*0.25 + heel_min; 
	% find times when heel is off the ground (<threshold)
	[ind_beg_list, ind_end_list] = find_continuous(heel_data < threshold, npts);
	%  
	hs_times = t(ind_end_list);
end
return
end
% ---------------------------------------------------------------------------
function [t_heel_strike, t_toe_off] = find_hs_to_times_from_markers(handles, t, toe_heel_data)
% handles.event_struct.lff = left foot flat times
% From foot flat times, look for when the toe
% lifts off the floor (z = vertical dir velocity, or norm of y-z in case of toe
% drag, exceeds a threshold) for toe off. 
% Look back in time for heel strike (heel z vel < thresh, or toe z vel < thresh
% in case it hits the ground first)

ind_heel_strike = [];
ind_toe_off = [];

% compute the norm of heel & toe y & z velocity
norm_yz_toe_vel = arrayfun(@(x,y)norm([x,y]), table2array(toe_heel_data.toe.y.vel), ...
	table2array(toe_heel_data.toe.z.vel));
norm_yz_toe_acc = arrayfun(@(x,y)norm([x,y]), table2array(toe_heel_data.toe.y.acc), ...
	table2array(toe_heel_data.toe.z.acc));
norm_yz_heel_vel = arrayfun(@(x,y)norm([x,y]), table2array(toe_heel_data.heel.y.vel), ...
	table2array(toe_heel_data.heel.z.vel));
% norm_yz_heel_acc = arrayfun(@(x,y)norm([x,y]), table2array(toe_heel_data.heel.y.acc), ...
% 	table2array(toe_heel_data.heel.z.acc));

heel_z_vel = table2array(toe_heel_data.heel.z.vel);
toe_z_vel = table2array(toe_heel_data.toe.z.vel);

% thresholds
norm_yz_thresh = str2double(handles.ed_norm_yz_vel_thresh.String);
yz_acc_thresh = str2double(handles.ed_norm_yz_acc_thresh.String);
z_heel_vel_hs_thresh = str2double(handles.ed_heel_z_vel_hs_thresh.String);
z_toe_vel_hs_thresh = str2double(handles.ed_toe_z_vel_hs_thresh.String);

% from each foot_on_floor_ind, look forward for toe off and backward for heel strike
for cnt = 1:length(toe_heel_data.ff_times)
	foot_on_floor_ind = find(t>=toe_heel_data.ff_times(cnt), 1);
	
	% norm of yz toe, greater than threshold = toe off
	to_ind = find(norm_yz_toe_vel(foot_on_floor_ind:end) > norm_yz_thresh & ...
				  norm_yz_toe_acc(foot_on_floor_ind:end) > yz_acc_thresh, ...
		1, 'first') + foot_on_floor_ind - 1;
	ind_toe_off = add_to_array(ind_toe_off, to_ind);
	
	% look backwards for the heel (or toe) z vel to go below threshol
	rev_ind = find(heel_z_vel(foot_on_floor_ind:-1:1) < z_heel_vel_hs_thresh, 1, 'first');
	hs_heel_ind = foot_on_floor_ind - rev_ind + 1;
	rev_ind = find(toe_z_vel(foot_on_floor_ind:-1:1) < z_toe_vel_hs_thresh, 1, 'first');
	hs_toe_ind = foot_on_floor_ind - rev_ind + 1;
	ind_heel_strike = add_to_array(ind_heel_strike, min([hs_heel_ind hs_toe_ind]));
% 	rev_ind = find(norm_yz_heel_vel(foot_on_floor_ind:-1:1) > z_heel_vel_hs_thresh, 1, 'first');
% 	hs_heel_ind = foot_on_floor_ind - rev_ind + 1;
% 	rev_ind = find(norm_yz_toe_vel(foot_on_floor_ind:-1:1) > z_toe_vel_hs_thresh, 1, 'first');
% 	hs_toe_ind = foot_on_floor_ind - rev_ind + 1;
% 	ind_heel_strike = add_to_array(ind_heel_strike, min([hs_heel_ind hs_toe_ind]));
end


% convert inds to times
t_heel_strike = t(unique(ind_heel_strike));
t_toe_off = t(unique(ind_toe_off));

end

% ---------------------------------------------------------------------------
function new_array = add_to_array(old_array, new_val)
if isempty(old_array)
	new_array = new_val;
	return
end
if isempty(new_val)
	new_array = old_array;
else
	new_array = [old_array(1:end), new_val];
end
end

% ---------------------------------------------------------------------------
function [startPos] = find_span_start(logical_data, npts)
%logical_data is a logical array

if size(logical_data,1) > 1, logical_data = logical_data'; end % make it a row vector

%we thus want to calculate the difference between rising and falling edges
logical_data = [false, logical_data, false];  %pad with 0's at ends
edges = diff(logical_data);
rising = find(edges==1);     %rising/falling edges
falling = find(edges==-1);  
spanWidth = falling - rising;  %width of span of 1's (above threshold)
wideEnough = spanWidth >= npts;   
startPos = rising(wideEnough);    %start of each span
%endPos = falling(wideEnough)-1;   %end of each span
%all points which are in the npts span (i.e. between startPos and endPos).
%allInSpan = cell2mat(arrayfun(@(x,y) x:1:y, startPos, endPos, 'uni', false));  

end % find_span_start



