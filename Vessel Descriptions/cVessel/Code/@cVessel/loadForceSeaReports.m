function [obj] = loadForceSeaReports(obj, filename, imo)
%loadForceSeaReports Loads Sea Report xlsx downloaded from SeaTrend
%   Detailed explanation goes here

% Inputs
filename = validateCellStr(filename);
validateattributes(imo, {'numeric'}, {'scalar', 'positive', 'integer',...
    'real', '>', 999999, '<', 10000000})

% Let's see if sheet input can be numeric
% currSheet = 1;
% firstRowIdx = 1;
% fileColID = [17, 20, 31, 32, 33, 36, 37, 38, 39, 40, 55, 43, 34, 35, 22];
fileColName = {'ReportStartUTC', 'ReportEndUTC', 'Ship_Heading', ...
        'Static_Draft_Aft', 'Static_Draft_Fore', 'Relative_Wind_Speed', ...
        'Relative_Wind_Direction', 'Air_Temperature', 'Water_Depth', ...
        'Seawater_Temperature', 'Mass_Consumed_Fuel_Oil', 'Brake_Power', ...
        'Distance_Logged', 'Distance_Observed', 'Report_Period'};
% SetSQL = {' SET Name = @VesselName'};
% SetSQL = {' SET DateTime_UTC = STR_TO_DATE(@ReportStartUTC, ''%d-%m-%Y %H:%i:%s'') + DATEDIFF(STR_TO_DATE(@ReportEndUTC, ''%d-%m-%Y %H:%i:%s''), STR_TO_DATE(@ReportStartUTC, ''%d-%m-%Y %H:%i:%s''))/2',...  
%         'Speed_Through_Water = @Distance_Logged/@Report_Period',...
%         'Speed_Over_Ground = @Distance_Observed/@Report_Period'};
% SetSQL = strjoin(SetSQL, ',');

% Get this in through the method somehow
%        FIELDS OPTIONALLY ENCLOSED BY '"' 
%       

tab = 'forceSeaReports';
delim = ';';
ignore_s = 1;

setNull_ch = ' SET `VesselName` = nullif(@`VesselName`, ''-''), `VesselIMONumber` = nullif(@`VesselIMONumber`, ''-''), `VoyageNumber` = nullif(@`VoyageNumber`, ''-''), `DeparturePort` = nullif(@`DeparturePort`, ''-''), `DepartureLocalTime` = nullif(@`DepartureLocalTime`, ''-''), `DepartureUtcTime` = nullif(@`DepartureUtcTime`, ''-''), `DepartureTimeZone` = nullif(@`DepartureTimeZone`, ''-''), `DepartureIsDaylightTime` = nullif(@`DepartureIsDaylightTime`, ''-''), `ArrivalPort` = nullif(@`ArrivalPort`, ''-''), `ArrivalLocalTime` = nullif(@`ArrivalLocalTime`, ''-''), `ArrivalUtcTime` = nullif(@`ArrivalUtcTime`, ''-''), `ArrivalTimeZone` = nullif(@`ArrivalTimeZone`, ''-''), `ArrivalIsDaylightTime` = nullif(@`ArrivalIsDaylightTime`, ''-''), `RemainingDistance` = nullif(@`RemainingDistance`, ''-''), `RemainingTime` = nullif(@`RemainingTime`, ''-''), `ReportStartLocalTime` = nullif(@`ReportStartLocalTime`, ''-''), `ReportStartUtcTime` = nullif(@`ReportStartUtcTime`, ''-''), `ReportStartTimeZone` = nullif(@`ReportStartTimeZone`, ''-''), `ReportEndLocalTime` = nullif(@`ReportEndLocalTime`, ''-''), `ReportEndUtcTime` = nullif(@`ReportEndUtcTime`, ''-''), `ReportEndTimeZone` = nullif(@`ReportEndTimeZone`, ''-''), `ReportPeriod` = nullif(@`ReportPeriod`, ''-''), `LatitudeDegrees` = nullif(@`LatitudeDegrees`, ''-''), `LatitudeMinutes` = nullif(@`LatitudeMinutes`, ''-''), `LatitudeSeconds` = nullif(@`LatitudeSeconds`, ''-''), `LatitudeSign` = nullif(@`LatitudeSign`, ''-''), `LongitudeDegrees` = nullif(@`LongitudeDegrees`, ''-''), `LongitudeMinutes` = nullif(@`LongitudeMinutes`, ''-''), `LongitudeSeconds` = nullif(@`LongitudeSeconds`, ''-''), `LongitudeSign` = nullif(@`LongitudeSign`, ''-''), `Heading` = nullif(@`Heading`, ''-''), `DraughtAft` = nullif(@`DraughtAft`, ''-''), `DraughtFore` = nullif(@`DraughtFore`, ''-''), `DistanceLogged` = nullif(@`DistanceLogged`, ''-''), `DistanceObserved` = nullif(@`DistanceObserved`, ''-''), `WindSpeed` = nullif(@`WindSpeed`, ''-''), `WindDirection` = nullif(@`WindDirection`, ''-''), `AirTemperature` = nullif(@`AirTemperature`, ''-''), `MinimumWaterDepth` = nullif(@`MinimumWaterDepth`, ''-''), `WaterTemperature` = nullif(@`WaterTemperature`, ''-''), `WavesState` = nullif(@`WavesState`, ''-''), `WavesDirection` = nullif(@`WavesDirection`, ''-''), `MainEnginePower` = nullif(@`MainEnginePower`, ''-''), `TcSpeed` = nullif(@`TcSpeed`, ''-''), `PropellerSpeed` = nullif(@`PropellerSpeed`, ''-''), `PumpIndex` = nullif(@`PumpIndex`, ''-''), `SGProduction` = nullif(@`SGProduction`, ''-''), `CPPropellerPitch` = nullif(@`CPPropellerPitch`, ''-''), `MainEngineHFOConsumption` = nullif(@`MainEngineHFOConsumption`, ''-''), `MainEngineHFOLsConsumption` = nullif(@`MainEngineHFOLsConsumption`, ''-''), `MainEngineMDOConsumption` = nullif(@`MainEngineMDOConsumption`, ''-''), `MainEngineMDOLsConsumption` = nullif(@`MainEngineMDOLsConsumption`, ''-''), `MainEngineMGOConsumption` = nullif(@`MainEngineMGOConsumption`, ''-''), `MainEngineBioConsumption` = nullif(@`MainEngineBioConsumption`, ''-''), `TotalHFOConsumption` = nullif(@`TotalHFOConsumption`, ''-''), `TotalHFOLsConsumption` = nullif(@`TotalHFOLsConsumption`, ''-''), `TotalMDOConsumption` = nullif(@`TotalMDOConsumption`, ''-''), `TotalMDOLsConsumption` = nullif(@`TotalMDOLsConsumption`, ''-''), `TotalMGOConsumption` = nullif(@`TotalMGOConsumption`, ''-''), `TotalBioConsumption` = nullif(@`TotalBioConsumption`, ''-''), `RemainingHFO` = nullif(@`RemainingHFO`, ''-''), `RemainingHFOLs` = nullif(@`RemainingHFOLs`, ''-''), `RemainingMDO` = nullif(@`RemainingMDO`, ''-''), `RemainingMDOLs` = nullif(@`RemainingMDOLs`, ''-''), `RemainingMGO` = nullif(@`RemainingMGO`, ''-''), `RemainingBio` = nullif(@`RemainingBio`, ''-''), `LowerCalorificValueForHFO` = nullif(@`LowerCalorificValueForHFO`, ''-''), `LowerCalorificValueForHFOLs` = nullif(@`LowerCalorificValueForHFOLs`, ''-''), `LowerCalorificValueForMDO` = nullif(@`LowerCalorificValueForMDO`, ''-''), `LowerCalorificValueForMDOLs` = nullif(@`LowerCalorificValueForMDOLs`, ''-''), `LowerCalorificValueForMGO` = nullif(@`LowerCalorificValueForMGO`, ''-''), `LowerCalorificValueForBio` = nullif(@`LowerCalorificValueForBio`, ''-''), `ShaftThrust` = nullif(@`ShaftThrust`, ''-''), `Comments` = nullif(@`Comments`, ''-''), `SpeedIndexCombined` = nullif(@`SpeedIndexCombined`, ''-''), `ConsumptionIndexCombined` = nullif(@`ConsumptionIndexCombined`, ''-'');';

obj.loadInFile(filename, tab, {}, delim, ignore_s, '', setNull_ch, 'optionally ''"''');

for io = 1:numel(imo)
    
    imo_ch = num2str( imo(io) );
    obj.call('insertFromForceSeaReportsIntoRaw', imo_ch);
end
% [obj, numWarnings, warnings] = obj.loadXLSX(filename, currSheet, firstRowIdx - 1, fileColID, ...
%     fileColName, tab, SetSQL);
end