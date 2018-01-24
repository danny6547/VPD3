function checkCSVExportScript(outfile, imo)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

validateattributes(outFile, {'char'}, {'vector'}, 'combineCSVExportScript',...
    'outFile', 1);
validateattributes(imo, {'numeric'}, {'scalar', 'integer', 'positive'},...
    'combineCSVExportScript', 'imo', 2);

% Read Files
q = readtable(outfile);
fprintf('Out file read\n');

% w = readtable(rawFile);
% fprintf('Second file read\n');

% Prepare tables for filtering
if ~ismember('Vessel_Configuration_Id', q.Properties.VariableNames)
    return
end
q.Vessel_Configuration_Id = [];
q.x___Calculated_Data_Id = [];
% q.Raw_Data_Id = [];
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

q.Latitude = [];
q.Longitude = [];
names = q.Properties.VariableNames;
[~, timei] = ismember('Timestamp', names);
q.Properties.VariableNames(timei) = {'DateTime_UTC'};
q.DateTime_UTC = datestr(q.DateTime_UTC, 'yyyy-mm-dd HH:MM:SS.000');

q.IMO_Vessel_Number = repmat(imo, [height(w), 1]);
q.Temp_Fuel_Oil_At_Flow_Meter = [];
q.Displacement = [];
% q.x___Raw_Data_Id = [];
q.Vessel_Id = [];

% % Remove rows from raw data where no calculations have been done
% e_l = ~ismember(q.x___Raw_Data_Id, q.Raw_Data_Id);
% w(e_l, :) = [];

% Concat and write
writetable(tempRawISO, outFile, 'WriteVariableNames', true);
end

