function h = demo_datatip

    %// basic sample curve
    npts = 600 ;
    x = linspace(0,4*pi,npts) ;
    y = sin(x) ;

    %// plot
	
    h.fig = figure ;
    h.ax = axes;    %%subplot(2,1,1)
    h.plot = plot(x,y, '.') ;
	h.plot.Marker = 'none';
	h.plot.LineStyle = '-';
	h.plot.Tag = 'line_data';

% 	subplot(2,1,2)
% 	plot(x,y)

	% add menu to add vertical lines
	hcmenu = uicontextmenu;
	ud.hMenuHS = uimenu(hcmenu, 'Label', 'Add HS', 'Tag', 'menuAddHS', 'Callback', {@menuAddVline_Callback, h.ax});
	ud.hMenuTO = uimenu(hcmenu, 'Label', 'Add TO', 'Tag', 'menuAddTO', 'Callback', {@menuAddVline_Callback, h.ax});
	set(h.ax, 'UIContextMenu', hcmenu, 'UserData', ud);

    %// simulate some event times
    time_events = x([25 265 346]) ; %// events type 1 at index 25, 265 and 422

    %// define the target line for the new datatip
    hTarget = handle(h.plot);
	% change datatip template
	dtt = hTarget.DataTipTemplate;
	dtt.DataTipRows(1).Label = 't';

    %// Add the datatip array
    h.dtip = add_datatips( time_events , hTarget ) ;


function hdtip = add_datatips( evt_times , hTarget )
    %// retrieve the datacursor manager
    cursorMode = datacursormode(gcf);
%     set(cursorMode, 'UpdateFcn',@customDatatipFunction); %%, 'NewDataCursorOnClick',false);

    xdata = get(hTarget,'XData') ;
    ydata = get(hTarget,'YData') ;

    %// add the datatip for each event
    for idt = 1:numel(evt_times)
        hdtip(idt) = cursorMode.createDatatip(hTarget) ;
        set(hdtip(idt), 'MarkerSize',5, 'MarkerFaceColor','none', ...
                  'MarkerEdgeColor','r', 'Marker','o', 'HitTest','on');

        %// move it into the right place
        idx = find( xdata >= evt_times(idt), 1, 'first' ) ;%// find the index of the corresponding time
        pos = [xdata(idx) , ydata(idx) ,0 ];
		set(hdtip(idt), 'Position', pos)
%         updateDataCursors(cursorMode);
    end

function output_txt = customDatatipFunction(~,evt)
    pos = get(evt,'Position');
    idx = get(evt,'DataIndex');
    output_txt = { ...
        '*** !! Event !! ***' , ...
        ['at Time : '  num2str(pos(1),4)] ...
        ['Value: '   , num2str(pos(2),8)] ...
        ['Data index: ',num2str(idx)] ...
                };

function menuAddVline_Callback(hObject, ~, h_ax)
	% x position to add the event is at cursor position
	cursor_pos = get(h_ax, 'CurrentPoint');
	evt_time = cursor_pos(1);

	h_l = line([evt_time evt_time], h_ax.YLim);
	
	h_data_line = findobj(h_ax, 'Tag', 'line_data');
	dt = add_datatips(evt_time, h_data_line);

	h_l.UserData.datatip = dt;

	draggable(h_l, 'h',  @dragMotionFcn);

function dragMotionFcn(h_line)
	
	dt = h_line.UserData.datatip;
% 	disp(['vert line x = ' num2str(h_line.XData(1))])
	idx = find(dt.DataSource.XData >= h_line.XData(1), 1, 'first');
% 	disp(['setting dt.Position to ' num2str(dt.DataSource.XData(idx)) ' ' num2str(dt.DataSource.YData(idx))])
	dt.Position = [dt.DataSource.XData(idx) dt.DataSource.YData(idx) 0];
% 	disp/(dt.Position)



	