function check_database_gc_info(app)
% check the database for this data_collection and trial 

% open connection to database
dbparams = get_db_login_params('tdcs_vgait');

try
	conn = dbConnect(dbparams.dbname, dbparams.user, dbparams.password, dbparams.serveraddr);
catch
	warning('could not connect to database')
	return
end
% subjects in the db have full s27xxtdvg name
full_subj = app.subject;
if length(full_subj) < 9
	full_subj = strcat(subj, 'tdvg');
end

% check for this trial of data 
% select last_update from tdcs_vgait.vicon_steps where subj = 's2702tdvg' and data_collect = 'pre' and trial = 18;
result = conn.dbSearch('vicon_steps', 'last_update',...
                           'subj', full_subj, ...
					   'data_collect', app.session, ...
					   'trial', app.trial_num);
% close the database
conn.dbClose()

if ~isempty(result)
	app.InDatabaseCheckBox.Value = 1;
	app.DatabaseDateLabel.Text = result{1};
else
	app.InDatabaseCheckBox.Value = 0;
	app.DatabaseDateLabel.Text = '0000-00-00';
end


