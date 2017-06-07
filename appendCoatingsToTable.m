function [ tbl ] = appendCoatingsToTable(tbl, coatingsfile, varargin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% Input
imoTableCol = 'IMO_DDPerf';
if nargin > 2
    
    imoTableCol = varargin{1};
    validateattributes(imoTableCol, {'char'}, {'vector'}, ...
        'appendCoatingsToTable', 'startTableCol', 3);
end

startTableCol = 'DryDockStartDate_DDPerf';
if nargin > 3
    
    startTableCol = varargin{2};
    validateattributes(startTableCol, {'char'}, {'vector'}, ...
        'appendCoatingsToTable', 'startTableCol', 4);
end

endTableCol = 'DryDockEndDate_DDPerf';
if nargin > 4
    
    endTableCol = varargin{3};
    validateattributes(endTableCol, {'char'}, {'vector'}, ...
        'appendCoatingsToTable', 'endTableCol', 5);
end

% Get table from file
coat_tbl = readtable(coatingsfile);

% Work on subset of table that has IMO, Start, End dates
nonEmptyIMO_l = ~arrayfun(@isempty, tbl.(imoTableCol));
nonEmptyStart_l = ~cellfun(@isempty, tbl.(startTableCol));
nonEmptyEnd_l = ~cellfun(@isempty, tbl.(endTableCol));
nonEmpty_l = nonEmptyIMO_l & nonEmptyStart_l & nonEmptyEnd_l;
originalTbl = tbl;
tbl = tbl(nonEmpty_l, :);

% Get indices of dates table to those in coating file 
tblRows_l = ismember([coat_tbl.IMO_Vessel_Number, datenum(coat_tbl.StartDate, 'dd-mm-yyyy'), datenum(coat_tbl.EndDate, 'dd-mm-yyyy')],...
    [tbl.(imoTableCol), datenum(tbl.(startTableCol), 'dd-mm-yyyy'), datenum(tbl.(endTableCol), 'dd-mm-yyyy')], 'rows');

% Index into coating file with rows that match input table
cols2append_c = {'Verticals', 'FlatBottom'};
table2append = coat_tbl(tblRows_l, cols2append_c);

% Get indices to input table of the table2append
tbl2AppendRows_l = ismember([tbl.(imoTableCol), datenum(tbl.(startTableCol), 'dd-mm-yyyy'), datenum(tbl.(endTableCol), 'dd-mm-yyyy')],...
    [coat_tbl.IMO_Vessel_Number, datenum(coat_tbl.StartDate, 'dd-mm-yyyy'), datenum(coat_tbl.EndDate, 'dd-mm-yyyy')], 'rows');

% Append columns to input table, indexed by row
if any(~tbl2AppendRows_l)
    
    table2append(~tbl2AppendRows_l, :) = cell2table(repmat({'', ''}, numel(find(~tbl2AppendRows_l, 1))), 'VariableNames', {'Verticals', 'FlatBottom'});
end

% Assign into original table
if any(~nonEmpty_l)
    
    empty2append = cell2table(repmat({'', ''}, numel(find(~nonEmpty_l)), 1), 'VariableNames', {'Verticals', 'FlatBottom'});
    q = table;
    q(nonEmpty_l, :) = table2append;
    q(~nonEmpty_l, :) = empty2append;
    table2append = q;
end
tbl = [originalTbl, table2append];
end