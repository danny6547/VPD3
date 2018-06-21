function [inName, varargout] = inputName(obj, name, datalength, nameDim, varargin)
%inputName Summary of this function goes here
%   Detailed explanation goes here


% Make draft index vector
draft_l = ismember(name, obj.DraftName);
draftInNames_l = sum(draft_l) > 1;
if draftInNames_l
    
    nDraft = sum(draft_l);
else
    
    nDraft = datalength; % [nRow, nCol];
end
draftIdx_v = 1:max(nDraft);
% [nDraft, draftDimI] = max(nDraft);
% ones_v = ones(1, 2);
% ones_v(draftDimI) = nDraft;
% sizeDraft = ones_v;
% draftIdx_v = reshape(draftIdx_v, sizeDraft);

% Generate empty output
outSz_v = nan(1, 2);
nameDim_l = 1:2 == nameDim;
outSz_v(nameDim_l) = numel(name);
outSz_v(~nameDim_l) = datalength;
inName = cell(outSz_v);

% Convert to names, index and assign
vect2Names_f = @(x, n) strcat(n, '_', arrayfun(@num2str, x, 'Uni', 0));
draftIdx_c = vect2Names_f(draftIdx_v, obj.DraftName);
[~, draftName_i] = ismember('Draft', name);
varSubs_c = {':', ':'};
varSubs_c(nameDim) = { draftName_i };
inName(varSubs_c{:}) = draftIdx_c;

% Check if Trim in names
trim_l = ismember(name, obj.TrimName);
hasTrim_l = ismember(obj.TrimName, name);
if hasTrim_l
    
    nTrim = sum(trim_l);
    trimIdx_v = 1:nTrim;
    trimIdx_c = vect2Names_f(trimIdx_v, obj.TrimName);
    
    % Repeat trims to create grid
    if nTrim > 1
        
        trimIdxRep_c = repmat(trimIdx_c(:)', [nDraft, 1]);
    end
    
    if nDraft > 1
        
        draftIdxRep_c = repmat(draftIdx_c(:), [1, nTrim]);
    end
    
    % Combine vectors
    gridNameIdx_c = strcat(draftIdxRep_c, trimIdxRep_c);
    varSubs_c(nameDim) = { find(trim_l) };
    inName(varSubs_c{:}) = gridNameIdx_c;
% else
%     
%     inputNameIdx_c = draftIdx_c;
end

% Create other index vectors
other_l = ~trim_l & ~draft_l;
if any(other_l)
    
    other_c = name(other_l);

%     otherSize = sizeDraft;
%     otherDim_l = otherSize == 1;
%     otherSize(otherDim_l) = sum(other_l);
    outSz_v(nameDim_l) = sum(other_l);
    outSz_v(~nameDim_l) = datalength;
    otherIdx_c = cell(outSz_v);
    idx_c = {':', ':'};
    for oi = 1:numel(other_c)
        
        idx_c{nameDim} = oi;
        otherIdx_c(idx_c{:}) = vect2Names_f(draftIdx_v(:), other_c{oi});
    end
    
%     % Concatenate to existing
%     inputNameIdx_c = cat(otherDimI, inputNameIdx_c, otherIdx_c);
    
    % Assign into output
    [~, otherOrder_i] = ismember(other_c, name);
    varSubs_c(nameDim) = {otherOrder_i};
    inName(varSubs_c{:}) = otherIdx_c;
end

% Create grid edge vector
edge_c = {};
if hasTrim_l && nTrim > 1
    
    % Create names
    edge_c = trimIdx_c;
    
    % Orientate
    if isrow(draftIdx_v)
        edge_c = edge_c(:);
    else
        edge_c = edge_c(:)';
    end
end

% Assign outputs
% inName = inputNameIdx_c;
varargout{1} = edge_c;

% name = validateCellStr(name);
% 
% if nargin > 3
%     
%     rowname = validateCellStr(name);
%     colname = validateCellStr(varargin{1});
%     
%     rowname(cellfun(@isempty, rowname)) = {obj.DeafaultRowName};
%     colname(cellfun(@isempty, colname)) = {obj.DeafaultColumnName};
% %     if isempty(rowname)
% %         
% %         rowname = obj.DeafaultRowName;
% %     end
% %     if isempty(colname)
% %         
% %         colname = obj.DeafaultColumnName;
% %     end
%     
% %     colname = validateCellStr(colname);
%     nCol = varargin{2};
%     nRow = num;
%     
%     inNameIRow_m = repmat((1:nRow)', 1, nCol);
%     inNameICol_m = repmat((1:nCol), nRow, 1);
%     inNameIRow_c = arrayfun(@num2str, inNameIRow_m, 'Uni', 0);
%     inNameICol_c = arrayfun(@num2str, inNameICol_m, 'Uni', 0);
%     
%     inNameRow_c = repmat(rowname, nRow, nCol);
%     inNameCol_c = repmat(colname, nRow, nCol);
%     
%     inNameRow_c = strcat(inNameRow_c, inNameIRow_c);
%     inNameCol_c = strcat(inNameCol_c, inNameICol_c);
%     
%     inName = strcat(inNameRow_c, inNameCol_c);
%     inName = inName(:)';
% end