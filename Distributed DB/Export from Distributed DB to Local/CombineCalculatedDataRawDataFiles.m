function combineCSVExportScript(rawFile, calcFile, outFile)
% combineCSVExportScript Combine files read from remote DB

% Input
validateattributes(rawFile, {'char'}, {'vector'}, 'combineCSVExportScript',...
    'rawFile', 1);
validateattributes(calcFile, {'char'}, {'vector'}, 'combineCSVExportScript',...
    'calcFile', 2);
validateattributes(outFile, {'char'}, {'vector'}, 'combineCSVExportScript',...
    'outFile', 3);

q = readtable('C:\Users\damcl\OneDrive - Hempel Group\Documents\temp\CalculatedData06.csv');
fprintf('First file read');

rawfile = 'C:\Users\damcl\OneDrive - Hempel Group\Documents\temp\RawData06.csv';
w = readtable(rawfile);
fprintf('Second file read');

imo = 9567063;

q.Vessel_Configuration_Id = [];
q.x___Calculated_Data_Id = [];
q.Raw_Data_Id = [];
% q.Row = [];
q.Invalid_Rpm = [];
q.Invalid_Rudder_Angle = [];
q.Invalid_Speed_Over_Ground = [];
q.Invalid_Speed_Through_Water = [];
q.Chauvenet_Air_Temperature = [];
q.Chauvenet_Criteria = [];
q.Chauvenet_Delivered_Power = [];
q.Chauvenet_Relative_Wind_Direction = [];
q.Chauvenet_Relative_Wind_Speed = [];
q.Chauvenet_Rudder_Angle = [];
q.Chauvenet_Seawater_Temperature = [];
q.Chauvenet_Shaft_Revolutions = [];
q.Chauvenet_Ship_Heading = [];
q.Chauvenet_Speed_Over_Ground = [];
q.Chauvenet_Static_Draught_Aft = [];
q.Chauvenet_Static_Draught_Fore = [];
q.Chauvenet_Water_Depth = [];
q.Wind_Resistance_Applied = [];
q.ErrorCode = [];
q.Displacement_Correction_Needed = [];

w.Latitude = [];
w.Longitude = [];
names = w.Properties.VariableNames;
[~, timei] = ismember('Timestamp', names);
w.Properties.VariableNames(timei) = {'DateTime_UTC'};
w.DateTime_UTC = datestr(w.DateTime_UTC, 'yyyy-mm-dd HH:MM:SS.000');

w.IMO_Vessel_Number = repmat(imo, [height(w), 1]);
w.Temp_Fuel_Oil_At_Flow_Meter = [];
w.Displacement = [];
w.x___Raw_Data_Id = [];
w.Vessel_Id = [];

tempRawISO = [q, w];
writetable(tempRawISO, ...
    'C:\Users\damcl\OneDrive - Hempel Group\Documents\temp\tempRawISO06.csv',...
    'WriteVariableNames', true);

end