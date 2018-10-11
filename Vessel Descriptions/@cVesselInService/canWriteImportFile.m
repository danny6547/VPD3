function log = canWriteImportFile(obj)
%canWriteImportFile True when import file can be written
%   Detailed explanation goes here

    % Get raw data names from RawData table
    importTabName = 'RawData';
    [~, temp_tbl] = obj.SQL.describe(importTabName);
    rawCols_c = lower(temp_tbl.field);
    
    % Get variable names from object
    objVars = lower(obj.Data.Properties.VariableNames);
    
    % Look for any import table field names in object's data
    commonVars = intersect(rawCols_c, objVars);
    log = ~isempty(commonVars);
end