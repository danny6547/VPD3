/* Insert raw dnvgl data into raw data for a given vessel, after some manipulation */

DROP PROCEDURE IF EXISTS insertFromDNVGLRawIntoRaw;

delimiter //

CREATE PROCEDURE insertFromDNVGLRawIntoRaw(imo INT)

BEGIN

CALL createTempRaw(imo);
CALL updateFromBunkerNote(imo);

INSERT INTO rawdata (IMO_Vessel_Number,
							Water_Depth, 
							DateTime_UTC,
							Relative_Wind_Speed,
							 Relative_Wind_Direction,
							 Speed_Over_Ground,
                             Speed_Through_Water,
							 Shaft_Revolutions,
							 Static_Draught_Fore,
							 Static_Draught_Aft,
							 Seawater_Temperature,
							 Air_Temperature,
							 Air_Pressure,
							 Mass_Consumed_Fuel_Oil,
                             Shaft_Power,
                             Displacement, 
                             Lower_Caloirifc_Value_Fuel_Oil,
                             Density_Fuel_Oil_15C
                             )
SELECT IMO_Vessel_Number, 
							 Water_Depth, 
							 DateTime_UTC, 
							 Relative_Wind_Speed,
							 Relative_Wind_Direction,
							 Speed_Over_Ground,
                             Speed_Through_Water,
							 Shaft_Revolutions,
							 Static_Draught_Fore,
							 Static_Draught_Aft,
							 Seawater_Temperature,
							 Air_Temperature,
							 Air_Pressure,
							 Mass_Consumed_Fuel_Oil,
                             ME_1_Load,
                             Draft_Displacement_Actual,
                             Lower_Caloirifc_Value_Fuel_Oil,
                             Density_Fuel_Oil_15C
							 FROM tempRaw;
END;