function [log] = isGrid(obj, names)
%isGrid True if names describe a grid of data
%   Detailed explanation goes here

% Create expected names
allNameIdx_c = regexp(names, '[\d]+$', 'match');
allNameIdx_c = cellfun(@(x) [x{:}], allNameIdx_c, 'Uni', 0);
allNameIdx_c(cellfun(@isempty, allNameIdx_c)) = [];

nameIdx_c = unique(allNameIdx_c);
name1 = strcat('Answer_', obj.DraftName, '_', nameIdx_c);
name2 = strcat('Answer_', obj.TrimName, '_', nameIdx_c);

% Check if names are found
log = all(ismember(name1, names)) && all(ismember(name2, names));
end