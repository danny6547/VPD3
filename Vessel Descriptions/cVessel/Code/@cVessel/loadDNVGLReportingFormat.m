function obj = loadDNVGLReportingFormat(obj, filename, varargin )
%loadDNVGLReportingFormat Load files with DNVGL noon-data format to RawData
%   Detailed explanation goes here

% Input
set2_sql = {''};
if nargin > 2 && ~isempty(varargin{1})
    
   imo = varargin{1};
   validateattributes(imo, {'numeric'}, {'scalar', 'positive', 'integer'}, ...
       'cVessel.loadDNVGLReportingFormat', 'imo', 3);
   set2_sql = ['IMO_Vessel_Number = ', num2str(imo)];
end

p = inputParser();
p.addParameter('mainSheet', 'Hempel''s Data Collection Form');
p.addParameter('firstRowIdx', 21);
p.addParameter('fileColID', [2, 4, 15, 16, 24, 25, 26, 27, 32, 51, 95, 96, 98, 102]);
p.addParameter('tab', 'RawData');
p.addParameter('fileColName', {  ...
                'Date_UTC', ...
                'Time_UTC',  ...
                'Wind_Dir',  ...
                'Wind_Force',  ...
                'Air_Temperature',  ...
                'Seawater_Temperature',  ...
                'Static_Draught_Fore',  ...
                'Static_Draught_Aft',  ...
                'Displacement',  ...
                'Mass_Consumed_Fuel_Oil',  ...
                'Speed_Over_Ground',  ...
                'Speed_Through_Water',  ...
                'Water_Depth',  ...
                'Delivered_Power',  ...
                           });
p.addParameter('tabColNames', {  ...
                'DateTime_UTC', ...
                'Relative_Wind_Direction',  ...
                'Relative_Wind_Speed',  ...
                'Air_Temperature',  ...
                'Seawater_Temperature',  ...
                'Static_Draught_Fore',  ...
                'Static_Draught_Aft',  ...
                'Displacement',  ...
                'Mass_Consumed_Fuel_Oil',  ...
                'Speed_Over_Ground',  ...
                'Speed_Through_Water',  ...
                'Water_Depth',  ...
                'Delivered_Power',  ...
                           });
p.addParameter('SetSQL', ...
            {'DateTime_UTC = ADDTIME(STR_TO_DATE(@Date_UTC, ''%Y-%m-%d''), STR_TO_DATE(@Time_UTC, '' %H:%i''))',...
            ['Relative_Wind_Direction = CASE '...
            'WHEN @Wind_Dir = 1 THEN 0 '...
            'WHEN @Wind_Dir = 2 THEN 45 '...
            'WHEN @Wind_Dir = 3 THEN 90 '...
            'WHEN @Wind_Dir = 4 THEN 135 '...
            'WHEN @Wind_Dir = 5 THEN 180 '...
            'WHEN @Wind_Dir = 6 THEN 225 '...
            'WHEN @Wind_Dir = 7 THEN 270 '...
            'WHEN @Wind_Dir = 8 THEN 315 '...
            'END'],...
            'Relative_Wind_Speed = knots2mps(@Wind_Force)',...
            'Speed_Over_Ground = knots2mps(nullif(@Speed_Over_Ground, ''''))',...
            'Speed_Through_Water = knots2mps(nullif(@Speed_Through_Water, ''''))',...
            'Displacement = nullif(@Displacement * 1e3, '''')'});
paramValues_c = varargin(2:end);
p.parse(paramValues_c{:});
mainSheet = p.Results.mainSheet;
firstRowIdx = p.Results.firstRowIdx;
fileColID = p.Results.fileColID;
tab = p.Results.tab;
fileColName = p.Results.fileColName;
tabColNames = p.Results.tabColNames;
SetSQL = p.Results.SetSQL;

% Concatenate all set commands
SetSQL = [SetSQL, set2_sql];

% Account for behaviour where 1 row fewer than expected is read
firstRowIdx = firstRowIdx - 1;

% % Associate file columns with table columns
% mainSheet = 'Hempel''s Data Collection Form';
% firstRow = 20;
% fileColID = [2, 4, 15, 16, 24, 25, 26, 27, 30, 51, 95, 96, 98, 102];
% tab = 'RawData';
% fileColName = {  ...
%                 'Date_UTC', ...
%                 'Time_UTC',  ...
%                 'Wind_Dir',  ...
%                 'Wind_Force',  ...
%                 'Air_Temperature',  ...
%                 'Seawater_Temperature',  ...
%                 'Static_Draught_Fore',  ...
%                 'Static_Draught_Aft',  ...
%                 'Displacement',  ...
%                 'Mass_Consumed_Fuel_Oil',  ...
%                 'Speed_Over_Ground',  ...
%                 'Speed_Through_Water',  ...
%                 'Water_Depth',  ...
%                 'Delivered_Power',  ...
%                            };
% tabColNames = {  ...
%                 'DateTime_UTC', ...
%                 'Relative_Wind_Direction',  ...
%                 'Relative_Wind_Speed',  ...
%                 'Air_Temperature',  ...
%                 'Seawater_Temperature',  ...
%                 'Static_Draught_Fore',  ...
%                 'Static_Draught_Aft',  ...
%                 'Displacement',  ...
%                 'Mass_Consumed_Fuel_Oil',  ...
%                 'Speed_Over_Ground',  ...
%                 'Speed_Through_Water',  ...
%                 'Water_Depth',  ...
%                 'Delivered_Power',  ...
%                            };
% 
% % Create necessary set SQL
% set_sql = [{'DateTime_UTC = ADDTIME(STR_TO_DATE(@Date_UTC, ''%Y-%m-%d''), STR_TO_DATE(@Time_UTC, '' %H:%i''))',...
%             ['Relative_Wind_Direction = CASE '...
%             'WHEN @Wind_Dir = 1 THEN 0 '...
%             'WHEN @Wind_Dir = 2 THEN 45 '...
%             'WHEN @Wind_Dir = 3 THEN 90 '...
%             'WHEN @Wind_Dir = 4 THEN 135 '...
%             'WHEN @Wind_Dir = 5 THEN 180 '...
%             'WHEN @Wind_Dir = 6 THEN 225 '...
%             'WHEN @Wind_Dir = 7 THEN 270 '...
%             'WHEN @Wind_Dir = 8 THEN 315 '...
%             'END'],...
%             'Relative_Wind_Speed = knots2mps(@Wind_Force)',...
%             'Speed_Over_Ground = knots2mps(nullif(@Speed_Over_Ground, ''''))',...
%             'Speed_Through_Water = knots2mps(nullif(@Speed_Through_Water, ''''))'},...
%             set2_sql];

% Load time-seres data from xlsx
obj = obj.loadXLSX(filename, mainSheet, firstRowIdx, fileColID, fileColName, tab, tabColNames, SetSQL);

% % Load bunker data from xlsx
% bunkerSheet = 'Bunker Reporting';
% obj = obj.loadXLSX(filename, bunkerSheet, ...);
end