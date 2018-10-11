function [names, varargout] = fileTableNames(tbl, name, varargin)
%fileTableNames Summary of this function goes here
%   Detailed explanation goes here

% Input
name = validateCellStr(name, 'cMTurkHIT.fileTableNames', 'name', 3);
validateattributes(name, {'cell'}, {});
% isGrid_l = obj.IsGrid;
names = tbl.Properties.VariableNames;

% if nargin > 3
%     
%     isGrid_l = varargin{1};
%     validateattributes(isGrid_l, {'logical'}, {'scalar'}, 'cMTurkHIT',...
%         'isGrid', 4);
% end

% Names are different for Displacement when data is grid
if numel(name) == 2 % strcmp(name, 'Displacement') && isGrid_l
    
    % Check if draft, trim coordinate vector given
    [draft_v, draft_c] = idxVectFromName(names, name{1});
    nDraft = max(draft_v);
    
    [trim_v, trim_c] = idxVectFromName(names, name{2});
    nTrim = max(trim_v);
    
    draftM_c = repmat(draft_c(:)', nTrim, 1);
    trimM_c = repmat(trim_c(:), 1, nDraft);
    dispM_c = strcat('Answer_', name{1}, '_', draftM_c, name{2}, '_', trimM_c);
    names = dispM_c(:);
    varargout{1} = draft_v;
    varargout{2} = trim_v;
    
elseif numel(name) == 1
    
    name = [name{:}];
    [val_v, idx_c] = idxVectFromName(names, name);
    names = strcat('Answer_', name, '_', idx_c);
    varargout{1} = val_v;
end

    function [name_v, idxstr] = idxVectFromName(names, name)
        
        nameIdx_c = regexp(names, [name, '_[\d]+'], 'match');
        nameIdx_c = [nameIdx_c{:}];
        name_c = unique(nameIdx_c);
        idxstr = strrep(name_c, [name, '_'], '');
        name_v = cellfun(@str2double, idxstr);
        idx = max(name_v);
    end
end