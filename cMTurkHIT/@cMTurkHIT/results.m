function [obj, tbl] = results(obj, varargin)
%results Parse results from out file
%   Detailed explanation goes here

filename = obj.outName;
if nargin > 1
    
    % Take input file
    filename = varargin{1};
    validateattributes(filename, {'char'}, {'vector'}, 'cMTurkHIT.results',...
        'filename', 2);
end

% Prep
% obj.prepareOutputFile;

% Read data part of file
% file_tbl = readtable(filename, 'ReadVariableNames', true, 'Delimiter', ',');
nCol = 91;
file_c = cell(1, nCol);
fid = fopen(filename, 'r');
hi = 1;
while ~feof(fid)
    
    if hi == 1
        
        temp_cc = textscan(fid, '%q', nCol+2, 'Delimiter', ',');
        colNames = [temp_cc{:}(1:end-2)];
    else
        
        temp_cc = textscan(fid, '%q', nCol, 'Delimiter', ',');
        file_c(hi - 1, :) = [temp_cc{:}];
    end
    hi = hi + 1;
end
fclose(fid);

% Create table from cell
colNames = strrep(colNames, '.', '_');
file_tbl = cell2table(file_c, 'VariableNames', colNames);

% Filter rejects
reject_l = strcmp(file_tbl.AssignmentStatus, 'Rejected');
file_tbl(reject_l, :) = [];
nHIT = height(file_tbl);

% Get answers
colNames = file_tbl.Properties.VariableNames;
answer_l = contains(colNames, 'Answer_');
answerNames = colNames(answer_l);
answer_tbl = file_tbl(:, answer_l);

% Convert to numeric with NaN
answerTbl_c = table2cell(answer_tbl);
answerTbl_m = cellfun(@str2double, answerTbl_c);
answer_tbl = array2table(answerTbl_m, ...
    'VariableNames', answer_tbl.Properties.VariableNames);

% Get draft vector


% Get trim
trimAnswerName_ch = ['Answer_', obj.TrimName];
draftAnswerName_ch = ['Answer_', obj.DraftName];
trim_l = contains(answerNames, trimAnswerName_ch);
isGrid_l = any(trim_l);

if isGrid_l
    
    % Save into object
    obj.IsGrid = isGrid_l;
    
    % Get edge values
    draftEdgeTemp_l = regexp(answerNames, [draftAnswerName_ch, '_\d+$']);
    draftEdge_l = ~cellfun(@isempty, draftEdgeTemp_l);
    trimEdge_l = trim_l;
    draftEdge_c = answerNames(draftEdge_l);
    trimEdge_c = answerNames(trim_l);
    draftEdgeIdx_c = regexp(draftEdge_c, [draftAnswerName_ch, '_\d+'], 'match');
    trimEdgeIdx_c = regexp(trimEdge_c, [trimAnswerName_ch, '_\d+'], 'match');
    draftEdgeIdx_v = [draftEdgeIdx_c{:}];
    trimEdgeIdx_v = [trimEdgeIdx_c{:}];
    [~, sortAscDraftIdx_v] = sort(draftEdgeIdx_v);
    [~, sortAscTrimIdx_v] = sort(trimEdgeIdx_v);
    
    % Get displacement matrix
    gridNamePattern_ch = ['Answer_', obj.DraftName, '_[\d]+', ...
        obj.TrimName, '_[\d]+'];
    gridNamePattern_c = regexp(answerNames, gridNamePattern_ch);
    disp_l = ~cellfun(@isempty, gridNamePattern_c);
    displacement = answer_tbl{:, disp_l};
    
    % Get edge vector indices
    gridNames_c = answerNames(disp_l);
    gridIdx_cc = regexp(gridNames_c(:), '[\d]+', 'match');
    [draftIdx_c, trimIdx_c] = cellfun(@(x) x{:}, gridIdx_cc, 'Uni', 0);
    draftIdx_v = cellfun(@str2double, draftIdx_c);
    trimIdx_v = cellfun(@str2double, trimIdx_c);
    
    nGrid = sum(disp_l);
    draft = nan(nHIT, nGrid);
    trim = nan(nHIT, nGrid);
    for hi = 1:nHIT
        
        % Get edge vector values, sorted in ascending order
        draftVal_v = [answer_tbl{hi, draftEdge_l}];
        draftVal_v = draftVal_v(sortAscDraftIdx_v);
        trimVal_v = [answer_tbl{hi, trimEdge_l}];
        trimVal_v = trimVal_v(sortAscTrimIdx_v);
        
        % Index the sorted edge vectors with the corresponding grid entry
        draft(hi, :) = draftVal_v(draftIdx_v);
        trim(hi, :) = trimVal_v(trimIdx_v);
    end
    
    % Create table
    tbl = table(draft(:), trim(:), displacement(:), ...
        'VariableNames', {'Draft', 'Trim', 'Displacement'});
end

obj.FileData = tbl;

end