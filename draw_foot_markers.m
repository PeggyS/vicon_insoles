function draw_foot_markers(app)

% define inv and uninv sides
if strcmpi(app.caller_app.side(1), 'r')
	inv_side = 'r';
	uninv_side = 'l';
	inv_side_long = 'right';
	uninv_side_long = 'left';
else
	inv_side = 'l';
	uninv_side = 'r';
	inv_side_long = 'left';
	uninv_side_long = 'right';
end

% marker data
m_data = app.caller_app.vicon_data.markers.tbl;
% marker time vector
m_time = m_data.Frame / app.caller_app.vicon_data.markers.samp_freq;

% insole time 
% Frame = sec/100; Sub_Frame = milliseconds after the frame
i_time = app.caller_app.vicon_data.devices.tbl.Frame / 100 + app.caller_app.vicon_data.devices.tbl.Sub_Frame/1000;

% plot the 8 sensors data summed together
fsr_list = {'Lat_Heel', 'Med_Heel', 'Lat_Instep', 'Lat_MT', 'Center_MT', 'Med_MT', 'Lat_Toe', 'Med_Toe'};
inv_fsr_data = nan(length(i_time), length(fsr_list));
uninv_fsr_data = nan(length(i_time), length(fsr_list));
% discover what the fsr variable name prefix is
var_prefix = find_fsr_var_prefix(app.caller_app.vicon_data.devices.tbl);
for cnt = 1:8
	inv_fsr_var = [var_prefix upper(inv_side) '_' fsr_list{cnt} '_V'];
	inv_fsr_data(:,cnt) = app.caller_app.vicon_data.devices.tbl.(inv_fsr_var);
	uninv_fsr_var = [var_prefix upper(uninv_side) '_' fsr_list{cnt} '_V'];
	uninv_fsr_data(:,cnt) = app.caller_app.vicon_data.devices.tbl.(uninv_fsr_var);
end


inv_fsr_composite_data_V = sum(inv_fsr_data, 2);
% use the calibration info to approximate force from the fsr voltage
if ~isempty(app.caller_app.coeff)
	inv_composite_force_est = polyval(app.caller_app.coeff.(inv_side_long), inv_fsr_composite_data_V);
end

uninv_fsr_composite_data_V = sum(uninv_fsr_data, 2);
% use the calibration info to approximate force from the fsr voltage
if ~isempty(app.caller_app.coeff)
	uninv_composite_force_est = polyval(app.caller_app.coeff.(uninv_side_long), uninv_fsr_composite_data_V);
end


% axes - involved heel
var = [upper(inv_side) 'HEE_Z_mm'];
line(app.UIAxes_inv_heel, m_time, m_data.(var),...
	'Tag', ['line_' var])
var = strrep(var, 'Z', 'Y');
line(app.UIAxes_inv_heel, m_time, m_data.(var),...
	'Tag', ['line_' var], 'Visible', 'off')
var = strrep(var, 'Y', 'X');
line(app.UIAxes_inv_heel, m_time, m_data.(var),...
	'Tag', ['line_' var], 'Visible', 'off')

% involved fsr
line(app.UIAxes_inv_toe, i_time, inv_composite_force_est,...
	'Tag', 'line_inv_fsr_est')


% axes - uninvolved heel
var = [upper(uninv_side) 'HEE_Z_mm'];
line(app.UIAxes_uninv_heel, m_time, m_data.(var),...
	'Tag', ['line_' var])
var = strrep(var, 'Z', 'Y');
line(app.UIAxes_uninv_heel, m_time, m_data.(var),...
	'Tag', ['line_' var], 'Visible', 'off')
var = strrep(var, 'Y', 'X');
line(app.UIAxes_uninv_heel, m_time, m_data.(var),...
	'Tag', ['line_' var], 'Visible', 'off')

% uninvolved fsr
line(app.UIAxes_uninv_toe, i_time, uninv_composite_force_est,...
	'Tag', 'line_uninv_fsr_est')


end % function