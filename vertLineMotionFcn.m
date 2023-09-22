function vertLineMotionFcn(hLine)
% as the vertical line moves, update the value text
% text handle is stored in the hLine's userdata

ud = get(hLine, 'UserData');
if isempty(ud) %%|| ~isfield(ud, 'hText')
	uiwait(warndlg({'vertLineMotionFcn'; ...
    	'Line user data or hText field is missing. This should not happen.'; ...
		'Please tell Peggy.'}, ...
        'Vicon Insoles', 'modal'));
	return
end
% oldPos = get(ud.hText, 'Position');
% xValue = get(hLine, 'XData');
% val_str = get_line_display_data(hLine);
% set(ud.hText, 'Position', [xValue(1) oldPos(2)], 'String', val_str);

% update the datatip
dt = hLine.UserData.datatip;
idx = find(dt.DataSource.XData >= hLine.XData(1), 1, 'first');
dt.Position = [dt.DataSource.XData(idx) dt.DataSource.YData(idx) 0];

% update the event struct (maybe remove from here and add to an endmove function FIXME)
update_hs_to_events(hLine)

