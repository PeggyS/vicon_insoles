function thresh_line_endfcn(h_line)

% update the threshold edit box with the new value of the dragged line
ed_obj = findobj(h_line.Parent.Parent, 'Tag', 'threshold_edit');
ed_obj.String = num2str(h_line.YData(1));

% use the threshold_edit callback to updat the events and lines
edit_threshold_callback(ed_obj, [], 'composite', [])