/* Create columns and update values in temp Force raw table to match those of table RawData, based on the RawData definitions given in the ISO 19030 standard */

DROP PROCEDURE IF EXISTS convertForceSeaReportsToRawData;

delimiter //

CREATE PROCEDURE convertForceSeaReportsToRawData()
BEGIN
	
    /* Datetime is midpoint of start and end */
    /* UPDATE tempForceRaw_SR SET DateTime_UTC = ReportStartUtcTime + timediff(ReportStartUtcTime, ReportEndUtcTime)/2; */
    UPDATE tempForceRaw_SR SET DateTime_UTC = DATE_ADD(ReportStartUtcTime, 
		INTERVAL (HOUR(TIMEDIFF(ReportEndUtcTime, ReportStartUtcTime))*3600 + 
				MINUTE(TIMEDIFF(ReportEndUtcTime, ReportStartUtcTime))*60 +
                SECOND(TIMEDIFF(ReportEndUtcTime, ReportStartUtcTime)))/2 SECOND);
    
    /* Lat and Lon are just combinations of their d,m,s components*/
    UPDATE tempForceRaw_SR SET Latitude = LatitudeDegrees + LatitudeMinutes/60 + LatitudeSeconds/3600;
    UPDATE tempForceRaw_SR SET Longitude = LongitudeDegrees + LongitudeMinutes/60 + LongitudeSeconds/3600;
    
    UPDATE tempForceRaw_SR
		SET Latitude = CASE
			WHEN LatitudeSign = 'N' THEN LatitudeDegrees + LatitudeMinutes/60 + LatitudeSeconds/3600
			WHEN LatitudeSign = 'S' THEN -(LatitudeDegrees + LatitudeMinutes/60 + LatitudeSeconds/3600)
		END
		WHERE LatitudeSign IN ('N', 'S');
        
    UPDATE tempForceRaw_SR
		SET Longitude = CASE
			WHEN LongitudeSign = 'E' THEN LongitudeDegrees + LongitudeMinutes/60 + LongitudeSeconds/3600
			WHEN LongitudeSign = 'W' THEN -(LongitudeDegrees + LongitudeMinutes/60 + LongitudeSeconds/3600)
		END
		WHERE LongitudeSign IN ('E', 'W');
    
    /* Convert from knots to mps */
    UPDATE tempForceRaw_SR SET Speed_Over_Ground = knots2mps(DistanceObserved/ReportPeriod);
    UPDATE tempForceRaw_SR SET Speed_Through_Water = knots2mps(DistanceLogged/ReportPeriod);
    UPDATE tempForceRaw_SR SET Relative_Wind_Speed = knots2mps(WindSpeed);
    
    /* Assign */
    UPDATE tempForceRaw_SR SET IMO_Vessel_Number = VesselIMONumber;
    UPDATE tempForceRaw_SR SET Water_Depth = MinimumWaterDepth;
    UPDATE tempForceRaw_SR SET Shaft_Revolutions = TcSpeed;
    UPDATE tempForceRaw_SR SET Static_Draught_Fore = DraughtFore;
    UPDATE tempForceRaw_SR SET Static_Draught_Aft = DraughtAft;
    UPDATE tempForceRaw_SR SET Seawater_Temperature = WaterTemperature;
    UPDATE tempForceRaw_SR SET Air_Temperature = AirTemperature;
    UPDATE tempForceRaw_SR SET Mass_Consumed_Fuel_Oil = MainEngineHFOConsumption;
    UPDATE tempForceRaw_SR SET Delivered_Power = MainEnginePower;
    UPDATE tempForceRaw_SR SET Shaft_Revolutions = PropellerSpeed;
    UPDATE tempForceRaw_SR SET Ship_Heading = Heading;
    UPDATE tempForceRaw_SR SET Relative_Wind_Direction = WindDirection;
    
    /* Shaft Torque can come from shaft power */
    UPDATE tempForceRaw_SR SET Shaft_Torque = Delivered_Power / (Shaft_Revolutions * (2 * PI() / 60));
    
    /* Convert from radians to degrees */
    
    /* Assign */
    /*UPDATE tempForceRaw_SR SET Rudder_Angle = rud_mean;
    
    /* Cannot simply assign mass consumed fuel oil because different time stamps (put in noon report table?)*/
    
    /* Assign into noon data table */
    
END;