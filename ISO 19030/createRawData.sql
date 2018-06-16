/* Create table for data required by ISO 19030 analysis */



DROP PROCEDURE IF EXISTS createRawData;

delimiter //

CREATE PROCEDURE createRawData()

BEGIN

CREATE TABLE `inservice`.rawdata (Raw_Data_Id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
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
                         CONSTRAINT UniqueVesselDate UNIQUE(Vessel_Id, Timestamp)
                         /*,
                         Wind_Resistance_Relative FLOAT(15, 5),
                         Air_Resistance_No_Wind FLOAT(15, 5),
						 Lower_Caloirifc_Value_Fuel_Oil FLOAT(15, 5),
                         Normalised_Energy_Consumption FLOAT(15, 5),
						 Density_Fuel_Oil_15C FLOAT(15, 5),
						 Density_Change_Rate_Per_C FLOAT(15, 5),
                         
                         Expected_Speed_Through_Water FLOAT(15, 5),
                         Speed_Loss FLOAT(15, 5),
                         Transverse_Projected_Area_Current FLOAT(15, 5),
                         Wind_Resistance_Correction FLOAT(15, 5),
                         Corrected_Power DOUBLE(20, 3),
                         Filter_SpeedPower_Disp_Trim BOOLEAN,
                         Filter_SpeedPower_Trim BOOLEAN,
                         Filter_SpeedPower_Disp BOOLEAN,
                         Filter_SpeedPower_Below BOOLEAN,
                         NearestDisplacement DOUBLE(20, 10),
                         NearestTrim FLOAT(15, 5),
                         Trim FLOAT(15, 5),
                         Chauvenet_Criteria BOOLEAN,
                         Validated BOOLEAN,
                         Displacement_Correction_Needed BOOLEAN,
                         Filter_All BOOLEAN DEFAULT FALSE,
                         Filter_SFOC_Out_Range BOOLEAN DEFAULT FALSE,
                         Filter_Reference_Seawater_Temp BOOLEAN DEFAULT FALSE,
                         Filter_Reference_Wind_Speed BOOLEAN DEFAULT FALSE,
                         Filter_Reference_Water_Depth BOOLEAN DEFAULT FALSE,
                         Filter_Reference_Rudder_Angle BOOLEAN DEFAULT FALSE */
						 ) ENGINE = MYISAM;
						 
END;