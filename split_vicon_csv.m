function split_vicon_csv(filename)
% SPLIT_VICON_CSV - take a vicon csv file with several data sections and save each section as a separate csv file
%
%

if ~exist(filename, 'file')
	error('%s does not exist', filename);
end

% check the file's date to decide what encoding to use when reading in
f_info = dir(filename);
cutoff_datenum = datenum(2019,12,01); % date defining the use of different encoding
if f_info.datenum >= cutoff_datenum
	encoding = 'UTF-8';
else
	encoding = 'ISO-8859-1';
end

% open the file
[fid, errmsg] = fopen(filename, 'r', 'n', encoding);
if fid < 0, disp(errmsg), return, end
[~,~,machinefmt,~] = fopen(fid);
% make encoding UTF-8 for saved files
encodingOut = 'UTF-8';

% read in 1st line
txt = fgetl(fid);
% remove wierd first character that seems to be present in vicon nexus
% 2.8.2 when exporting accelerations
if double(txt(1)) == 65279
	txt = txt(2:end);
end
	
while ischar(txt) % txt will change to -1 when end of file is reached
	
	% look for keywords: Events, Devices, Model Outputs
	switch txt
		case 'Events'
			disp('found Events')
		case 'Devices'
			disp('found Devices')
			end_txt = split_out(fid, 'Devices', strrep(filename, '.csv', '_devices.csv'), ...
				machinefmt, encodingOut);
		case 'Model Outputs'
			disp('found Model Outputs')
			end_txt = split_out(fid, 'Model Outputs', strrep(filename, '.csv', '_modeloutputs.csv'), ...
				machinefmt, encodingOut);
		case 'Trajectories'
			disp('found Trajectories')
			end_txt = split_out(fid, 'Trajectories', strrep(filename, '.csv', '_trajectories.csv'), ...
				machinefmt, encodingOut);
	end
	if ischar(end_txt) % end_txt will be -1 if end of file is reached
		% read in next line
		txt = fgetl(fid);
	else
		txt = end_txt;
	end
	
end
	
% close the file
fclose(fid);
return

% ------------------------------
function txt = split_out(fid_in, type, filename, machinefmt, encodingOut)
% open the output file
[fid_out, errmsg] = fopen(filename, 'w', machinefmt, encodingOut);
if fid_out < 0, error(errmsg), end

% write 'Devices' to beginning of outfile
fprintf(fid_out, '%s\n', type);
% read in each line & write to the output file until a blank line is
% reached
txt = fgetl(fid_in);
while(~isempty(txt) && ischar(txt))
	fprintf(fid_out, '%s\n', txt);
	txt = fgetl(fid_in);
end
fclose(fid_out);
return
