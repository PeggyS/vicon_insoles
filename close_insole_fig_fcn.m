function close_insole_fig_fcn(h_fig, evt, h_checkbox)

try
	% uncheck the checkbox
	h_checkbox.Value = false;
	
	remove_event_line_links(h_fig)
	
catch ME
	disp(ME)
end
delete(h_fig)
return