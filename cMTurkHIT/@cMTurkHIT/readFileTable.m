function [file, answer, nHIT] = readFileTable(obj, filename, varargin)
%readFileTable Read table from output file, optionally filtering rejects
%   Detailed explanation goes here

% Input
filterRejects = true;
if nargin > 1
    
    filterRejects = varargin{1};
    validateattributes(filterRejects, {'logical'}, {'scalar'},...
        'cMTurkHIT.readFileTable', 'filterRejects', 2);
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
file = cell2table(file_c, 'VariableNames', colNames);

% Filter rejects
if filterRejects
    
    reject_l = strcmp(file.AssignmentStatus, 'Rejected');
    file(reject_l, :) = [];
    nHIT = height(file);
end

% Get answers
colNames = file.Properties.VariableNames;
answer_l = contains(colNames, 'Answer_');
answer = file(:, answer_l);

% Convert to numeric with NaN
% answerTbl_c = table2cell(answer);
answerTbl_c = obj.applyFunc(answer);
answerTbl_m = cellfun(@str2double, answerTbl_c);
answer = array2table(answerTbl_m, ...
    'VariableNames', answer.Properties.VariableNames);
