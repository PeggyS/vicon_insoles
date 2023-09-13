function devices = read_vicon_devices_csv(filename)

if ~exist(filename, 'file')
	error('%s does not exist', filename);
end

% read in the data
num_header_lines = 5;
try
% 	disp('readtable')
	devices.tbl = readtable(filename, 'FileType', 'text', 'Delimiter', ',', 'HeaderLines', num_header_lines);
catch ME
	disp(ME)
	error('error reading in table')
end

% parse the header for the column names
% open the file
fid = fopen(filename, 'r', 'n', 'UTF-8');
devices.filename = filename;
% read first line, it shold be 'Devices'
txt = fgetl(fid);
assert(strcmp(txt, 'Devices'), 'Devices is not the first line of the devices.csv file')

% read the next line, it should be the vicon sampling freq
txt = fgetl(fid);
devices.samp_freq = str2double(txt);

% next 3 lines form the column labels of the following table
txt = fgetl(fid);
tmp = textscan(txt,'%s','Delimiter',',');
col_names = tmp{1}';
% turn col_names into valid table variable names
% 1st row:  FP1 (3979) - Force
col_names = cellfun(@(x)strrep(x, ' - ', '_'),col_names,'Uniformoutput',false); % replace blank & dash with underscores
col_names = cellfun(@(x)regexprep(x, ' \(\d{4}\)', ''),col_names,'Uniformoutput',false); % remove parentheses & info in between
col_names = cellfun(@(x)strrep(x, ' ', '_'),col_names,'Uniformoutput',false); % replace any other blanks with underscores
% check each col name & if blank, repeat the previous col name
for c_cnt = 2:length(col_names)
	if ~isempty(col_names{c_cnt-1}) && isempty(col_names{c_cnt})
		col_names{c_cnt} = col_names{c_cnt-1};
	end
end

% 2nd row: Frame	Sub Frame	Fx	Fy ...
txt = fgetl(fid);
tmp = textscan(txt,'%s','Delimiter',',');
col2_names = tmp{1}';
col2_names = cellfun(@(x)strrep(x, ' ', '_'),col2_names,'Uniformoutput',false); % replace blank with underscores

% 3rd row: units like: N mm.N
txt = fgetl(fid);
tmp = textscan(txt,'%s','Delimiter',',');
col3_names = tmp{1}';
col3_names = cellfun(@(x)strrep(x, '.', ''),col3_names,'Uniformoutput',false); % remove dot 

% info from the 3 rows into a single column name
col_names = cellfun(@(x,y)combine_names(x,y), col_names, col2_names, 'UniformOutput', false);
col_names = cellfun(@(x,y)combine_names(x,y), col_names, col3_names, 'UniformOutput', false);

% make sure number of col_names agrees with num cols in tbl
assert(length(col_names) == width(devices.tbl), 'error parsing the col_names in %s', filename);
% set col names
devices.tbl.Properties.VariableNames = col_names;
return


% -----------------
function new_name = combine_names(name1, name2)
if isempty(name1)
	new_name = name2;
elseif isempty(name2)
	new_name = name1;
else
	new_name = [name1 '_' name2];
end
return

