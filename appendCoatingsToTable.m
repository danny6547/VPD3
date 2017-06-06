function [ tbl ] = appendCoatingsToTable(tbl, coatingsfile, varargin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% Input
if nargin > 2
    
    startTableCol = varargin{1};
    validateattributes(startTableCol, {'char'}, {'vector'}, ...
        'appendCoatingsToTable', 'startTableCol', 1);
end
if nargin > 3
    
    endTableCol = varargin{2};
    validateattributes(endTableCol, {'char'}, {'vector'}, ...
        'appendCoatingsToTable', 'endTableCol', 2);
end

% Get table from file
coat_tbl = readtable(coatingsfile);

% Get indices of dates table to those in coating file 
tblRows_l = ismember([coat_tbl.IMO_Vessel_Number, datenum(coat_tbl.StartDate, 'dd-mm-yyyy'), datenum(coat_tbl.EndDate, 'dd-mm-yyyy')],...
    [tbl.IMO_DDPerf, datenum(tbl.(startTableCol), 'dd-mm-yyyy'), datenum(tbl.(endTableCol), 'dd-mm-yyyy')], 'rows');

% Index into coating file with rows that match input table
cols2append_c = {'Verticals', 'FlatBottom'};
table2append = coat_tbl(tblRows_l, cols2append_c);

% Get indices to input table of the table2append
tbl2AppendRows_l = ismember([tbl.IMO_DDPerf, datenum(tbl.DryDockStartDate_DDPerf, 'dd-mm-yyyy'), datenum(tbl.DryDockEndDate_DDPerf, 'dd-mm-yyyy')],...
    [coat_tbl.IMO_Vessel_Number, datenum(coat_tbl.StartDate, 'dd-mm-yyyy'), datenum(coat_tbl.EndDate, 'dd-mm-yyyy')], 'rows');

% Append columns to input table, indexed by row
table2append(~tbl2AppendRows_l, :) = cell2table(repmat({'', ''}, numel(find(~tbl2AppendRows_l, 1))), 'VariableNames', {'Verticals', 'FlatBottom'});
tbl = [tbl, table2append];

end