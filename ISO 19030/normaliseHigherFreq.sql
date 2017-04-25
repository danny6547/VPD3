/* Average high-frequency data to a lower frequency */
/* Assumptions: */
/* 1. The first two non-null values of the primary parameter will be taken as the timestep to which all secondary parameters at a higher frequency will be averaged. */
/* 2. The series of durations over which the parameters will be averaged begins at the first row. */
/* 3. The highest precision in DateTime_UTC is 1 second (procedure may work as intended if additional precision given for this value). */




DROP PROCEDURE IF EXISTS normaliseHigherFreq;

delimiter //

CREATE PROCEDURE normaliseHigherFreq()

BEGIN

    DECLARE timeStep DOUBLE(20, 3);
    DECLARE minTime INT8(12);
    
    /* Check for higher-frequency secondary parameters */
    
    /* Get primary parameter timestep */
    SET timeStep := (SELECT (SELECT to_seconds(DateTime_UTC) FROM tempRawISO WHERE Speed_Over_Ground IS NOT NULL LIMIT 1, 1) - 
		(SELECT to_seconds(DateTime_UTC) FROM tempRawISO WHERE Speed_Over_Ground IS NOT NULL LIMIT 0, 1) );
	SET minTime = (SELECT TO_SECONDS(MIN(DateTime_UTC)) FROM tempRawISO);
    
    /* Average all secondary parameters to this value */
    DROP TABLE IF EXISTS tempRawISO1;
    CREATE TABLE tempRawISO1 LIKE tempRawISO;
    
    INSERT INTO tempRawISO1 (DateTime_UTC, IMO_Vessel_Number, Relative_Wind_Speed, Relative_Wind_Direction, Speed_Over_Ground, Ship_Heading, Shaft_Revolutions, Static_Draught_Fore, Static_Draught_Aft, Water_Depth, Rudder_Angle, Seawater_Temperature, Air_Temperature, Air_Pressure, Air_Density, Speed_Through_Water, Delivered_Power, Shaft_Power, Brake_Power, Shaft_Torque, Mass_Consumed_Fuel_Oil, Volume_Consumed_Fuel_Oil, Displacement) 
    SELECT (DateTime_UTC), IMO_Vessel_Number, AVG(Relative_Wind_Speed), AVG(Relative_Wind_Direction), AVG(Speed_Over_Ground), AVG(Ship_Heading), AVG(Shaft_Revolutions), AVG(Static_Draught_Fore), AVG(Static_Draught_Aft), AVG(Water_Depth), AVG(Rudder_Angle), AVG(Seawater_Temperature), AVG(Air_Temperature), AVG(Air_Pressure), AVG(Air_Density), AVG(Speed_Through_Water), AVG(Delivered_Power), AVG(Shaft_Power), AVG(Brake_Power), AVG(Shaft_Torque), AVG(Mass_Consumed_Fuel_Oil), AVG(Volume_Consumed_Fuel_Oil), AVG(Displacement)
		FROM tempRawISO
			GROUP BY FLOOR((TO_SECONDS(DateTime_UTC) - minTime) / timeStep);
    
    DROP TABLE tempRawISO;
    RENAME TABLE tempRawISO1 TO tempRawISO;
    
END;