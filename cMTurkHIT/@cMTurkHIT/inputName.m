function [inName, varargout] = inputName(obj, name, datalength, nameDim)
%inputName Summary of this function goes here
%   Detailed explanation goes here


% Make draft index vector
draft_l = ismember(name, obj.CoordinateName1);
draftInNames_l = sum(draft_l) > 1;
if draftInNames_l
    
    nDraft = sum(draft_l);
else
    
    nDraft = datalength;
end
draftIdx_v = 1:max(nDraft);

% Generate empty output
outSz_v = nan(1, 2);
nameDim_l = 1:2 == nameDim;
outSz_v(nameDim_l) = numel(name);
outSz_v(~nameDim_l) = datalength;
inName = cell(outSz_v);

% Convert to names, index and assign
vect2Names_f = @(x, n) strcat(n, '_', arrayfun(@num2str, x, 'Uni', 0));
draftIdx_c = vect2Names_f(draftIdx_v, obj.CoordinateName1);
[~, draftName_i] = ismember(obj.CoordinateName1, name);
varSubs_c = {':', ':'};
varSubs_c(nameDim) = { draftName_i };
inName(varSubs_c{:}) = draftIdx_c;

% Check if Trim in names
trim_l = ismember(name, obj.CoordinateName2);
hasTrim_l = ismember(obj.CoordinateName2, name);
if hasTrim_l
    
    nTrim = sum(trim_l);
    trimIdx_v = 1:nTrim;
    trimIdx_c = vect2Names_f(trimIdx_v, obj.CoordinateName2);
    
    % Repeat trims to create grid
    if nTrim > 1 && nDraft > 1
        
        trimIdxRep_c = repmat(trimIdx_c(:)', [nDraft, 1]);
        draftIdxRep_c = repmat(draftIdx_c(:), [1, nTrim]);
        
        % Combine vectors
        gridNameIdx_c = strcat(draftIdxRep_c, trimIdxRep_c);
        varSubs_c(nameDim) = { find(trim_l) };
        if nameDim == 1

            gridNameIdx_c = gridNameIdx_c';
        end
        inName(varSubs_c{:}) = gridNameIdx_c;
    else
        
        % Draft and trim are both given as columns in a table
        trimIdxRep_c = vect2Names_f(draftIdx_v, obj.CoordinateName2);
        varSubs_c(nameDim) = { find(trim_l) };
        inName(varSubs_c{:}) = trimIdxRep_c;
    end
end

% Create other index vectors
other_l = ~trim_l & ~draft_l;
if any(other_l)
    
    other_c = name(other_l);
    outSz_v(nameDim_l) = sum(other_l);
    outSz_v(~nameDim_l) = datalength;
    otherIdx_c = cell(outSz_v);
    idx_c = {':', ':'};
    for oi = 1:numel(other_c)
        
        idx_c{nameDim} = oi;
        otherIdx_c(idx_c{:}) = vect2Names_f(draftIdx_v(:), other_c{oi});
    end
    
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
    if nameDim == 1
        edge_c = edge_c(:);
    else
        edge_c = edge_c(:)';
    end
end

% Assign outputs
varargout{1} = edge_c;