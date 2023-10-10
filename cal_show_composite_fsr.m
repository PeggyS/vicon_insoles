function cal_show_composite_fsr(app, h_ax, side)
% h_ax = handle of axes to draw in
% side = 'left' or 'right'

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

composite_data = sum(all_fsr_data, 2);

% add y-axis on the left
yyaxis(h_ax, 'left')
ylabel(h_ax, 'Sum FSRs (V)')


l_tag = ['line_fsr_' lower(side(1)) '_composite'];

h_line = findobj(h_ax, 'Tag', l_tag);
if isgraphics(h_line)
	% update the existing line
	h_line.XData = t;
	h_line.YData = composite_data;
else
	% create the line
	line(h_ax, t, composite_data, 'Tag', l_tag);
end


end