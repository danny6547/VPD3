/* Create columns and update values in temp DNVGL raw table to match those of table RawData, based on the RawData definitions given in the ISO 19030 standard */

USE hull_performance;

DROP PROCEDURE IF EXISTS convertDNVGLRawToRawData;

delimiter //

CREATE PROCEDURE convertDNVGLRawToRawData()
BEGIN
	
    /* Input */
    DECLARE knots2SI DOUBLE(10, 10);
    DECLARE Fluid_Density INT(4);
    
    SET knots2SI := 0.5144444444;
    SET Fluid_Density := 1025;
    
    /* Add columns matching those in rawdata table, update values appropriately */
    UPDATE tempRaw SET Relative_Wind_Speed = Wind_Force_Kn * knots2SI;           /* Assume wind recorded is relative to ship's frame of reference */
    
    UPDATE tempRaw SET Relative_Wind_Direction = Wind_Dir;           /* Assume ship forward direction is 0, clockwise positive*/
	
    UPDATE tempRaw SET Speed_Over_Ground = Speed_GPS;           /* Assume wind recorded is relative to ship's frame of reference */
    
    /* Ship heading not found in DNVGL raw files. Data required by ISO only for calculation of true wind speed and direction, not used in performance analysis.
	ALTER TABLE tempRaw ADD Ship_Heading DOUBLE (10, 5);
    UPDATE tempRaw SET Ship_Heading = NULL;           /* Assume wind recorded is relative to ship's frame of reference */
	
    UPDATE tempRaw SET Shaft_Revolutions = ME_1_Speed_RPM;           /* Assume one main engine */
    
    UPDATE tempRaw SET Static_Draught_Fore = Draft_Actual_Fore;
    
    UPDATE tempRaw SET Static_Draught_Aft = Draft_Actual_Aft;
    
    /* Skip water depth, name and meaning equivalent
	ALTER TABLE tempRaw ADD Water_Depth DOUBLE(10, 5);
    UPDATE tempRaw SET Water_Depth = Water_Depth;            */
    
    /* Rudder Angle not found in DNVGL raw files. Data required by ISO only for calculation of true wind speed and direction, not used in performance analysis.
	ALTER TABLE tempRaw ADD Rudder_Angle DOUBLE (10, 5);
    UPDATE tempRaw SET Rudder_Angle = NULL;           /* Assume wind recorded is relative to ship's frame of reference */
    
    UPDATE tempRaw SET Seawater_Temperature = Temperature_Water;
    
    UPDATE tempRaw SET Air_Temperature = Temperature_Ambient;
    
    UPDATE tempRaw SET Air_Pressure = ME_Barometric_Pressure;           /* Assumes that ship has only one engine, and that air intake pressure is a sufficient approximation for atmospheric pressure.*/
    
    /* Air density is a derived value */
    
    /* Speed through water
    ALTER TABLE tempRaw ADD Speed_Through_Water DOUBLE(10, 5);
    UPDATE tempRaw SET Speed_Through_Water = Speed_Through_Water;         */
    
    /* Delivered Power is a derived value. It could be read from input after further code development. */
    
    /* Shaft Power is a derived value. It could be optionally read from input after further code development. */
    
    /* Brake Power is a derived value. */
    
    /* Shaft Torque not found in DNVGL raw files. Procedure `updateShaftPower` not compatible with this input file type. */
    
    UPDATE tempRaw SET Mass_Consumed_Fuel_Oil = ME_Consumption * 1e3;           /* Assume only one engine. */
    
    /* Volume of consumed fuel oil not found in DNVGL raw files. Procedure `updateMassFuelOilConsumed` not compatible with this input file type. */
    
    /* LCV is a bunker report variable. It can be read from bunker delivery note table. */
    /* CALL updateFromBunkerNote; */
    
    /* Normalied Energy Consumed is a derived variable */
    
    /* Density_Fuel_Oil_15C is a bunker report variable and will have been updated with previous call to updateFromBunkerNote */
    
    /* Density_Change_Rate_Per_C not found in DNVGL raw files. This may be obtained from another source. */
    
    /* Temp_Fuel_Oil_At_Flow_Meter not found in DNVGL raw files. Procedure `updateMassFuelOilConsumed' not compatible with this input file type. */
    
    /* Wind_Resistance_Relative not found in DNVGL raw files. This may be obtained from another source. */
    
    /* Air_Resistance_No_Wind not found in DNVGL raw files. This may be obtained from another source. */
    
    /* Expected_Speed_Through_Water is a derived variable. */
    
    /* Displacement is a derived variable. It could be optionally read from input after further code development.
	ALTER TABLE tempRaw ADD Displacement DOUBLE(20, 10);
    UPDATE tempRaw SET Displacement = Draft_Displacement_Actual / Fluid_Density;           /* Assume units of displacement in analysis are tonnes. */
    
    /* Speed_Loss is a derived variable. */
    
    /* Transverse_Projected_Area_Current not found in DNVGL raw files. This may be obtained from another source.  */
    
    /* Wind_Resistance_Correction is a derived variable. */
    
    /* Corrected_Power is a derived variable. */
    
END;