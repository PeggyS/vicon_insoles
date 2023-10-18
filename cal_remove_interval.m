function cal_remove_interval(app, side)

side_txt = side;
side_txt(1) = upper(side_txt(1));
axes_txt = ['UIAxesData' side_txt];

h_ax = app.(axes_txt);

% remove patches and lines
h_obj = findobj(h_ax, 'Tag', 'left_patch');
if ~isempty(h_obj), delete(h_obj), end

h_obj = findobj(h_ax, 'Tag', 'cal_patch_left_side');
if ~isempty(h_obj), delete(h_obj), end

h_obj = findobj(h_ax, 'Tag', 'right_patch');
if ~isempty(h_obj), delete(h_obj), end

h_obj = findobj(h_ax, 'Tag', 'cal_patch_right_side');
if ~isempty(h_obj), delete(h_obj), end

end % function