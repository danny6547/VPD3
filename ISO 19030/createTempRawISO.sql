/* Select data for ISO 19030 analysis from RawData table for a given IMO and store in temporary table for analysis, TempRawIso. */

DROP PROCEDURE IF EXISTS createTempRawISO;

delimiter //

CREATE PROCEDURE createTempRawISO(vcid INT)
BEGIN
	
	DROP TABLE IF EXISTS tempRawISO;
    
	/* CREATE TABLE tempRawISO LIKE rawdata; */
    /* Creating table with all columns much faster than adding later */
	CREATE TABLE tempRawISO (id INT PRIMARY KEY AUTO_INCREMENT,
							 Timestamp DATETIME NOT NULL,
							 Vessel_Id INT(10) NOT NULL,
							 Latitude FLOAT(15, 5),
							 Longitude FLOAT(15, 5),
							 Relative_Wind_Speed FLOAT(15, 5),
							 Relative_Wind_Direction FLOAT(15, 5),
							 Speed_Over_Ground FLOAT(15, 5),
							 Ship_Heading FLOAT(15, 5),
							 Shaft_Revolutions FLOAT(15, 5),
							 Static_Draught_Fore FLOAT(15, 5),
							 Static_Draught_Aft FLOAT(15, 5),
							 Water_Depth FLOAT(15, 5),
							 Rudder_Angle FLOAT(15, 5),
							 Seawater_Temperature FLOAT(15, 5),
							 Air_Temperature FLOAT(10, 8),
							 Air_Pressure FLOAT(10, 6),
							 Speed_Through_Water FLOAT(15, 5),
							 Air_Density FLOAT(10, 9),
							 Delivered_Power FLOAT(20, 3),
							 Shaft_Power FLOAT(15, 5),
							 Brake_Power FLOAT(20, 3),
							 Shaft_Torque FLOAT(15, 5),
							 Mass_Consumed_Fuel_Oil FLOAT(20, 10),
							 Volume_Consumed_Fuel_Oil FLOAT(15, 5),
							 Temp_Fuel_Oil_At_Flow_Meter FLOAT(15, 5),
							 Displacement FLOAT(20, 10),
                             Vessel_Configuration_Id	int(10) NOT NULL,
						Raw_Data_Id	bigint(19) NOT NULL,
						Lower_Caloirifc_Value_Fuel_Oil float(15, 8),
						Normalised_Energy_Consumption float(15, 8),
						Density_Fuel_Oil_15C float(15, 8),
						Density_Change_Rate_Per_C float(15, 8),
						Wind_Resistance_Relative float(15, 8),
						Air_Resistance_No_Wind float(15, 8),
						Expected_Speed_Through_Water float(15, 8),
						/*Displacement float(15, 8),*/
						Speed_Loss float(15, 8),
						Transverse_Projected_Area_Current float(15, 8),
						Relative_Wind_Speed_Reference float(15, 8),
						Relative_Wind_Direction_Reference float(15, 8),
						Wind_Reference_Height float(15, 8),
						True_Wind_Speed float(15, 8),
						True_Wind_Direction float(15, 8),
						True_Wind_Speed_Reference float(15, 8),
						True_Wind_Direction_Reference float(15, 8),
						Wind_Resistance_Correction float(15, 8),
						Corrected_Power float(15, 8),
						Filter_SpeedPower_Disp_Trim BIT(1),
						Filter_SpeedPower_Trim BIT(1),
						Filter_SpeedPower_Disp BIT(1),
						Filter_SpeedPower_Below BIT(1),
						Filter_SpeedPower_Above BIT(1),
						Nearest_Displacement float(15, 8),
						Nearest_Trim float(15, 8),
						Trim float(15, 8),
						Chauvenet_Criteria BIT(1),
						Validated BIT(1),
						Displacement_Correction_Needed BIT(1),
						Filter_SFOC_Out_Range BIT(1),
						Filter_Reference_Seawater_Temp BIT(1),
						Filter_Reference_Wind_Speed BIT(1),
						Filter_Reference_Water_Depth BIT(1),
						Filter_Reference_Rudder_Angle BIT(1),
						Invalid_Rpm BIT(1),
						Invalid_Rudder_Angle BIT(1),
						Invalid_Speed_Over_Ground BIT(1),
						Invalid_Speed_Through_Water BIT(1),
						Chauvenet_Delivered_Power BIT(1),
						Chauvenet_Shaft_Revolutions BIT(1),
						Chauvenet_Relative_Wind_Speed BIT(1),
						Chauvenet_Relative_Wind_Direction BIT(1),
						Chauvenet_Speed_Over_Ground BIT(1),
						Chauvenet_Ship_Heading BIT(1),
						Chauvenet_Rudder_Angle BIT(1),
						Chauvenet_Water_Depth  BIT(1),
						Chauvenet_Air_Temperature BIT(1),
						Chauvenet_Static_Draught_Fore BIT(1),
						Chauvenet_Static_Draught_Aft  BIT(1),
						Chauvenet_Seawater_Temperature BIT(1),
						Wind_Resistance_Applied BIT(1),
						ErrorCode int(10),
						MeasurementDate	date,
						MeasurementTime	time(6),
						 CONSTRAINT UniqueDates UNIQUE(Timestamp)
						 ) ENGINE = MYISAM;
	
	INSERT INTO tempRawISO (Raw_Data_Id, Timestamp, Vessel_Id, Latitude, Longitude, Relative_Wind_Speed, Relative_Wind_Direction, Speed_Over_Ground, Ship_Heading, Shaft_Revolutions, Static_Draught_Fore, Static_Draught_Aft, Water_Depth, Rudder_Angle, Seawater_Temperature, Air_Temperature, Air_Pressure, Speed_Through_Water, Air_Density, Delivered_Power, Shaft_Power, Brake_Power, Shaft_Torque, Mass_Consumed_Fuel_Oil, Volume_Consumed_Fuel_Oil, Temp_Fuel_Oil_At_Flow_Meter, Displacement)
		SELECT Raw_Data_Id, Timestamp, Vessel_Id, Latitude, Longitude, Relative_Wind_Speed, Relative_Wind_Direction, Speed_Over_Ground, Ship_Heading, Shaft_Revolutions, Static_Draught_Fore, Static_Draught_Aft, Water_Depth, Rudder_Angle, Seawater_Temperature, Air_Temperature, Air_Pressure, Speed_Through_Water, Air_Density, Delivered_Power, Shaft_Power, Brake_Power, Shaft_Torque, Mass_Consumed_Fuel_Oil, Volume_Consumed_Fuel_Oil, Temp_Fuel_Oil_At_Flow_Meter, Displacement
			FROM rawdata WHERE Vessel_Id = (SELECT Vessel_Id from VesselConfiguration WHERE Vessel_Configuration_Id = vcid);
    
END