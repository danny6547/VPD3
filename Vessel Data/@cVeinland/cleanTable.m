function tbl = cleanTable(obj, tbl)
%cleanTable Clean table read from file to remove missing and unwanted data
%   Detailed explanation goes here

miss = obj.MissingData;
tbl = standardizeMissing(tbl, miss);
var2keep = obj.FileVariables2Keep;
allVar = tbl.Properties.VariableNames;
var2clean = setdiff(allVar, var2keep);
tbl = rmmissing(tbl, 2, 'DataVariables', var2clean);

unwantedVars = obj.UnwantedVariables;
for ui = 1:numel(unwantedVars)
    
    tbl.(unwantedVars{ui}) = [];
end