function out_struct = read_struct(fname)

% read in the text file
txt = readtextfile(fname); 	% cell array of strings, one row for each line in the file

% separate each line at the colon ' : '
txt = split(txt, ' : ');

for row_cnt = 1:size(txt, 1)
	fld_name = txt{row_cnt, 1};
	try
		out_struct.(fld_name) = str2num(txt{row_cnt, 2}); %#ok<ST2NM> 
	catch
		out_struct.(fld_name) = txt{row_cnt, 2};
	end
end
