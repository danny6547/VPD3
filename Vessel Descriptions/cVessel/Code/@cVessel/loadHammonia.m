function [tbl] = loadHammonia(obj, filename, nHead, varargin)
%loadHammonia Load in-service file in Hammonia format
%   Detailed explanation goes here

% Read table vars
fid = fopen(filename, 'r');
raw_cc = textscan(fid, '%q', nHead, 'Delimiter', ';');
raw_c = strrep([raw_cc{:}], '﻿', '');
varNames = regexprep(raw_c, '[\n\r]+(Revolution)', '');

% Load into table
raw = readtable(filename, 'HeaderLines', nHead, 'ReadVariableNames', false);
raw.Properties.VariableNames = genvarname(varNames);

% Assign columns, convert units
knots2mps_f = @(x) x*0.51444;
MW2kW_f = @(x) x*1e3;
% Relative_Wind_Speed,Relative_Wind_Direction,Static_Draught_Fore,Static_Draught_Aft,
% ,,,,Seawater_Temperature,Air_Temperature,Air_Pressure,,,,,,,Volume_Consumed_Fuel_Oil,Temp_Fuel_Oil_At_Flow_Meter,Displacement
tbl = table(raw.TIME, 'VariableNames', {'DateTime_UTC'});
tbl.Speed_Through_Water = knots2mps_f(raw.WATERSPEED0x5Bkn0x5D0x28kn0x29);
tbl.Speed_Over_Ground = knots2mps_f(raw.GROUNDSPEED0x5Bkn0x5D0x28kn0x29);
tbl.Ship_Heading = raw.HEADING0x5Bdeg0x5D;
tbl.Shaft_Revolutions = raw.ShaftSpeed0x5Brpm0x5D0x28rpm0x29;
tbl.Water_Depth = raw.WATERDEPTH0x5Bm0x5D0x28m0x29;
tbl.Shaft_Power = MW2kW_f(raw.ShaftPower0x5BMW0x5D0x28MW0x29);
tbl.Brake_Power = MW2kW_f(raw.MELoad0x5B0x250x5D0x280x250x29);
tbl.Shaft_Torque = raw.ShaftTorque0x5BkNm0x5D0x28kNm0x29;
tbl.Propeller_Pitch = raw.PropellerPitch0x5B0x250x5D0x280x250x29;

% Parse Latitude, Longitude string
w = regexp(raw.POSITION, '[°''NE;]', 'split');
emptyPos_l = cellfun(@(x) all(cellfun(@isempty, x)), w);
outpos_m = nan(height(raw), 2);
w(emptyPos_l) = [];

e = cellfun(@(x) x([1, 3, 6, 8]), w, 'Uni', 0);
r = cellfun(@(x) cellfun(@str2double, x), e, 'Uni', 0);
t = cellfun(@(x) [x(1) + x(2)/60, x(3) + x(4)/60]', r, 'Uni', 0);
filepos_m = [t{:}]';
outpos_m(~emptyPos_l, :) = filepos_m;
tbl.Latitude = outpos_m(:, 1);
tbl.Longitude = outpos_m(:, 2);

% Convert
tbl.DateTime_UTC = datetime(tbl.DateTime_UTC, 'InputFormat', 'dd-MM-yyyy HH:mm:SS');
tbl = table2timetable(tbl);
end