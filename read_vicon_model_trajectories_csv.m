function data = read_vicon_model_trajectories_csv(filename)

if ~exist(filename, 'file')
	error('%s does not exist', filename);
end

% read in the data
num_header_lines = 5;
try
	disp('readtable')
	data.tbl = readtable(filename, 'FileType', 'text', 'Delimiter', ',', 'HeaderLines', num_header_lines);
catch ME
	disp(ME)
	error('error reading in table')
end

% parse the header for the column names
% open the file
fid = fopen(filename, 'r', 'n', 'UTF-8');
data.filename = filename;
% read first line, it should be 'Model Outputs' or 'Trajectories'
txt = fgetl(fid);
assert(strcmp(txt, 'Model Outputs') || strcmp(txt, 'Trajectories'), 'Model Outpus or Trajectories is not the first line of the devices.csv file')

% read the next line, it should be the vicon sampling freq
txt = fgetl(fid);
data.samp_freq = str2double(txt);
% next 3 lines form the column labels of the following table
txt = fgetl(fid);
tmp = textscan(txt,'%s','Delimiter',',');
col_names = tmp{1}';
% turn col_names into valid table variable names
% 1st row:  		s2702tdvg:LAbsAnkleAngle			s2702tdvg:LAnkleAngles	
col_names = cellfun(@(x)regexprep(x, '^.*:', ''),col_names,'Uniformoutput',false); % remove subj number & :
col_names = cellfun(@(x)strrep(x, ' ', '_'),col_names,'Uniformoutput',false); % replace blank with underscores
% check each col name & if blank, repeat the previous col name
for c_cnt = 2:length(col_names)
	if ~isempty(col_names{c_cnt-1}) && isempty(col_names{c_cnt})
		col_names{c_cnt} = col_names{c_cnt-1};
	end
end

% 2nd row: Frame	Sub Frame	X Y Z ...X' Y' Z'
txt = fgetl(fid);
tmp = textscan(txt,'%s','Delimiter',',');
col2_names = tmp{1}';
col2_names = cellfun(@(x)strrep(x, ' ', '_'),col2_names,'Uniformoutput',false); % replace blank with underscores
col2_names = cellfun(@(x)strrep(x, '''''', '_acc'),col2_names,'Uniformoutput',false); % replace '' with acc
col2_names = cellfun(@(x)strrep(x, '''', '_vel'),col2_names,'Uniformoutput',false); % replace ' with vel

% 3rd row: units like: N mm.N
txt = fgetl(fid);
tmp = textscan(txt,'%s','Delimiter',',');
col3_names = tmp{1}';
col3_names = cellfun(@(x)strrep(x, ' ', '_'),col3_names,'Uniformoutput',false); % 
col3_names = cellfun(@(x)strrep(x, '.', ''),col3_names,'Uniformoutput',false); % remove dot 
col3_names = cellfun(@(x)strrep(x, '/', '_per_'),col3_names,'Uniformoutput',false); % replace /
col3_names = cellfun(@(x)strrep(x, '²', '_2'),col3_names,'Uniformoutput',false); % replace 
col3_names = cellfun(@(x)strrep(x, char(178), '_2'),col3_names,'Uniformoutput',false);
col3_names = cellfun(@(x)strrep(x, '³', '_3'),col3_names,'Uniformoutput',false); % replace 
col3_names = cellfun(@(x)strrep(x, '^4', '_4'),col3_names,'Uniformoutput',false); % replace 
col3_names = cellfun(@(x)strrep(x, '^5', '_5'),col3_names,'Uniformoutput',false); % replace 
% in 'Trajectories' section, the last column doesn't have a 3rd row value, add
% an empty string
if length(col3_names) < length(col_names)
	col3_names(end+1) = {''};
end


% info from the 3 rows into a single column name
col_names = cellfun(@(x,y)combine_names(x,y), col_names, col2_names, 'UniformOutput', false);
col_names = cellfun(@(x,y)combine_names(x,y), col_names, col3_names, 'UniformOutput', false);

% make sure number of col_names agrees with num cols in tbl
assert(length(col_names) == width(data.tbl), 'error parsing the col_names in %s', filename);
% set col names
data.tbl.Properties.VariableNames = col_names;
return


