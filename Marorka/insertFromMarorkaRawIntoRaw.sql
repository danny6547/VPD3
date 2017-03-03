/* Insert data from tempMarorkaRaw into RawData for a given vessel, after some 
modification. */

USE hull_performance;

DROP PROCEDURE IF EXISTS insertFromMarorkaRawIntoRaw;

delimiter //

CREATE PROCEDURE insertFromMarorkaRawIntoRaw()

BEGIN

/* CALL createTempMarorkaRaw(); */
/* CALL updateFromBunkerNote(imo); */

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
							 /* Seawater_Temperature, */
							 /* Air_Temperature, */
							 /* Air_Pressure, */
							 Mass_Consumed_Fuel_Oil,
                             Shaft_Power
                             /* Displacement */
                             )
SELECT IMONo, 
							 `Sea depth [m]`, 
							 DateTime_UTC,
							 `Relative wind speed [m/s]`,
							 `Relative wind direction [Â°]`,
							 `GPS speed [knots]`,
                             `Log speed [knots]`,
							 `Shaft rpm [rpm]`,
							 `Draft fore [m]`,
							 `Draft aft [m]`,
							 /* Seawater_Temperature, */
							 /* Air_Temperature, */
							 /* Air_Pressure, */
							 `ME consumed [MT]`,
                             `Shaft power [kW]`
                             /* Draft_Displacement_Actual */
							 FROM tempMarorkaRaw
								ON DUPLICATE KEY UPDATE 
									IMO_Vessel_Number = VALUES(IMO_Vessel_Number),
                                    Water_Depth = VALUES(Water_Depth),
                                    DateTime_UTC = VALUES(DateTime_UTC),
                                    Relative_Wind_Speed = VALUES(Relative_Wind_Speed),
                                    Relative_Wind_Direction = VALUES(Relative_Wind_Direction),
                                    Speed_Over_Ground = VALUES(Speed_Over_Ground),
                                    Speed_Through_Water = VALUES(Speed_Through_Water),
                                    Shaft_Revolutions = VALUES(Shaft_Revolutions),
                                    Static_Draught_Fore = VALUES(Static_Draught_Fore),
                                    Static_Draught_Aft = VALUES(Static_Draught_Aft),
                                    /* Seawater_Temperature = VALUES(Seawater_Temperature), */
                                    /* Air_Temperature = VALUES(Air_Temperature), */
                                    /* Air_Pressure = VALUES(Air_Pressure), */
                                    Mass_Consumed_Fuel_Oil = VALUES(Mass_Consumed_Fuel_Oil),
                                    Shaft_Power = VALUES(Shaft_Power)
                                    /* Displacement = VALUES(Displacement) */
									;
END;