/* Create temporary table for ISO 19030 analysis with */

CREATE TABLE rawdata (id INT PRIMARY KEY AUTO_INCREMENT,
						 DateTime_UTC DATETIME(3),
                         IMO_Vessel_Number INT(7),
						 Relative_Wind_Speed DOUBLE(10, 5),
						 Relative_Wind_Direction DOUBLE(10, 5),
						 Speed_Over_Ground DOUBLE(10, 5),
						 Ship_Heading DOUBLE(10, 5),
						 Shaft_Revolutions DOUBLE(10, 5),
						 Static_Draught_Fore DOUBLE(10, 5),
						 Static_Draught_Aft DOUBLE(10, 5),
						 Water_Depth DOUBLE(10, 5),
						 Rudder_Angle DOUBLE(10, 5),
						 Seawater_Temperature DOUBLE(10, 5),
						 Air_Temperature DOUBLE(10, 8),
						 Air_Pressure DOUBLE(10, 6),
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
                         Wind_Resistance_Relative DOUBLE(10, 5),
                         Air_Resistance_No_Wind DOUBLE(10, 5),
                         Expected_Speed_Through_Water DOUBLE(10, 5),
                         Displacement DOUBLE(20, 10),
                         Speed_Loss DOUBLE(10, 5),
                         Transverse_Projected_Area_Current DOUBLE(10, 5),
                         Wind_Resistance_Correction DOUBLE(10, 5),
                         Corrected_Power DOUBLE(20, 3),
                         FilterSPDispTrim BOOLEAN,
                         FilterSPTrim BOOLEAN,
                         FilterSPDisp BOOLEAN,
                         FilterSPBelow BOOLEAN,
                         NearestDisplacement DOUBLE(20, 10),
                         NearestTrim DOUBLE(10, 5),
                         Trim DOUBLE(10, 5),
                         Chauvenet_Criteria BOOLEAN
						 ) ENGINE = MYISAM;