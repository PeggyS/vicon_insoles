function createInsoleLineCMenu(app, hLine, hText)
hcmenu = uicontextmenu;
ud = hLine.UserData;
% ud.hMenuDrag = uimenu(hcmenu, 'Label', 'Update Event Time', 'Tag', 'menuUpdateEvent', 'Callback', {@menuUpdateEvent_Callback, hLine});
ud.hMenuDrag = uimenu(hcmenu, 'Label', 'Draggable', 'Tag', 'menuDraggable', 'Callback', {@menuDraggable_Callback, hLine, app});
% ud.hMenuShow = uimenu(hcmenu, 'Label', 'Show Data Value', 'Tag', 'menuShowData', 'Callback', {@menuShowData_Callback, hLine, hText});
ud.hMenuShow = uimenu(hcmenu, 'Label', 'Delete Event', 'Tag', 'menuDeleteEvent', 'Callback', {@menuDeleteInsoleEvent_Callback, hLine});
% ud.hText = hText;		% also save the time text handle for quick access
ud.app = app;			% the app for access to everything
set(hLine, 'UIContextMenu', hcmenu, 'UserData', ud);
