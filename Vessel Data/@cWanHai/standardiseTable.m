function [tbl] = standardiseTable(tbl, freq, type)
%standardiseTable Rename table variables based on standard
%   Detailed explanation goes here

% [spec, timeName] = cWanHai.specification(freq, type);
% [var, stdVar] = varFromSpec(freq, type);

% tabVars = tbl.Properties.VariableNames;
% 
% [foundVars_l, foundVars_i] = ismember(tabVars, var);
% repTab_i = foundVars_i(foundVars_l);
% 
% newVars = tabVars;
% standardVars = spec(:, 2);
% newVars(repTab_i) = standardVars(repStandard_i);

% [var, stdVar] = cWanHai.varFromSpec(freq, type);

% Change variable names to standard
spec = cWanHai.specification(freq, type);
stdVar = spec(:, 2);
requiredVar_l = ~cellfun(@isempty, stdVar);
var = spec(requiredVar_l, 1);
stdVar = stdVar(requiredVar_l);
tbl = cVesselNoonData.renameTableVar(tbl, var, stdVar);

% Change time dimension to standard
tbl.Properties.DimensionNames{1} = 'Timestamp';
end