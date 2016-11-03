/* Removes rows from table tempraw whose values for DateTime and IMO are found together on rows of rawdata */

delimiter //

CREATE PROCEDURE insertWithoutDuplicates()
BEGIN

INSERT INTO rawdata (DateTime_UTC,IMO_Vessel_Number,Relative_Wind_Speed,Relative_Wind_Direction, Speed_Over_Ground, Shaft_Revolutions, Static_Draught_Fore, Static_Draught_Aft, Seawater_Temperature, Air_Temperature, Air_Pressure, Mass_Consumed_Fuel_Oil)
				Select DateTime_UTC,IMO_Vessel_Number,Relative_Wind_Speed,Relative_Wind_Direction, Speed_Over_Ground, Shaft_Revolutions, Static_Draught_Fore, Static_Draught_Aft, Seawater_Temperature, Air_Temperature, Air_Pressure, Mass_Consumed_Fuel_Oil
					FROM tempraw as a
						WHERE NOT EXISTS(Select DateTime_UTC,IMO_Vessel_Number,Relative_Wind_Speed,Relative_Wind_Direction, Speed_Over_Ground, Shaft_Revolutions, Static_Draught_Fore, Static_Draught_Aft, Seawater_Temperature, Air_Temperature, Air_Pressure, Mass_Consumed_Fuel_Oil FROM rawdata as b
							WHERE a.DateTime_UTC = b.DateTime_UTC and a.IMO_Vessel_Number = b.IMO_Vessel_Number );
            
END;