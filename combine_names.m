function new_name = combine_names(name1, name2)
if isempty(name1)
	new_name = name2;
elseif isempty(name2)
	new_name = name1;
else
	new_name = [name1 '_' name2];
end
return
