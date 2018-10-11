function printImportFile2(obj, filename, varargin)
%printImportFile2 Print import file from InService
%   Detailed explanation goes here

% Input
printVid = false;
if nargin > 2
    
    printVid = varargin{1};
    validateattributes(printVid, {'logical'}, {'scalar'},...
        'cVesselInService.printImportFile2', 'printVid', 3);
    
    if printVid && isempty(obj.Vessel_Id)
        
        errid = 'cVIS:printEmptyVesselId';
        errmsg = ['Input indicates that vessel id is to be printed into '...
            'import file, but vessel id is empty.'];
        error(errid, errmsg);
    end
end

if ~obj.canWriteImportFile()
    
    errid = 'cVIS:noImportFileVars';
    errmsg = 'No import file variables found in in-service data';
    error(errid, errmsg);
end

fileCols = obj.importFileVars(); % strsplit('Relative_Wind_Speed,Relative_Wind_Direction,Speed_Over_Ground,Ship_Heading,Shaft_Revolutions,Static_Draught_Fore,Static_Draught_Aft,Water_Depth,Rudder_Angle,Seawater_Temperature,Air_Temperature,Air_Pressure,Speed_Through_Water,Delivered_Power,Shaft_Power,Brake_Power,Shaft_Torque,Mass_Consumed_Fuel_Oil,Volume_Consumed_Fuel_Oil,Temp_Fuel_Oil_At_Flow_Meter,Displacement', ',');
fileColsLow = ['timestamp', lower(fileCols)];

vessCols = obj.Data.Properties.VariableNames;
[vessCols_l, vessCols_i] = ismember(fileColsLow, vessCols);
vessCols_i = vessCols_i(vessCols_l);

tbl2write = obj.Data(:, vessCols_i);
tabVars = tbl2write.Properties.VariableNames;
[~, vari] = ismember(tabVars, lower(fileCols));
newVars = fileCols(vari);
tbl2write.Properties.VariableNames = newVars;
tbl2write.Properties.DimensionNames{1} = 'DateTime_UTC';
tbl2write.DateTime_UTC.Format = 'yyyy-MM-dd HH:mm:ss.S';

% Filter
filter_l = tbl2write.Speed_Through_Water <= 0 | ...
        tbl2write.Static_Draught_Fore <= 0 | ...
        tbl2write.Static_Draught_Aft <= 0 | ...
        isnan(tbl2write.Speed_Through_Water) | ...
        isnan(tbl2write.Static_Draught_Fore) | ...
        isnan(tbl2write.Static_Draught_Aft);
tbl2write(filter_l, :) = [];

filterTime_l = isnat(tbl2write.DateTime_UTC);
tbl2write(filterTime_l, :) = [];

tbl2write_c = table2cell(tbl2write);
tbl2write_c(cellfun(@isnan, tbl2write_c)) = {''};
date_tbl = tbl2write.DateTime_UTC;
tbl2write = [table(date_tbl, 'VariableNames', {'DateTime_UTC'}),...
                cell2table(tbl2write_c, 'VariableNames', newVars)];

% Append vessel id if requested
if printVid
    
    tbl2write.Vessel_Id = repmat(obj.Vessel_Id, height(tbl2write), 1);
end

writetable(tbl2write, filename);