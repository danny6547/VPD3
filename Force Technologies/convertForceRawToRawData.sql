/* Create columns and update values in temp Force raw table to match those of table RawData, based on the RawData definitions given in the ISO 19030 standard */

DROP PROCEDURE IF EXISTS convertForceRawToRawData;

delimiter //

CREATE PROCEDURE convertForceRawToRawData()
BEGIN
	
    /* Input */
    DECLARE knots2SI DOUBLE(10, 10);
    DECLARE Fluid_Density INT(4);
    
    SET knots2SI := 0.5144444444;
    SET Fluid_Density := 1.025;
    
    /* Datetime is midpoint of start and end */
    UPDATE tempForceRaw SET DateTime_UTC = ADDTIME(Start, SEC_TO_TIME(TIME_TO_SEC(timediff(xEnd, Start))/2));
    
    UPDATE tempForceRaw SET IMO_Vessel_Number = imo_number;
    
    /* Lat and Lon are just combinations of their d,m,s components*/
    UPDATE tempForceRaw SET Latitude = lat_mean;
    UPDATE tempForceRaw SET Longitude = lon_mean;
    
    /* Conver from knots to mps */
    UPDATE tempForceRaw SET Speed_Over_Ground = sog_mean; /*knots2mps(sog_mean);*/
    UPDATE tempForceRaw SET Speed_Through_Water = stw_mean; /*knots2mps(stw_mean);*/
    UPDATE tempForceRaw SET Relative_Wind_Speed = wins_mean; /*knots2mps(wins_mean);*/
    
    /* Convert from radians to degrees */
    UPDATE tempForceRaw SET Ship_Heading = rad2deg(hdt_mean) + 180;
    UPDATE tempForceRaw SET Relative_Wind_Direction = rad2deg(wind_mean) + 180;
    
    /* Assign */
    UPDATE tempForceRaw SET Air_Temperature = airt_mean;
    UPDATE tempForceRaw SET Air_Pressure = airp_mean;
    UPDATE tempForceRaw SET Rudder_Angle = rud_mean;
    UPDATE tempForceRaw SET Water_Depth = dpt_mean;
    UPDATE tempForceRaw SET Shaft_Power = spow_mean / 1e3;
    UPDATE tempForceRaw SET Shaft_Revolutions = srpm_mean;
    UPDATE tempForceRaw SET Shaft_Torque = strq_mean / 1e3;
    UPDATE tempForceRaw SET Static_Draught_Aft = draught_aft;
    UPDATE tempForceRaw SET Static_Draught_Fore = draught_fore;
    
    /* Cannot simply assign mass consumed fuel oil because different time stamps (put in noon report table?)*/
    
    /* Assign into noon data table */
    
END;