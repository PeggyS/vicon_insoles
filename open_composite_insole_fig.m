function open_composite_insole_fig(app, side)
% open a figure with the insole data

if ~isprop(app, 'vicon_data') 
	disp('No Vicon data available')
	return
end

if ~isfield(app.vicon_data, 'devices')
	disp('No Insole data to display')
	return
end

fig_str = ['figure_insole_' lower(side) '_composite'];
fig_pos = [1 152 2560 800];

% insole figure is saved in the main app app
app.(fig_str) = figure('Pos', fig_pos, 'Tag', fig_str, 'Name', [side ' Composite FSR Insole']);


% time 
% Frame = sec/100; Sub_Frame = milliseconds after the frame
t = app.vicon_data.devices.tbl.Frame / 100 + app.vicon_data.devices.tbl.Sub_Frame/1000;

% plot the 8 sensors data summed together
fsr_list = {'Lat_Heel', 'Med_Heel', 'Lat_Instep', 'Lat_MT', 'Center_MT', 'Med_MT', 'Lat_Toe', 'Med_Toe'};
all_fsr_data = nan(length(t), length(fsr_list));
% discover what the fsr variable name prefix is
var_prefix = find_fsr_var_prefix(app.vicon_data.devices.tbl);
for cnt = 1:8
	fsr_var = [var_prefix upper(side(1)) '_' fsr_list{cnt} '_V'];
	all_fsr_data(:,cnt) = app.vicon_data.devices.tbl.(fsr_var);
end

fsr_composite_data_V = sum(all_fsr_data, 2);
% use the calibration info to approximate force from the fsr voltage
if ~isempty(app.coeff)
	composite_force_est = polyval(app.coeff.(lower(side)), fsr_composite_data_V);
end

% create uicontrols
create_uicontrols(app.(fig_str), app)


h_ax = axes;
h_ax.Tag = ['axes_' lower(side(1)) '_composite'];
yyaxis(h_ax, 'left')
create_axes_CMenu(h_ax)
% force estimate line
h_force_line = plot(t, composite_force_est, ...
	'Tag', ['line_fsr_' lower(side(1)) '_force_est']);
ylabel('Foot Z-force Estimate')
title(side)
xlabel('Time (s)')

% change the datatip template for the force line
dtt = h_force_line.DataTipTemplate;
dtt.DataTipRows(1).Label = 'time';
dtt.DataTipRows(2).Label = 'force';

% fsr voltage line
% use the scale on the right side of axes
yyaxis(h_ax, 'right')
plot(t, fsr_composite_data_V, 'Tag', ['line_fsr_' lower(side(1)) '_composite_V'])
ylabel('Composite FSR (V)')

% add threshold line
if isfield(app.fsr_event_threshold_struct, lower(side))
	thresh = app.fsr_event_threshold_struct.(lower(side));
else
	thresh = (max(composite_force_est) - min(composite_force_est)) * 0.1 + min(composite_force_est);
end
ed_obj = findobj(app.(fig_str), 'Tag', 'threshold_edit');
ed_obj.String = num2str(thresh);
yyaxis(h_ax, 'left')
h_l = line(h_ax.XLim, [thresh thresh], 'Color', 'k', 'Tag', 'line_threshold');
draggable(h_l, 'vertical', 'endfcn', @thresh_line_endfcn);

% if not already read in from file, or present, compute hs & to events from thresh
if isempty(app.event_struct)
	keyboard
	compute_insole_events(app, side, 'hs', thresh)
	compute_insole_events(app, side, 'to', thresh)
else
	if ~isfield(app.event_struct, [lower(side(1)), 'hs'])
		keyboard
		compute_insole_events(app, side, 'hs', thresh)
	elseif isempty(app.event_struct.([lower(side(1)), 'hs']).times)
		compute_insole_events(app, side, 'hs', thresh)
	end
	if ~isfield(app.event_struct, [lower(side(1)), 'to'])
		compute_insole_events(app, side, 'to', thresh)
	elseif isempty(app.event_struct.([lower(side(1)), 'to']).times)
		compute_insole_events(app, side, 'to', thresh)
	end
end

% update axis xmin and xmax values in edit boxes
ed_obj = findobj(app.(fig_str), 'Tag', 'edit_axes_min');
ed_obj.String = num2str(h_ax.XLim(1));
ed_obj = findobj(app.(fig_str), 'Tag', 'edit_axes_max');
ed_obj.String = num2str(h_ax.XLim(2));

% Add listener to axes' 'XLim' 'PostSet' event (so it fires after axes
% change).  Update the xmin and xmax values shown in edit boxes as the axis
% limits change.
addlistener(h_ax(1),'XLim','PostSet',@(~,~)xlimListenerFcn(h_ax));

% create close function callback to uncheck the box in the app window and
% remove linkprops
checkbox_var = [upper(side(1)) lower(side(2:end)) 'InsoleCompositeCheckBox'];
app.(fig_str).CloseRequestFcn = {@close_insole_fig_fcn, app.(checkbox_var)};

return

% ---------------------------
function create_uicontrols(h_fig, app)
if app.NoEEGdataCheckBox.Value == 1
	enable = 'off';
else
	enable = 'on';
end
uicontrol(h_fig, ...
		'Style', 'checkbox', ...
		'Tag', 'show_eeg_events_chkbx', ...
		'String', {'Show EEG Events'}, ...
		'Units', 'normalized', ...
		'Position', [0.0187,0.95,0.2,0.0166], ...
		'FontSize', 12, ...
		'Value', 0, ...
		'Enable', enable, ...
		'Callback', {@pb_show_eeg_events_callback, app});


uicontrol(h_fig, ...
		'Style', 'checkbox', ...
		'Tag', 'show_hs_lat_chkbx', ...
		'String', {'Show HS'}, ...
		'Units', 'normalized', ...
		'Position', [0.0187,0.145,0.094,0.0166], ...
		'FontSize', 9, ...
		'Value', 0, ...
		'Callback', {@pb_show_insole_events_callback, 'hs_lat', app});

% uicontrol(h_fig, ...
% 		'Style', 'edit', ...
% 		'Tag', 'hs_threshold_edit', ...
% 		'String', {'0'}, ...
% 		'Units', 'normalized', ...
% 		'Position', [0.0187,0.80,0.0588,0.0166], ...
% 		'FontSize', 9, ...
% 		'Value', 0, ...
% 		'Callback', {@edit_threshold_callback, 'hs_med', app});


uicontrol(h_fig, ...
		'Style', 'checkbox', ...
		'Tag', 'show_to_med_bp', ...
		'String', {'Show TO'}, ...
		'Units', 'normalized', ...
		'Position', [0.0187,0.107,0.094,0.0166], ...
		'FontSize', 9, ...
		'Value', 0, ...
		'Callback', {@pb_show_insole_events_callback, 'to_med', app});
uicontrol(h_fig, ...
		'Style', 'edit', ...
		'Tag', 'threshold_edit', ...
		'String', {'20'}, ...
		'Units', 'normalized', ...
		'Position', [0.0187,0.179,0.0588,0.0166], ...
		'FontSize', 9, ...
		'Value', 0, ...
		'Callback', {@edit_threshold_callback, 'composite', app});


	
uicontrol(h_fig, ...
		'Style', 'pushbutton', ...
		'Tag', 'save_events_pb', ...
		'String', {'Save Events'}, ...
		'Units', 'normalized', ...
		'Position', [0.0187,0.025,0.2,0.03], ...
		'FontSize', 14, ...
		'Callback', {@pb_save_events_callback, h_fig, app});

uicontrol(h_fig, ...
		'Style', 'edit', ...
		'Tag', 'edit_axes_min', ...
		'String', {'0'}, ...
		'Units', 'normalized', ...
		'Position', [0.1,0.07,0.0588,0.0166], ...
		'FontSize', 9, ...
		'Value', 0, ...
		'Callback', {@edit_axes_change_callback, 'x_min'});

uicontrol(h_fig, ...
		'Style','text', ...
		'String', {'x min ='}, ...
		'Units', 'normalized', ...
		'Position', [0.05 0.075 0.05 0.0166], ...
		'FontSize', 10)

uicontrol(h_fig, ...
		'Style', 'edit', ...
		'Tag', 'edit_axes_max', ...
		'String', {'0'}, ...
		'Units', 'normalized', ...
		'Position', [0.9,0.07,0.0588,0.0166], ...
		'FontSize', 9, ...
		'Value', 0, ...
		'Callback', {@edit_axes_change_callback, 'x_max'});

uicontrol(h_fig, ...
		'Style','text', ...
		'String', {'x max ='}, ...
		'Units', 'normalized', ...
		'Position', [0.85 0.075 0.05 0.0166], ...
		'FontSize', 10)

return

% ----------------------------
function create_axes_CMenu(h_ax)
hcmenu = uicontextmenu;
ud.hMenuDrag = uimenu(hcmenu, 'Label', 'Add HS', 'Tag', 'menuAddHS', 'Callback', {@menuAddEvent_Callback, h_ax});
ud.hMenuShow = uimenu(hcmenu, 'Label', 'Add TO', 'Tag', 'menuAddTO', 'Callback', {@menuAddEvent_Callback, h_ax});

set(h_ax, 'UIContextMenu', hcmenu, 'UserData', ud);
return

% -----------------------------
function xlimListenerFcn(h_ax)
h_edit = findobj(h_ax.Parent, 'Tag', 'edit_axes_min');
if ~isempty(h_edit)
	h_edit.String = {num2str(h_ax.XLim(1))};
end
h_edit = findobj(h_ax.Parent, 'Tag', 'edit_axes_max');
if ~isempty(h_edit)
	h_edit.String = {num2str(h_ax.XLim(2))};
end
return

% -----------------------------
function edit_axes_change_callback(source, ~, min_or_max)
h_fig = source.Parent;
h_ax = findobj(h_fig, '-regexp', 'Tag', '^axes_.*');
xlims = h_ax(1).XLim;
xdiff = diff(xlims);
if strcmp(min_or_max, 'x_min')
	xmin = str2double(source.String);
	if xmin > xlims(2)
		xlims =  [xmin xmin+xdiff] ;
	else
		xlims(1) = xmin;
	end
else
	xmax = str2double(source.String);
	if xmax < xlims(1)
		xlims = [xmax-xdiff xmax];
	else
		xlims(2) = xmax;
	end
end
h_ax(1).XLim = xlims;
return
