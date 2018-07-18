function [log] = isGrid(obj, tbl)
%isGrid True if names describe a grid of data
%   Detailed explanation goes here

log = false;
names = tbl.Properties.VariableNames;

% % Check if draft, trim coordinate vector given
% [draft_v, draft_c] = idxVectFromName(names, obj.DraftName);
% nDraft = max(draft_v);
% 
% [trim_v, trim_c] = idxVectFromName(names, obj.TrimName);
% nTrim = max(trim_v);
% 
% if isempty(draft_v) || isempty(trim_v)
%     return
% end
% 
% name1 = strcat('Answer_', obj.DraftName, '_', draft_c);
% name2 = strcat('Answer_', obj.TrimName, '_', trim_c);
% 
% draftM_c = repmat(draft_c(:)', nTrim, 1);
% trimM_c = repmat(trim_c(:), 1, nDraft);
% name3 = strcat('Answer_', obj.DraftName, '_', draftM_c, obj.TrimName, '_', trimM_c);
% name3 = name3(:);

[name1] = obj.fileTableNames(tbl, 'Draft');
[name2] = obj.fileTableNames(tbl, 'Trim');

if isempty(name1) || isempty(name2)
    return
end
[name3] = obj.fileTableNames(tbl, 'Displacement', true);

% Check if names are found
log = all(ismember(name1, names)) && all(ismember(name2, names)) && ...
    all(ismember(name3, names));

end