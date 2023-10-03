function line_delete_dt_fcn(h_line, ~)

if isfield(h_line.UserData, 'datatip')
	delete(h_line.UserData.datatip)
end

end