%% 11
obj = cMTurkHIT();
obj.RowLabels   = {'DRAFT MEAN', 'MOULD VOL', 'KB'};
obj.RowNames    = {'Draft', 'Mld_Vol', 'KB'};
obj.NumColumns = 7;
tab_c = obj.printHTMLTable;

obj2 = cMTurkHIT();
obj2.RowNames   = {'Draft', 'Trim', 'Trim', 'Trim', 'Trim', 'Trim', 'Trim', 'Trim'};
obj2.NumColumns = 7;
obj2.ColumnLabels = {'TRIM', 'DISPLACEMENT', '', '', '', '', '', ''};
tab2_c = obj2.printHTMLTable;
% LOTS
% UASC A7

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
obj.ColumnNames = {'Draft', 'EXT', 'VOLM', 'Displacement'};
obj.NumRows = 73;
obj.PageVariable = 'Trim';
obj.PageLabel = 'Calculated for Trim = ';
% Test with Cap Blanche
% Laurin Corrido
% Methane Spirit

%% 7
obj = cMTurkHIT();
obj.RowLabels = {'DRAFT MOULDED', 'MOUDLDED VOLUME (M3)', 'LCF MID', 'DISP. TRIM=', 'DISP. TRIM=', 'DISP. TRIM='};
obj.RowNames    = {'Draft', 'Volume', 'LCF', 'Trim', 'Trim', 'Trim'}; 
obj.NumColumns = 13;
% Hanjin Boston
% As Suwayq

%% 10
obj = cMTurkHIT();
obj.ColumnLabels = {'DRAFT EXT.', 'DISPL.', 'MOULD VOL.', 'T.P.C', 'L.C.F'};
obj.ColumnNames = {'Draft', 'Displacement', 'volume', 'TPC', 'LCF'};
obj.NumRows = 45;

% Test with Tokyo Spirit
% HEOGH also has displacement and trim correction on separate pages
% UASC A4

% Ordfjell Bow Saga: draft, trim, disp as vectors, draft needs to be
% repeated