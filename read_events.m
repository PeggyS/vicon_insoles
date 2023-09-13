function out_struct = read_events(fname)
% read in the events from the text file that was created using write_struct

out_struct = struct();
% read in the file as text
txt = readtextfile(fname);
if isempty(txt)
	% nothing read in
	disp('no text to parse')
	return
end

% separate each line at the colon ':'
txt = cellfun(@(x)(regexp(x,':','split')), txt, 'uniformoutput', false);
txt = cellfun(@strtrim,txt, 'uniformoutput', false);		% remove extra spaces

% go through each line of text
for kk = 1:length(txt)
	% variable name is in the first cell, value is in the second
	out_struct.(txt{kk}{1}) = str2num(txt{kk}{2}); %#ok<ST2NM>
	
end

