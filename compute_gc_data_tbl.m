function gc_data_tbl = compute_gc_data_tbl(app, inv_hs_times, inv_to_times, uninv_hs_times, uninv_to_times)

% define inv and uninv sides
if strcmpi(app.caller_app.side(1), 'r')
	inv_side = 'r';
	uninv_side = 'l';
else
	inv_side = 'l';
	uninv_side = 'r';
end

% make sure there are enough hs & to times to compute a gait cycle.
if length(inv_hs_times) < 2 || isempty(inv_to_times) || ...
	length(uninv_hs_times) < 2 || isempty(uninv_to_times) 
	gc_data_tbl = table();
	return
end

% verify the uninv toe off is included in the 1st gait cycle. If not, use the
% next gait cycle as the first one
% uninv toe off
ind = find(uninv_to_times>inv_hs_times(1) & uninv_to_times<inv_hs_times(2));
if length(ind)<1      % no uninv toe off found in the 1st inv gait cycle
	% remove the 1st inv heel strike, so the gait cycles start at the 2nd
	% inv hs
	inv_hs_times = inv_hs_times(2:end);
end

% gait cycle times & event info
num_gcs = length(inv_hs_times)-1;
gc_beg_time = nan(num_gcs,1);
gc_end_time = nan(num_gcs,1);
involved_to_time = nan(num_gcs,1);
uninvolved_hs_time = nan(num_gcs,1);
uninvolved_to_time = nan(num_gcs,1);
involved_stride_length = nan(num_gcs,1);
uninvolved_stride_length = nan(num_gcs,1);
involved_step_length = nan(num_gcs,1);
uninvolved_step_length = nan(num_gcs,1);
involved_insole_max = nan(num_gcs,1);
involved_insole_mean = nan(num_gcs,1);
involved_insole_auc = nan(num_gcs,1);
ss_involved_insole_max = nan(num_gcs,1);
ss_involved_insole_mean = nan(num_gcs,1);
ss_involved_insole_auc = nan(num_gcs,1);
ds_loading_involved_insole_max = nan(num_gcs,1);
ds_loading_involved_insole_mean = nan(num_gcs,1);
ds_loading_involved_insole_auc = nan(num_gcs,1);
ds_unloading_involved_insole_max = nan(num_gcs,1);
ds_unloading_involved_insole_mean = nan(num_gcs,1);
ds_unloading_involved_insole_auc = nan(num_gcs,1);
ds_loading_uninvolved_insole_max = nan(num_gcs,1);
ds_loading_uninvolved_insole_mean = nan(num_gcs,1);
ds_loading_uninvolved_insole_auc = nan(num_gcs,1);
ds_unloading_uninvolved_insole_max = nan(num_gcs,1);
ds_unloading_uninvolved_insole_mean = nan(num_gcs,1);
ds_unloading_uninvolved_insole_auc = nan(num_gcs,1);
swing_uninvolved_insole_max = nan(num_gcs,1);
swing_uninvolved_insole_mean = nan(num_gcs,1);
swing_uninvolved_insole_auc = nan(num_gcs,1);

% step length info
h_inv_y = findobj(app.UIAxes_inv_heel, '-regexp', 'Tag', 'line_.*HEE_Y_mm'); % computer - door axis
h_inv_x = findobj(app.UIAxes_inv_heel, '-regexp', 'Tag', 'line_.*HEE_X_mm'); % offices - wall axis
h_uninv_y = findobj(app.UIAxes_uninv_heel, '-regexp', 'Tag', 'line_.*HEE_Y_mm'); % computer - door axis
h_uninv_x = findobj(app.UIAxes_uninv_heel, '-regexp', 'Tag', 'line_.*HEE_X_mm'); % offices - wall axis
% heel marker x & y data
heel.involved.x = h_inv_x.YData;
heel.involved.y = h_inv_y.YData;
heel.t = h_inv_x.XData;
heel.uninvolved.x = h_uninv_x.YData;
heel.uninvolved.y = h_uninv_y.YData;

% insole data
h_inv_insole = findobj(app.UIAxes_inv_insole, 'Tag', 'line_inv_fsr_est');
h_uninv_insole = findobj(app.UIAxes_uninv_insole, 'Tag', 'line_uninv_fsr_est');
insole.involved.t = h_inv_insole.XData;
insole.involved.force = h_inv_insole.YData;
insole.uninvolved.t = h_uninv_insole.XData;
insole.uninvolved.force = h_uninv_insole.YData;

for gc_cnt = 1:num_gcs
	gc_beg_time(gc_cnt) = inv_hs_times(gc_cnt);
	gc_end_time(gc_cnt) = inv_hs_times(gc_cnt+1);
	% inv to off
	ind = find(inv_to_times>inv_hs_times(gc_cnt) & inv_to_times<inv_hs_times(gc_cnt+1));
	if isempty(ind)
		% found no toe offs
		break
	end
	assert(length(ind)==1, 'involved %s side: found %d toe offs between %f and %f', ...
		inv_side, length(ind), inv_hs_times(gc_cnt), inv_hs_times(gc_cnt+1))
	involved_to_time(gc_cnt) = inv_to_times(ind);
	
	% uninv heel strike
	uninv_hs_ind = find(uninv_hs_times>inv_hs_times(gc_cnt) & uninv_hs_times<inv_hs_times(gc_cnt+1));
	assert(length(uninv_hs_ind)==1, 'uninvolved %s side: found %d heel strikes between %f and %f', ...
		uninv_side, length(uninv_hs_ind), inv_hs_times(gc_cnt), inv_hs_times(gc_cnt+1))
	uninvolved_hs_time(gc_cnt) = uninv_hs_times(uninv_hs_ind);
	
	% uninv toe off
	ind = find(uninv_to_times>inv_hs_times(gc_cnt) & uninv_to_times<inv_hs_times(gc_cnt+1));
	assert(length(ind)==1, 'uninvolved %s side: found %d toe offs between %f and %f', ...
		uninv_side, length(ind), inv_hs_times(gc_cnt), inv_hs_times(gc_cnt+1))
	uninvolved_to_time(gc_cnt) = uninv_to_times(ind);
	
	% involved stride length = distance between heel markers beginning & end of gc
	ind_gc_beg = find(heel.t >= gc_beg_time(gc_cnt), 1, 'first');
	ind_gc_end = find(heel.t >= gc_end_time(gc_cnt), 1, 'first');
	% distance = norm([y2-y1, x2-x1])
	involved_stride_length(gc_cnt) = norm([heel.involved.y(ind_gc_end)-heel.involved.y(ind_gc_beg) , ...
		heel.involved.x(ind_gc_end)-heel.involved.x(ind_gc_beg)]);
	
	% uninvolved stride length = distance between uninvolved heel markers on 2
	% consecutive heel strikes - the uninvolved stride may be the one before or
	% after the involved gait cycle
	if length(uninv_hs_times) > gc_cnt % if there will be an ending hs index
		ind_1st_hs = find(heel.t >= uninv_hs_times(gc_cnt), 1, 'first');
		ind_2nd_hs = find(heel.t >= uninv_hs_times(gc_cnt+1), 1, 'first');
		% distance = norm([y2-y1, x2-x1])
		uninvolved_stride_length(gc_cnt) = norm([heel.uninvolved.y(ind_2nd_hs)-heel.uninvolved.y(ind_1st_hs) , ...
			heel.uninvolved.x(ind_2nd_hs)-heel.uninvolved.x(ind_1st_hs)]);
	end

	% step length = distance between heels at heel strike 
	involved_step_length(gc_cnt) = norm([heel.involved.y(ind_gc_end)-heel.uninvolved.y(ind_gc_end) , ...
			heel.involved.x(ind_gc_end)-heel.uninvolved.x(ind_gc_end)]);
	t_ind_uninv_hs = find(heel.t >= uninv_hs_times(uninv_hs_ind), 1, 'first');
	uninvolved_step_length(gc_cnt) = norm([heel.uninvolved.y(t_ind_uninv_hs)-heel.involved.y(t_ind_uninv_hs) , ...
			heel.uninvolved.x(t_ind_uninv_hs)-heel.involved.x(t_ind_uninv_hs)]);

	% insole data
	% peak, mean, auc during entire inv stance phase
	% between gc_beg_time and involved_to_time 
	data = insole.involved.force(insole.involved.t >= gc_beg_time(gc_cnt) & insole.involved.t <= involved_to_time(gc_cnt));
	t = insole.involved.t(insole.involved.t >= gc_beg_time(gc_cnt) & insole.involved.t <= involved_to_time(gc_cnt));
	involved_insole_max(gc_cnt) = max(data);
	involved_insole_mean(gc_cnt) = mean(data);
	involved_insole_auc(gc_cnt) = trapz(t, data);
	% during single stance between uninvolved_to_time and uninvolved_hs_time
	data = insole.involved.force(insole.involved.t >= uninvolved_to_time(gc_cnt) & insole.involved.t <= uninvolved_hs_time(gc_cnt));
	t = insole.involved.t(insole.involved.t >= uninvolved_to_time(gc_cnt) & insole.involved.t <= uninvolved_hs_time(gc_cnt));
	ss_involved_insole_max(gc_cnt) = max(data);
	ss_involved_insole_mean(gc_cnt) = mean(data);
	ss_involved_insole_auc(gc_cnt) = trapz(t, data);
	% during double stance loading: between gc_beg_time and uninvolved_to_time
	data = insole.involved.force(insole.involved.t >= gc_beg_time(gc_cnt) & insole.involved.t <= uninvolved_to_time(gc_cnt));
	t = insole.involved.t(insole.involved.t >= gc_beg_time(gc_cnt) & insole.involved.t <= uninvolved_to_time(gc_cnt));
	ds_loading_involved_insole_max(gc_cnt) = max(data);
	ds_loading_involved_insole_mean(gc_cnt) = mean(data);
	ds_loading_involved_insole_auc(gc_cnt) = trapz(t, data);
	data = insole.uninvolved.force(insole.uninvolved.t >= gc_beg_time(gc_cnt) & insole.uninvolved.t <= uninvolved_to_time(gc_cnt));
	t = insole.uninvolved.t(insole.uninvolved.t >= gc_beg_time(gc_cnt) & insole.uninvolved.t <= uninvolved_to_time(gc_cnt));
	ds_loading_uninvolved_insole_max(gc_cnt) = max(data);
	ds_loading_uninvolved_insole_mean(gc_cnt) = mean(data);
	ds_loading_uninvolved_insole_auc(gc_cnt) = trapz(t, data);
	% during double stance unloading: between uninvolved_hs_time and involved_to_time
	data = insole.involved.force(insole.involved.t >= uninvolved_hs_time(gc_cnt) & insole.involved.t <= involved_to_time(gc_cnt));
	t = insole.involved.t(insole.involved.t >= uninvolved_hs_time(gc_cnt) & insole.involved.t <= involved_to_time(gc_cnt));
	ds_unloading_involved_insole_max(gc_cnt) = max(data);
	ds_unloading_involved_insole_mean(gc_cnt) = mean(data);
	ds_unloading_involved_insole_auc(gc_cnt) = trapz(t, data);
	data = insole.uninvolved.force(insole.uninvolved.t >= uninvolved_hs_time(gc_cnt) & insole.uninvolved.t <= involved_to_time(gc_cnt));
	t = insole.uninvolved.t(insole.uninvolved.t >= uninvolved_hs_time(gc_cnt) & insole.uninvolved.t <= involved_to_time(gc_cnt));
	ds_unloading_uninvolved_insole_max(gc_cnt) = max(data);
	ds_unloading_uninvolved_insole_mean(gc_cnt) = mean(data);
	ds_unloading_uninvolved_insole_auc(gc_cnt) = trapz(t, data);
	% during swing time: between involved_to_time and gc_end_time
	data = insole.uninvolved.force(insole.uninvolved.t >= involved_to_time(gc_cnt) & insole.uninvolved.t <= gc_end_time(gc_cnt));
	t = insole.uninvolved.t(insole.uninvolved.t >= involved_to_time(gc_cnt) & insole.uninvolved.t <= gc_end_time(gc_cnt));
	swing_uninvolved_insole_max(gc_cnt) = max(data);
	swing_uninvolved_insole_mean(gc_cnt) = mean(data);
	swing_uninvolved_insole_auc(gc_cnt) = trapz(t, data);
end

gc_data_tbl = table(gc_beg_time, gc_end_time, involved_to_time, uninvolved_hs_time, uninvolved_to_time, ...
				involved_stride_length, uninvolved_stride_length, involved_step_length, uninvolved_step_length, ...
				involved_insole_max, involved_insole_mean, involved_insole_auc, ...
				ss_involved_insole_max, ss_involved_insole_mean, ss_involved_insole_auc, ...
				ds_loading_involved_insole_max, ds_loading_involved_insole_mean, ds_loading_involved_insole_auc, ...
				ds_loading_uninvolved_insole_max, ds_loading_uninvolved_insole_mean, ds_loading_uninvolved_insole_auc, ...
				ds_unloading_involved_insole_max, ds_unloading_involved_insole_mean, ds_unloading_involved_insole_auc, ...
				ds_unloading_uninvolved_insole_max, ds_unloading_uninvolved_insole_mean, ds_unloading_uninvolved_insole_auc, ...
				swing_uninvolved_insole_max, swing_uninvolved_insole_mean, swing_uninvolved_insole_auc, ...
			'VariableNames',{'gc_beg', 'gc_end', 'involved_to', 'uninvolved_hs', 'uninvolved_to', ...
					'involved_stride_length', 'uninvolved_stride_length', 'involved_step_length', 'uninvolved_step_length', ...
					'involved_insole_max', 'involved_insole_mean', 'involved_insole_auc', ...
					'ss_involved_insole_max', 'ss_involved_insole_mean', 'ss_involved_insole_auc', ...
					'ds_loading_involved_insole_max', 'ds_loading_involved_insole_mean', 'ds_loading_involved_insole_auc', ...
					'ds_loading_uninvolved_insole_max', 'ds_loading_uninvolved_insole_mean', 'ds_loading_uninvolved_insole_auc', ...
					'ds_unloading_involved_insole_max', 'ds_unloading_involved_insole_mean', 'ds_unloading_involved_insole_auc', ...
					'ds_unloading_uninvolved_insole_max', 'ds_unloading_uninvolved_insole_mean', 'ds_unloading_uninvolved_insole_auc', ...
					'swing_uninvolved_insole_max', 'swing_uninvolved_insole_mean', 'swing_uninvolved_insole_auc'});

% some computed values
gc_data_tbl.gc_time = gc_data_tbl.gc_end - gc_data_tbl.gc_beg;
gc_data_tbl.swing_time = gc_data_tbl.gc_end - gc_data_tbl.involved_to;
gc_data_tbl.single_stance_time = gc_data_tbl.uninvolved_hs - gc_data_tbl.uninvolved_to;
gc_data_tbl.double_stance_loading_time = gc_data_tbl.uninvolved_to - gc_data_tbl.gc_beg;
gc_data_tbl.double_stance_unloading_time = gc_data_tbl.involved_to - gc_data_tbl.uninvolved_hs;



end