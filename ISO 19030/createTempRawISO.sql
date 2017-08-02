/* Select data for ISO 19030 analysis from RawData table for a given IMO and store in temporary table for analysis, TempRawIso. */



DROP PROCEDURE IF EXISTS createTempRawISO;

delimiter //

CREATE PROCEDURE createTempRawISO(imo INT)
BEGIN
	
	DROP TABLE IF EXISTS tempRawISO;
    
	/* CREATE TABLE tempRawISO LIKE rawdata; */
    /* Creating table with all columns much faster than adding later */
	CREATE TABLE tempRawISO (id INT PRIMARY KEY AUTO_INCREMENT,
							 DateTime_UTC DATETIME(3),
							 IMO_Vessel_Number INT(7),
							 Relative_Wind_Speed DOUBLE(10, 5),
							 Relative_Wind_Direction DOUBLE(10, 5),
							 Speed_Over_Ground DOUBLE(10, 5),
							 Ship_Heading DOUBLE(10, 5),
							 Shaft_Revolutions DOUBLE(10, 5),
							 Static_Draught_Fore DOUBLE(10, 5),
							 Static_Draught_Aft DOUBLE(10, 5),
							 Water_Depth DOUBLE(20, 5),
							 Rudder_Angle DOUBLE(10, 5),
							 Seawater_Temperature DOUBLE(10, 5),
							 Air_Temperature DOUBLE(10, 8),
							 Air_Pressure DOUBLE(10, 3),
							 Air_Density DOUBLE(10, 9),
							 Speed_Through_Water DOUBLE(10, 5),
							 Delivered_Power DOUBLE(20, 3),
							 Shaft_Power DOUBLE(10, 5),
							 Brake_Power DOUBLE(20, 3),
							 Shaft_Torque DOUBLE(10, 5),
							 Mass_Consumed_Fuel_Oil DOUBLE(20, 10),
							 Volume_Consumed_Fuel_Oil DOUBLE(10, 5),
							 Lower_Caloirifc_Value_Fuel_Oil DOUBLE(10, 5),
							 Normalised_Energy_Consumption DOUBLE(10, 5),
							 Density_Fuel_Oil_15C DOUBLE(10, 5),
							 Density_Change_Rate_Per_C DOUBLE(10, 5),
							 Temp_Fuel_Oil_At_Flow_Meter DOUBLE(10, 5),
							 Wind_Resistance_Relative DOUBLE(20, 5),
							 Air_Resistance_No_Wind DOUBLE(20, 10),
							 Expected_Speed_Through_Water DOUBLE(10, 5),
							 Displacement DOUBLE(20, 10),
							 Speed_Loss DOUBLE(20, 5),
							 Transverse_Projected_Area_Current DOUBLE(10, 5),
                             Relative_Wind_Speed_Reference DOUBLE(10, 5),
                             Relative_Wind_Direction_Reference DOUBLE(10, 5),
                             Wind_Reference_Height DOUBLE(10, 5),
                             True_Wind_Speed DOUBLE(10, 5),
                             True_Wind_Direction DOUBLE(10, 5),
                             True_Wind_Speed_Reference DOUBLE(10, 5),
                             True_Wind_Direction_Reference DOUBLE(10, 5),
							 Wind_Resistance_Correction DOUBLE(20, 5),
							 Corrected_Power DOUBLE(20, 3),
							 Filter_SpeedPower_Disp_Trim BOOLEAN,
							 Filter_SpeedPower_Trim BOOLEAN,
							 Filter_SpeedPower_Disp BOOLEAN,
							 Filter_Power_Below BOOLEAN,
							 Filter_Power_Above BOOLEAN,
							 Filter_Speed_Below BOOLEAN,
							 Filter_Speed_Above BOOLEAN,
							 NearestDisplacement DOUBLE(20, 10),
							 NearestTrim DOUBLE(10, 5),
							 Trim DOUBLE(10, 5),
							 Chauvenet_Criteria BOOLEAN,
							 Validated BOOLEAN,
							 Displacement_Correction DOUBLE(20, 3),
							 Filter_All BOOLEAN DEFAULT FALSE,
							 Filter_SFOC_Out_Range BOOLEAN DEFAULT FALSE,
							 Filter_Reference_Seawater_Temp BOOLEAN DEFAULT FALSE,
							 Filter_Reference_Wind_Speed BOOLEAN DEFAULT FALSE,
							 Filter_Reference_Water_Depth BOOLEAN DEFAULT FALSE,
							 Filter_Reference_Rudder_Angle BOOLEAN DEFAULT FALSE,
							 WVX DOUBLE(10, 5),
							 WVY DOUBLE(10, 5),
							 WindCoefficient DOUBLE(10, 5),
                             CONSTRAINT UniqueDates UNIQUE(DateTime_UTC)
							 ) ENGINE = MYISAM;
	
	INSERT INTO tempRawISO (DateTime_UTC, IMO_Vessel_Number, Relative_Wind_Speed, Relative_Wind_Direction, Speed_Over_Ground, Ship_Heading, Shaft_Revolutions, Static_Draught_Fore, Static_Draught_Aft, Water_Depth, Rudder_Angle, Seawater_Temperature, Air_Temperature, Air_Pressure, Air_Density, Speed_Through_Water, Delivered_Power, Shaft_Power, Brake_Power, Shaft_Torque, Mass_Consumed_Fuel_Oil, Volume_Consumed_Fuel_Oil, Displacement)
		SELECT DateTime_UTC, IMO_Vessel_Number, Relative_Wind_Speed, Relative_Wind_Direction, Speed_Over_Ground, Ship_Heading, Shaft_Revolutions, Static_Draught_Fore, Static_Draught_Aft, Water_Depth, Rudder_Angle, Seawater_Temperature, Air_Temperature, Air_Pressure, Air_Density, Speed_Through_Water, Delivered_Power, Shaft_Power, Brake_Power, Shaft_Torque, Mass_Consumed_Fuel_Oil, Volume_Consumed_Fuel_Oil, Displacement
			FROM rawdata WHERE IMO_Vessel_Number = imo;
    
END