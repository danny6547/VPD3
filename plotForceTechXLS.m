function [ dataTable, dates, si, figHandle ] = plotForceTechXLS(filename, DDdate, varargin )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


figHandle = [];
dataTable = table();

if nargin > 2
    
    ShipName = varargin{1};
    
else
    
    % Processing
    headers_c = {'SGProduction'
    'CPPropellerPitch'
    'VesselName'
    'VesselIMONumber'
    'VoyageNumber'
    'DeparturePort'
    'DepartureLocalTime'
    'DepartureUtcTime'
    'DepartureTimeZone'
    'DepartureIsDaylightTime'
    'ArrivalPort'
    'ArrivalLocalTime'
    'ArrivalUtcTime'
    'ArrivalTimeZone'
    'ArrivalIsDaylightTime'
    'RemainingDistance'
    'RemainingTime'
    'ReportStartLocalTime'
    'ReportStartUtcTime'
    'ReportStartTimeZone'
    'ReportEndLocalTime'
    'ReportEndUtcTime'
    'ReportEndTimeZone'
    'ReportPeriod'
    'LatitudeDegrees'
    'LatitudeMinutes'
    'LatitudeSeconds'
    'LatitudeSign'
    'LongitudeDegrees'
    'LongitudeMinutes'
    'LongitudeSeconds'
    'LongitudeSign'
    'Heading'
    'DraughtAft'
    'DraughtFore'
    'DistanceLogged'
    'DistanceObserved'
    'WindSpeed'
    'WindDirection'
    'AirTemperature'
    'MinimumWaterDepth'
    'WaterTemperature'
    'WavesState'
    'WavesDirection'
    'MainEnginePower'
    'TcSpeed'
    'PropellerSpeed'
    'PumpIndex'
    'MainEngineHFOConsumption'
    'MainEngineHFOLsConsumption'
    'MainEngineMDOConsumption'
    'MainEngineMDOLsConsumption'
    'MainEngineMGOConsumption'
    'MainEngineBioConsumption'
    'TotalHFOConsumption'
    'TotalHFOLsConsumption'
    'TotalMDOConsumption'
    'TotalMDOLsConsumption'
    'TotalMGOConsumption'
    'TotalBioConsumption'
    'RemainingHFO'
    'RemainingHFOLs'
    'RemainingMDO'
    'RemainingMDOLs'
    'RemainingMGO'
    'RemainingBio'
    'LowerCalorificValueForHFO'
    'LowerCalorificValueForHFOLs'
    'LowerCalorificValueForMDO'
    'LowerCalorificValueForMDOLs'
    'LowerCalorificValueForMGO'
    'LowerCalorificValueForBio'
    'ShaftThrust'
    'Comments'
    'SpeedIndexCombined'
    'ConsumptionIndexCombine' };
    
    strForm_c{1} = '%f';
    strForm_c{end+1} = '%s';
    strForm_c{end+1} = '%s';
    strForm_c{end+1} = '%u';
    strForm_c{end+1} = '%s';
    strForm_c{end+1} = '%s';
    strForm_c{end+1} = '%s';
    strForm_c{end+1} = '%s';
    strForm_c{end+1} = '%u';
    strForm_c{end+1} = '%s';
    strForm_c{end+1} = '%s';
    strForm_c{end+1} = '%s';
    strForm_c{end+1} = '%s';
    strForm_c{end+1} = '%u';
    strForm_c{end+1} = '%s';
    strForm_c{end+1} = '%u';
    strForm_c{end+1} = '%f';
    strForm_c{end+1} = '%s';
    strForm_c{end+1} = '%s';
    strForm_c{end+1} = '%u';
    strForm_c{end+1} = '%s';
    strForm_c{end+1} = '%s';
    strForm_c{end+1} = '%u';
    strForm_c{end+1} = '%f';
    strForm_c{end+1} = '%u';
    strForm_c{end+1} = '%u';
    strForm_c{end+1} = '%u';
    strForm_c{end+1} = '%s';
    strForm_c{end+1} = '%u';
    strForm_c{end+1} = '%u';
    strForm_c{end+1} = '%u';
    strForm_c{end+1} = '%s';
    strForm_c{end+1} = '%u';
    strForm_c{end+1} = '%f';
    strForm_c{end+1} = '%f';
    strForm_c{end+1} = '%s';
    strForm_c{end+1} = '%u';
    strForm_c{end+1} = '%u';
    strForm_c{end+1} = '%u';
    strForm_c{end+1} = '%u';
    strForm_c{end+1} = '%u';
    strForm_c{end+1} = '%u';
    strForm_c{end+1} = '%u';
    strForm_c{end+1} = '%u';
    strForm_c{end+1} = '%s';
    strForm_c{end+1} = '%u';
    strForm_c{end+1} = '%f';
    strForm_c{end+1} = '%f';
    strForm_c{end+1} = '%f';
    strForm_c{end+1} = '%s';
    strForm_c{end+1} = '%s';
    strForm_c{end+1} = '%s';
    strForm_c{end+1} = '%s';
    strForm_c{end+1} = '%s';
    strForm_c{end+1} = '%f';
    strForm_c{end+1} = '%s';
    strForm_c{end+1} = '%f';
    strForm_c{end+1} = '%s';
    strForm_c{end+1} = '%s';
    strForm_c{end+1} = '%s';
    strForm_c{end+1} = '%f';
    strForm_c{end+1} = '%s';
    strForm_c{end+1} = '%f';
    strForm_c{end+1} = '%s';
    strForm_c{end+1} = '%s';
    strForm_c{end+1} = '%s';
    strForm_c{end+1} = '%f'; %67
    strForm_c{end+1} = '%s';
    strForm_c{end+1} = '%s';
    strForm_c{end+1} = '%s'; %70
    strForm_c{end+1} = '%s';
    strForm_c{end+1} = '%s';
    strForm_c{end+1} = '%s';
    strForm_c{end+1} = '%s';
    strForm_c{end+1} = '%f';
    strForm_c{end+1} = '%f'; %76
    
    strForm_s = [strForm_c{:}, '\n'];
    
    fid = fopen(filename);
    temp_c = textscan(fid, strForm_s, 'Headerlines', 1, ...
        'Delimiter', {','}, 'Whitespace', '', 'TreatAsEmpty', '-');
    
    while ~feof(fid)
        
        temp2_c = textscan(fid, strForm_s, 'Headerlines', 1, ...
        'Delimiter', {','}, 'Whitespace', '', 'TreatAsEmpty', '-');
        temp_c(end+1, :) = temp2_c;
    end
    
    fclose(fid);
    temp_c(end, :) = [];
    
    ShipName = cell2table(temp_c, 'VariableNames', headers_c);
    
end

% Filter
if iscell(ShipName.ReportEndUtcTime)
    rawDate = cellfun(@(x) datenum(x{1}, 'yyyy-mm-dd HH:MM'), ...
        ShipName.ReportEndUtcTime, 'Uni', 1, 'Err', @(x, y) nan(1));
else
    rawDate = datenum(ShipName.ReportEndUtcTime, 'yyyy-mm-dd HH:MM'); %'dd-mm-yyyy HH:MM' ); %  );
end

rawSI = ShipName.SpeedIndexCombined;
if iscell(rawSI)
    rawSI(cellfun(@(x) isequal(x, '-'), rawSI)) = {nan};
    rawSI(cellfun(@isempty, rawSI)) = {nan};
    rawSI(~cellfun(@isscalar, rawSI)) = {nan};
    if any(cellfun(@(x) isequal(class(x), 'char'), rawSI))
        rawSI = cellfun(@str2double, rawSI);
    else
        rawSI = [rawSI{:}];
    end
end

datefilt_l = rawDate >= datenum(DDdate, 'dd-mm-yy');

if iscell(ShipName.WavesState)
    waves_c = ShipName.WavesState;
    waves_c(cellfun(@isempty, waves_c)) = {nan};
    waves_c(~cellfun(@isscalar, waves_c)) = {nan};
    waves_v = [waves_c{:}];
else
    waves_v = ShipName.WavesState;
end

if iscell(ShipName.MinimumWaterDepth)
    depth_c = ShipName.MinimumWaterDepth;
    depth_c(cellfun(@isempty, depth_c)) = {nan};
    depth_c(~cellfun(@isscalar, depth_c)) = {nan};
    depth_v = [depth_c{:}];
else
    depth_v = ShipName.MinimumWaterDepth;
end

waves_v = waves_v(datefilt_l);
depth_v = depth_v(datefilt_l);
dateDate = rawDate(datefilt_l);
dateSI = rawSI(datefilt_l);

waves_l = waves_v < 5;
depth_l = depth_v > 54;
filt_l = waves_l & depth_l;

filtDate = dateDate(filt_l);
filtSI = dateSI(filt_l);
unFiltDate = dateDate(~filt_l);
unFiltSI = dateSI(~filt_l);

si = filtSI;
dates = filtDate;

% Plot
figHandle = figure;
si_line = plot(filtDate, filtSI, 'g^');
si_line.MarkerFaceColor = [0, 0.75, 0];
si_line.Color = [0, 0.75, 0];
% hold on;
% unFilt_line = plot(unFiltDate, unFiltSI, 'g^');
% hold off;
% unFilt_line.MarkerFaceColor = unFilt_line.Color;

[~, shipname] = fileparts(filename);
title_s = 'Combined Speed Index against Time';
if isempty(shipname)
    title_s = [title_s, ' for Vessel ', shipname];
end

title(title_s, 'fontsize', 13);
% legend('Data after Filtering', 'Data filtered out')
set(gcf, 'Color', [1, 1, 1])
datetick('x', 'yyyy')

dataTable = ShipName;


end