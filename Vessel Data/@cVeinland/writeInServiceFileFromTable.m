function [out] = writeInServiceFileFromTable(tbl, file)
%loadInService Load in-service data from files or directory
%   Detailed explanation goes here

% Input
validateattributes(file, {'char'}, {'vector'}, ...
    'cVeinland.writeInServiceFile', 'file', 3);
validateattributes(tbl, {'timetable', 'table'}, {}, ...
    'cVeinland.writeInServiceFile', 'tbl', 2);

% Conversion units
knots2mps = 0.514444;

% Create output table
out = timetable(datetime(tbl.report_date, 'Format', 'yyyy-MM-dd HH:mm:SSSSSSS'));
out.Speed_Through_Water = tbl.log_speed * knots2mps;
out.Shaft_Power = tbl.shaft_power;
out.Relative_Wind_Speed = tbl.rel_wind_speed;
out.Relative_Wind_Direction = tbl.rel_wind_angle_heading;
out.Speed_Over_Ground = tbl.gps_speed;
out.Ship_Heading = tbl.heading_course;
out.Shaft_Revolutions = tbl.shaft_rpm;
out.Static_Draught_Fore = tbl.draft_forw;
out.Static_Draught_Aft = tbl.draft_aft;
out.Water_Depth = tbl.water_depth;
out.Seawater_Temperature = tbl.seawater_temperature;
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

% Divide daily fuel consumption by times of each report


% Generate import file
writetable(timetable2table(out), file);

end