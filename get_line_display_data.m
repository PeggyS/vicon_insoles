function val_str = get_line_display_data(h_vertical_line)

% find the visible data lines (lines with tags containing X, Y, or Z
h_data_lines = findobj(h_vertical_line.Parent, '-regexp', 'Tag', '.*(_(X)|(Y)|(Z)|(fsr)_).*', 'Visible','on');
% get the ydata at the xposition of h_vertical_line
val_str = cell(length(h_data_lines)+1,1);
val_str{1} = ['t = ' num2str(h_vertical_line.XData(1))];
for l_cnt = 1:length(h_data_lines)
	ind = find(h_data_lines(l_cnt).XData>=h_vertical_line.XData(1), 1);
	data = h_data_lines(l_cnt).YData(ind);
	val_str{l_cnt+1} = [strrep(h_data_lines(l_cnt).Tag, '_', ' ') ' = ' num2str(data)];
	
end