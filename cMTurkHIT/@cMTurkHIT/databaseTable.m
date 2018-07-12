function [tbl] = databaseTable(obj)
%databaseTable Table matching that in database
%   Detailed explanation goes here

tbl = obj.FilteredData;
if obj.IsGrid
    
    dbNames = {'Draft', 'Trim', 'Displacement'};
else
    
    dbNames = {'Draft', 'TPC', 'LCF', 'Displacement'};
end

dbNames_l = ismember(tbl.Properties.VariableNames, dbNames);
tbl = tbl(:, dbNames_l);
end