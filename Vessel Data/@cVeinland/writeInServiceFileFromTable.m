function [out, over, tbl] = writeInServiceFileFromTable(tbl, file)
%loadInService Load in-service data from files or directory
%   Detailed explanation goes here

% Input
validateattributes(file, {'char'}, {'vector'}, ...
    'cVeinland.writeInServiceFile', 'file', 3);
validateattributes(tbl, {'timetable', 'table'}, {}, ...
    'cVeinland.writeInServiceFile', 'tbl', 2);

% Conversion units
knots2mps = 0.514444;

% Change code when Veinland get back to us with the logic behind wind
% variables in file
tblVar = tbl.Properties.VariableNames;
draftVar = 'draft_forw';
if ismember('draft_fwd', tblVar)
    
    draftVar = 'draft_fwd';
end
waterTempVar = 'seawater_temperature';
if ismember('seawater_temp', tblVar)
    
    waterTempVar = 'seawater_temp';
end
headingVar = 'heading_course';
if ismember('vessel_gps_course', tblVar)
    
    headingVar = 'seawater_temp';
end
depthVar = 'water_depth';
if ismember('depth', tblVar)
    
    depthVar = 'depth';
end

% Create output table
out = timetable(datetime(tbl.report_date, 'Format', 'yyyy-MM-dd HH:mm:SSSSSSS'));
out.Speed_Through_Water = tbl.log_speed * knots2mps;
out.Shaft_Power = tbl.shaft_power;

% Change code when Veinland get back to us with the logic behind wind
% variables in file
out.Relative_Wind_Speed = tbl.rel_wind_speed;
out.Relative_Wind_Direction = tbl.true_wind_angle_heading;

out.Speed_Over_Ground = tbl.gps_speed;
out.Ship_Heading = tbl.(headingVar);
out.Shaft_Revolutions = tbl.shaft_rpm;
out.Static_Draught_Fore = tbl.(draftVar);
out.Static_Draught_Aft = tbl.draft_aft;
out.Water_Depth = tbl.(depthVar);
out.Seawater_Temperature = tbl.(waterTempVar);
out.Air_Temperature = tbl.air_temperature;
out.Air_Pressure = tbl.air_pressure;
out.Shaft_Torque = tbl.shaft_torque;
out.Mass_Consumed_Fuel_Oil = tbl.foc_me_actual;
out.Temp_Fuel_Oil_At_Flow_Meter = tbl.temperature_me_IN;
out.Mass_Consumed_Fuel_Oil = tbl.foc_me_actual;
out.Displacement = tbl.displacement;
out.Rudder_Angle = tbl.rudder_angle;
out.Properties.DimensionNames = {'DateTime_UTC', 'Variables'};

% Convert units/conventions
% Check if wind speed units different from spec
knots_l = strcmpi(tbl.wind_speed_unit, 'k');
out.Relative_Wind_Speed(knots_l) = out.Relative_Wind_Speed(knots_l)*knots2mps;

% if ismember('wind_reference', tbl.Properties.VariableNames)
%     
%     true_l = strcmpi(tbl.wind_reference, 'T');
%     relative_l = ~true_l;
%     true2relWind_f = @(x) nan;
%     out.Relative_Wind_Direction(true_l) = true2relWind_f(tbl.wind_angle_heading(true_l));
%     out.Relative_Wind_Direction(relative_l) = tbl.rel_wind_angle_heading(relative_l);
% end

% Divide daily fuel consumption by times of each report

% Generate import file
writetable(timetable2table(out), file);

% Generate overview table
numerVar_l = varfun(@isnumeric, tbl, 'OutputFormat', 'uniform');
numerVar_c = tbl.Properties.VariableNames(numerVar_l);

pcNonEmpty_tbl = varfun(@(x) mean(~isnan(x))*100, tbl(:, numerVar_l),...
    'OutputFormat', 'table');
pcNonEmpty_tbl.Properties.VariableNames = numerVar_c;

nUnique_tbl = varfun(@(x) numel(unique(x(~isnan(x)))), tbl(:, numerVar_l),...
    'OutputFormat', 'table');
nUnique_tbl.Properties.VariableNames = numerVar_c;

over = [pcNonEmpty_tbl; nUnique_tbl];
over.Properties.RowNames = {'pcNonEmpty', 'nUnique'};
end