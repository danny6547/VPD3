%% 11
obj = cMTurkHIT();
obj.RowLabels   = {'DRAFT MEAN', 'MOULD VOL', 'KB', '', '', ''};
obj.RowNames    = {'Draft', 'Mld_Vol', 'KB', 'Trim', 'Trim', 'Trim'};
obj.NumColumns = 7;
html = obj.print;

%% 6
obj = cMTurkHIT();
obj.ColumnLabels =  {'DRAFT', 'DRAFT MLD', 'DISP', 'TRIM', 'TRIM', 'TRIM';...
                        'EXT',      'MLD',  'IN SW', '', '', ''}; % Repeat trim 8 times
obj.ColumnNames = {'Draft', 'draft_moulded', 'Displacement', 'Trim', 'Trim', 'Trim'}; % Repeat trim 8 times
obj.NumRows = 55;

%% 12
obj = cMTurkHIT();
obj.ColumnLabels =  {'DRAFT', 'EXT', 'VOLM', 'DISP';...
                        'm',    'm',    'm3',   't'};
obj.ColumnName = {'Draft', 'EXT', 'VOLM', 'Displacement'};
obj.NumRows = 73;
obj.PageVariable = 'Trim';
obj.PageLabel = 'Calculated for Trim = ';

%% 7
obj = cMTurkHIT();
obj.RowLabels = {'DRAFT MOULDED', 'MOUDLDED VOLUME (M3)', 'LCF MID', 'DISP. TRIM=', 'DISP. TRIM=', 'DISP. TRIM='};
obj.RowNames    = {'Draft', 'Volume', 'LCF', 'Trim', 'Trim', 'Trim'}; 
obj.NumCols = 13;

%% 10
obj = cMTurkHIT();
obj.ColumnLabels = {'DRAFT EXT.', 'DISPL.', 'MOULD VOL.', 'T.P.C', 'L.C.F'};
obj.ColumnNames = {'Draft', 'Displacement', 'volume', 'TPC', 'LCF'};
obj.NumRows = 45;

% Create grid value inputs everywhere Draft, Trim are Names, when IsGrid
%   Then these inputs independent of labels (compare 7 and 11)
%   Row and column names? Yes, therefore defining a grid!
% When not IsGrid, no need to create grid value inputs

% IsGrid when Draft and Trim in both RowNames and ColNames
% Where to create grid side vector?
%   Doesn't need to be continuous
%   At any of the indices of 'Name' in the RowNames where there is only one
%   of 'Name' in ColNames
% Where to create grid top vector?
%   At any of the indices of 'Name' in the ColNames where there is only one
%   of 'Name' in RowNames