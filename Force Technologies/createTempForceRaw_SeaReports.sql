/* Create tempRaw table, a temporary table used to insert data from DNVGLRaw to RawData */

DROP PROCEDURE IF EXISTS createTempForceRaw_SeaReports;

delimiter //

CREATE PROCEDURE createTempForceRaw_SeaReports(imo INT)

BEGIN

DROP TABLE IF EXISTS tempForceRaw_SR;
/* CREATE TABLE tempRaw LIKE dnvglraw; */

CREATE TABLE tempForceRaw_SR LIKE `force`.`forceSeaReports`;

ALTER TABLE tempForceRaw_SR ADD COLUMN Seawater_Temperature DOUBLE (20, 5), 
						ADD COLUMN IMO_Vessel_Number INT(7),
						ADD COLUMN DateTime_UTC DATETIME,
						ADD COLUMN Latitude DOUBLE (10, 8), 
						ADD COLUMN Longitude DOUBLE (10, 7), 
						ADD COLUMN Displacement DOUBLE (20, 5), 
						ADD COLUMN Air_Temperature DOUBLE (20, 5), 
						ADD COLUMN Mass_Consumed_Fuel_Oil DOUBLE (20, 5), 
						ADD COLUMN Air_Pressure DOUBLE (20, 5),
						ADD COLUMN Relative_Wind_Speed DOUBLE (20, 5), 
						ADD COLUMN Relative_Wind_Direction DOUBLE (20, 5),
						ADD COLUMN Shaft_Revolutions DOUBLE (20, 5),
						ADD COLUMN Static_Draught_Fore DOUBLE (20, 5),
						ADD COLUMN Static_Draught_Aft DOUBLE (20, 5),
						ADD COLUMN Lower_Caloirifc_Value_Fuel_Oil DOUBLE (20, 5),
						ADD COLUMN Density_Fuel_Oil_15C DOUBLE (20, 5),
						ADD COLUMN Speed_Over_Ground DOUBLE (20, 5),
                        ADD COLUMN Speed_Through_Water DOUBLE (20, 5),
                        ADD COLUMN Delivered_Power DOUBLE (20, 5),
                        ADD COLUMN Ship_Heading DOUBLE (20, 5),
                        ADD COLUMN Shaft_Torque DOUBLE (20, 5),
                        ADD COLUMN Water_Depth DOUBLE (20, 5)
;

/* Seawater_Temperature, Displacement, Air_Temperature, Mass_Consumed_Fuel_Oil, Air_Pressure, Relative_Wind_Speed, Relative_Wind_Direction, Speed_Over_Ground, Shaft_Revolutions, Static_Draught_Fore, Static_Draught_Aft, */

INSERT INTO tempForceRaw_SR (VesselName, VesselIMONumber, VoyageNumber, DeparturePort, DepartureLocalTime, DepartureUtcTime, DepartureTimeZone, DepartureIsDaylightTime, ArrivalPort, ArrivalLocalTime, ArrivalUtcTime, ArrivalTimeZone, ArrivalIsDaylightTime, RemainingDistance, RemainingTime, ReportStartLocalTime, ReportStartUtcTime, ReportStartTimeZone, ReportEndLocalTime, ReportEndUtcTime, ReportEndTimeZone, ReportPeriod, LatitudeDegrees, LatitudeMinutes, LatitudeSeconds, LatitudeSign, LongitudeDegrees, LongitudeMinutes, LongitudeSeconds, LongitudeSign, Heading, DraughtAft, DraughtFore, DistanceLogged, DistanceObserved, WindSpeed, WindDirection, AirTemperature, MinimumWaterDepth, WaterTemperature, WavesState, WavesDirection, MainEnginePower, TcSpeed, PropellerSpeed, PumpIndex, SGProduction, CPPropellerPitch, MainEngineHFOConsumption, MainEngineHFOLsConsumption, MainEngineMDOConsumption, MainEngineMDOLsConsumption, MainEngineMGOConsumption, MainEngineBioConsumption, TotalHFOConsumption, TotalHFOLsConsumption, TotalMDOConsumption, TotalMDOLsConsumption, TotalMGOConsumption, TotalBioConsumption, RemainingHFO, RemainingHFOLs, RemainingMDO, RemainingMDOLs, RemainingMGO, RemainingBio, LowerCalorificValueForHFO, LowerCalorificValueForHFOLs, LowerCalorificValueForMDO, LowerCalorificValueForMDOLs, LowerCalorificValueForMGO, LowerCalorificValueForBio, ShaftThrust, Comments, SpeedIndexCombined, ConsumptionIndexCombined)
	(SELECT VesselName, VesselIMONumber, VoyageNumber, DeparturePort, DepartureLocalTime, DepartureUtcTime, DepartureTimeZone, DepartureIsDaylightTime, ArrivalPort, ArrivalLocalTime, ArrivalUtcTime, ArrivalTimeZone, ArrivalIsDaylightTime, RemainingDistance, RemainingTime, ReportStartLocalTime, ReportStartUtcTime, ReportStartTimeZone, ReportEndLocalTime, ReportEndUtcTime, ReportEndTimeZone, ReportPeriod, LatitudeDegrees, LatitudeMinutes, LatitudeSeconds, LatitudeSign, LongitudeDegrees, LongitudeMinutes, LongitudeSeconds, LongitudeSign, Heading, DraughtAft, DraughtFore, DistanceLogged, DistanceObserved, WindSpeed, WindDirection, AirTemperature, MinimumWaterDepth, WaterTemperature, WavesState, WavesDirection, MainEnginePower, TcSpeed, PropellerSpeed, PumpIndex, SGProduction, CPPropellerPitch, MainEngineHFOConsumption, MainEngineHFOLsConsumption, MainEngineMDOConsumption, MainEngineMDOLsConsumption, MainEngineMGOConsumption, MainEngineBioConsumption, TotalHFOConsumption, TotalHFOLsConsumption, TotalMDOConsumption, TotalMDOLsConsumption, TotalMGOConsumption, TotalBioConsumption, RemainingHFO, RemainingHFOLs, RemainingMDO, RemainingMDOLs, RemainingMGO, RemainingBio, LowerCalorificValueForHFO, LowerCalorificValueForHFOLs, LowerCalorificValueForMDO, LowerCalorificValueForMDOLs, LowerCalorificValueForMGO, LowerCalorificValueForBio, ShaftThrust, Comments, SpeedIndexCombined, ConsumptionIndexCombined
		FROM ForceSeaReports WHERE VesselIMONumber = imo);

CALL convertForceSeaReportsToRawData;

END;