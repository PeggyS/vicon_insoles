function move_cal_patch_line(h_line)

% keyboard
% patch to update is in line userdata
h_patch = h_line.UserData;

if contains(h_patch.Tag, 'left')
	% patch on the left of the interval
	h_patch.Vertices(3,1) = h_line.XData(1);
	h_patch.Vertices(4,1) = h_line.XData(1);
else
	% patch on the right of the interval
	h_patch.Vertices(1,1) = h_line.XData(1);
	h_patch.Vertices(2,1) = h_line.XData(1);
end

end % function