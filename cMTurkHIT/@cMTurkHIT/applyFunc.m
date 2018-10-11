function c = applyFunc(obj, tbl)
%applyFunc 
%   Detailed explanation goes here

% allNames = tbl.Properties.VariableNames;
c = table2cell(tbl);

% Iterate functions
for fi = 1:size(obj.DataFunc, 1)
    
    % Get current name and func
    currName = obj.DataFunc{fi, 1};
    currFunc = obj.DataFunc{fi, 2};
    
    % Find part of cell for current name
    currNames = obj.fileTableNames(tbl, currName);
    currCols_l = ismember(tbl.Properties.VariableNames, currNames);
    
    % Apply function to all elements
    c(:, currCols_l) = cellfun(currFunc, c(:, currCols_l), 'Uni', 0);
end