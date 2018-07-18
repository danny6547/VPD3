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

if exist(filename, 'file') ~= 2
    
    errid = 'ParseError:FileNotFound';
    errmsg = 'Output CSV file is expected to be found in ''Output'' sub-folder';
    error(errid, errmsg);
end

% Read data part of file
fid = fopen(filename, 'r');
tempScan_c = textscan(fid, '%s', 1, 'Delimiter', '\n');
colNames_cc = textscan([tempScan_c{1}{:}], '%q', inf, 'Delimiter', ',');
colNames = colNames_cc{1}(1:end-2);

nCol = length(colNames);
file_c = cell(1, nCol);
hi = 1;
while ~feof(fid)
    
    temp_ch = fgetl(fid);
    temp_cc = textscan(temp_ch, '%q', nCol, 'Delimiter', ',');
    line_c = [temp_cc{:}];
    if isempty(line_c)
        
        continue
    end
    file_c(hi, :) = line_c;
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

% Save into object
isGrid_l = obj.isGrid(answer_tbl);
obj.IsGrid = isGrid_l;

% Convert to numeric with NaN
% answerTbl_c = table2cell(answer_tbl);
answerTbl_c = obj.applyFunc(answer_tbl);
answerTbl_m = cellfun(@str2double, answerTbl_c);
answer_tbl = array2table(answerTbl_m, ...
    'VariableNames', answer_tbl.Properties.VariableNames);

% Get draft vector


% Get trim
trimAnswerName_ch = ['Answer_', obj.TrimName];
draftAnswerName_ch = ['Answer_', obj.DraftName];
trim_l = contains(answerNames, trimAnswerName_ch);

% Data is gridded even if layout was table

if isGrid_l
    
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
    
    % Assign numbers of edge vectors
    obj.nDraft = numel(draftIdx_v);
    obj.nTrim = numel(trimIdx_v);
    
    nGrid = sum(disp_l);
    draft = nan(nHIT, nGrid);
    trim = nan(nHIT, nGrid);
    for hi = 1:nHIT
        
        % Get edge vector values, sorted in ascending order
        draftVal_v = [answer_tbl{hi, draftEdge_l}];
        draftVal_v = draftVal_v(sortAscDraftIdx_v);
        draftVal_v = sort(draftVal_v);
        trimVal_v = [answer_tbl{hi, trimEdge_l}];
        trimVal_v = trimVal_v(sortAscTrimIdx_v);
        trimVal_v = sort(trimVal_v);
        
        % Index the sorted edge vectors with the corresponding grid entry
        draft(hi, :) = draftVal_v(draftIdx_v);
        trim(hi, :) = trimVal_v(trimIdx_v);
    end
    
    % Create table
    tbl = table(draft(:), trim(:), displacement(:), ...
        'VariableNames', {'Draft', 'Trim', 'Displacement'});
    
else
    
    % Get variable names
    startIdx_v = regexp(answerNames, 'Answer_', 'end');
    endIdx_v = regexp(answerNames, '_[\d]+', 'start');
    duplicateNames = cellfun(@(name, si, ei) name(si+1:ei-1), answerNames, ...
        startIdx_v, endIdx_v, 'Uni', 0);
    names = unique(duplicateNames);
    
    % Iterate names
    tbl = table();
    for name = names
        
        % Skip if page name found
        if isempty([name{:}])
            
            continue
        end
        
        % Index file table with this name
        thisName_ch = ['Answer_', [name{:}]];
        thisName_c = regexp(answerNames, [thisName_ch, '_[\d]+']);
        thisName_l = ~cellfun(@isempty, thisName_c);
        name_tbl = answer_tbl(:, thisName_l);
        
        % Sort columns from file into ascending order
        thisName_c = answerNames(thisName_l);
        idx_cc = regexp(thisName_c, '[\d]+', 'match');
        idx_c = [idx_cc{:}];
        idx_v = cellfun(@str2double, idx_c);
        [~, sortI] = sort(idx_v, 'asc');
        name_tbl = name_tbl(:, sortI);
        
        % Append column of data into output table
        tbl.([name{:}]) = name_tbl{:, :}(:); 
    end
    
    % Assign numbers of draft
    obj.nDraft = height(name_tbl);
    obj.nTrim = 0;
    
    % Check for any page variables
    if obj.hasPageData() && ~isempty(obj.PageValue)

        % Index current image to find corresponding page value
        fileImg_c = file_tbl.Input_image_url;
        objimg_c = obj.ImageURL;
        [~, imageOrder_v] = ismember(fileImg_c, objimg_c);
        page_v = obj.PageValue(imageOrder_v);
        
    elseif obj.hasPageData() && ~isempty(obj.PageLabel)
        
        % Read page values from file
        pageAnswer_ch = ['Answer_', obj.PageName];
        page_v = answer_tbl.(pageAnswer_ch);
        
    elseif obj.hasPageData()
        
        % Error if page name given but no label or values
        errid = 'PageData:InsufficientInput';
        errmsg = ['In order to parse page data, either property PageLabel '...
            'or PageValues must be given'];
        error(errid, errmsg);
    end
    
    if obj.hasPageData()
        
        % Assign page values to output table
        page_m = repmat(page_v(:), [1, width(name_tbl)]);
        tbl.(obj.PageName) = page_m(:);
        
        % Data is gridded even if layout was table
        obj.IsGrid = true;
    end
end

obj.FileData = tbl;
end