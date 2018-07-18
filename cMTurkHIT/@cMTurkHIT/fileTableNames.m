function [names] = fileTableNames(obj, tbl, name, varargin)
%fileTableNames Summary of this function goes here
%   Detailed explanation goes here

isGrid_l = obj.IsGrid;
names = tbl.Properties.VariableNames;

if nargin > 3
    
    isGrid_l = varargin{1};
    validateattributes(isGrid_l, {'logical'}, {'scalar'}, 'cMTurkHIT',...
        'isGrid', 4);
end

% Names are different for Displacement when data is grid
if strcmp(name, 'Displacement') && isGrid_l

    % Check if draft, trim coordinate vector given
    [draft_v, draft_c] = idxVectFromName(names, obj.DraftName);
    nDraft = max(draft_v);

    [trim_v, trim_c] = idxVectFromName(names, obj.TrimName);
    nTrim = max(trim_v);

    draftM_c = repmat(draft_c(:)', nTrim, 1);
    trimM_c = repmat(trim_c(:), 1, nDraft);
    dispM_c = strcat('Answer_', obj.DraftName, '_', draftM_c, obj.TrimName, '_', trimM_c);
    names = dispM_c(:);
else

    [~, idx_c] = idxVectFromName(names, name);
    names = strcat('Answer_', name, '_', idx_c);
end

    function [idx, idxstr] = idxVectFromName(names, name)
        
        nameIdx_c = regexp(names, [name, '_[\d]+'], 'match');
        nameIdx_c = [nameIdx_c{:}];
        name_c = unique(nameIdx_c);
        idxstr = strrep(name_c, [name, '_'], '');
        name_v = cellfun(@str2double, idxstr);
        idx = max(name_v);
    end
end