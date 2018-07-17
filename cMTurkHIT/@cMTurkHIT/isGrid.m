function [log] = isGrid(obj, names)
%isGrid True if names describe a grid of data
%   Detailed explanation goes here

log = false;

% Check if draft, trim coordinate vector given
[draft_v, draft_c] = idxVectFromName(names, obj.DraftName);
nDraft = max(draft_v);

[trim_v, trim_c] = idxVectFromName(names, obj.TrimName);
nTrim = max(trim_v);

if isempty(draft_v) || isempty(trim_v)
    return
end

name1 = strcat('Answer_', obj.DraftName, '_', draft_c);
name2 = strcat('Answer_', obj.TrimName, '_', trim_c);

draftM_c = repmat(draft_c(:)', nTrim, 1);
trimM_c = repmat(trim_c(:), 1, nDraft);
name3 = strcat('Answer_', obj.DraftName, '_', draftM_c, obj.TrimName, '_', trimM_c);
name3 = name3(:);

% Check if names are found
log = all(ismember(name1, names)) && all(ismember(name2, names)) && ...
    all(ismember(name3, names));

    function [idx, idxstr] = idxVectFromName(names, name)
        
        nameIdx_c = regexp(names, [name, '_[\d]+'], 'match');
        nameIdx_c = [nameIdx_c{:}];
        name_c = unique(nameIdx_c);
        idxstr = strrep(name_c, [name, '_'], '');
        name_v = cellfun(@str2double, idxstr);
        idx = max(name_v);
    end
end