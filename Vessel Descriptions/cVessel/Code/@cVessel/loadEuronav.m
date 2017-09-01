function [ obj, numWarnings, warnings ] = loadEuronav(obj, filename, sheetname, varargin)
%LOADEURONAV Summary of this function goes here
%   Detailed explanation goes here

% validateattributes(imo, {'numeric'}, {'scalar', 'positive', 'integer'}, ...
%    'cVessel.loadDNVGLReportingFormat', 'imo', 3);
% set2_sql = ['IMO_Vessel_Number = ', num2str(imo)];

filename = validateCellStr(filename, 'loadEuronav', 'filename', 2);
sheetname = validateCellStr(sheetname, 'loadEuronav', 'sheetname', 3);

for fi = 1:numel(filename)
    
    currFile = filename{fi};
    for si = 1:numel(sheetname)

        currSheet = sheetname{si};

        p = inputParser();
        p.addParameter('firstRowIdx', 2);
        p.addParameter('fileColID', [1, 2, 3, 4, 5, 6, 7, 15, 24, 25, 26, 27, 28, 29, 30, 33]);  %, 22, 23, 24, 25, 26, 27]); % 8, 11, 14
        p.addParameter('tab', 'RawData');
        p.addParameter('fileColName', {  ...
                        'Vessel',...
                        'StartTime',...
                        'EndTime',...
                        'Shaft_Revolutions',...
                        'Shaft_Torque',...
                        'Static_Draught_Fore',...
                        'Static_Draught_Aft',...
                        'Temp_Fuel_Oil_At_Flow_Meter',...
                        'GPS_Speed',...
                        'Speed_Through_Water',  ...
                        'Ship_Heading',...
                        'Rudder_Angle',...
                        'Wind_Speed_Knots',...
                        'Relative_Wind_Direction',...
                        'Water_Depth',...
                        'Mass_Consumed_Fuel_Oil'  ...
                                   });
    %     p.addParameter('tabColNames', {  ...
    %                     'DateTime_UTC', ...
    %                     'Shaft_Revolutions',...
    %                     'Shaft_Torque',...
    %                     'Static_Draught_Fore',...
    %                     'Static_Draught_Aft',...
    %                     'Temp_Fuel_Oil_At_Flow_Meter',...
    %                     'Mass_Consumed_Fuel_Oil',...
    %                     'Speed_Over_Ground',...
    %                     'Relative_Wind_Speed',  ...
    %                     'Relative_Wind_Direction',...
    %                     'Speed_Through_Water',...
    %                     'Water_Depth',...
    %                     'Ship_Heading',...
    %                     'Rudder_Angle'...
    %                     'Shaft_Power'...
    %                                });
        p.addParameter('SetSQL', ...
                    {'DateTime_UTC = STR_TO_DATE(@StartTime, ''%d-%m-%Y %H:%i:%s'') + timeDIFF(STR_TO_DATE(@EndTime, ''%d-%m-%Y %H:%i:%s''), STR_TO_DATE(@StartTime, ''%d-%m-%Y %H:%i:%s''))/2',...
                    ['IMO_Vessel_Number = CASE '...
                    'WHEN @Vessel = ''Hakone'' THEN 9398084 ',...
                    'WHEN @Vessel = ''Hirado'' THEN 9377420 ',...
                    'WHEN @Vessel = ''Hakata'' THEN 9346952 ',...
                    'WHEN @Vessel = ''Hakone'' THEN 9398084 ',...
                    'WHEN @Vessel = ''Sandra'' THEN 9537757 ',...
                    'WHEN @Vessel = ''Sara'' THEN 9537745 ',...
                    'WHEN @Vessel = ''Devon'' THEN 9516117 ',...
                    'WHEN @Vessel = ''Maria'' THEN 9530890 ',...
                    'WHEN @Vessel = ''Captain Michael'' THEN 9531480 ',...
                    'END']...
                    'Speed_Over_Ground = knots2mps(@GPS_Speed)'...
                    'Relative_Wind_Speed = knots2mps(@Wind_Speed_Knots)'....
                    'Speed_Through_Water = knots2mps(@Speed_Through_Water)'....
                    });
        paramValues_c = varargin;
        p.parse(paramValues_c{:});
    %     mainSheet = p.Results.mainSheet;
        firstRowIdx = p.Results.firstRowIdx;
        fileColID = p.Results.fileColID;
        tab = p.Results.tab;
        fileColName = p.Results.fileColName;
    %     tabColNames = p.Results.tabColNames;
        SetSQL = p.Results.SetSQL;

        % Concatenate all set commands
    %     SetSQL = [SetSQL, set2_sql];

        % Load time-seres data from xlsx
        [obj, numWarnings, warnings] = obj.loadXLSX(currFile, currSheet, firstRowIdx, fileColID, fileColName, tab, SetSQL);
    end
end