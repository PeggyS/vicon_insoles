function gc_info2db(app)
% send the data  table in the mysql database
%
%

% open connection to database
dbparams = get_db_login_params('tdcs_vgait');
dbtable = 'vicon_steps';
% % since this takes a while, display a waitbar
% hwb = waitbar(0, 'Sending Gait Info Data to the Database');

% update the waitbar
% waitbar(i/count, hwb);

add_to_database = true;
% check to see if this is already in the database

if app.caller_app.InDatabaseCheckBox.Value == 1   % data is in database
	answer = questdlg({'Info already in  database ' ; ...
		'Overwrite database with new info?'},'', 'No');
	if strcmp(answer, 'Yes')
		% delete old data from database
		try
			conn = dbConnect(dbparams.dbname, dbparams.user, dbparams.password, dbparams.serveraddr);
		catch
			disp('error connecting to database')
			return
		end
		
		% remove all the old data
		conn.dbDeleteRow(dbtable, 'subj', app.caller_app.subject, ...
					'data_collect', app.caller_app.session, ...
					'trial', app.caller_app.trial_num);
		conn.dbClose()
	else
		% don't overwrite data
		add_to_database = false;
	end
end

if add_to_database
	% add one row for each row in gc_data_tbl
	constInfo = {app.caller_app.subject app.caller_app.session ...
		app.caller_app.trial_num };
	const_colnames = {'subj', 'data_collect', 'trial'};
	var_list = app.gc_data_tbl.Properties.VariableNames;
	try
		conn = dbConnect(dbparams.dbname, dbparams.user, dbparams.password, dbparams.serveraddr);
	catch
		disp('error connecting to database')
		return
	end
	for cnt = 1:height(app.gc_data_tbl)
		values = constInfo;
		colnames = const_colnames;
		% do not include nans
		for vv = 1:length(var_list)
			var = var_list{vv};
			if ~isnan(app.gc_data_tbl.(var)(cnt))
				colnames = [colnames {var}];
				values = [values {app.gc_data_tbl.(var)(cnt)}];
			end
		end
		
		conn.dbAddRow(dbtable,colnames, values);
	end

	% select last_update from tdcs_vgait.vicon_steps where subj = 's2702tdvg' and data_collect = 'pre' and trial = 18;
	result = conn.dbSearch('vicon_steps', 'last_update',...
                           'subj', app.caller_app.subject, 'data_collect', app.caller_app.session, 'trial', app.caller_app.trial_num);
	% close the database
	conn.dbClose()
	
	app.caller_app.InDatabaseCheckBox.Value = 1;
	app.caller_app.DatabaseDateLabel.Text = result{1};
end % add_to_database


return

