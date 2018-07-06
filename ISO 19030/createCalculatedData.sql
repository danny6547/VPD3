/* Create table for data required by ISO 19030 analysis */



DROP PROCEDURE IF EXISTS createCalculatedData;

delimiter //

CREATE PROCEDURE createCalculatedData()

BEGIN

CREATE TABLE CalculatedData (
						Calculated_Data_Id bigint(19) PRIMARY KEY UNIQUE AUTO_INCREMENT NOT NULL,
						Vessel_Configuration_Id	int(10) NOT NULL,
						Raw_Data_Id	bigint(19) NOT NULL,
						Lower_Caloirifc_Value_Fuel_Oil float(15, 8),
						Normalised_Energy_Consumption float(15, 8),
						Density_Fuel_Oil_15C float(15, 8),
						Density_Change_Rate_Per_C float(15, 8),
						Temp_Fuel_Oil_At_Flow_Meter float(15, 8),
						Wind_Resistance_Relative float(15, 8),
						Air_Resistance_No_Wind float(15, 8),
						Expected_Speed_Through_Water float(15, 8),
						Displacement float(15, 8),
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
						Air_Density float(15, 8),
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
						Speed_Through_Water float(15, 8)
						 ) ENGINE = MYISAM;
						 
END;