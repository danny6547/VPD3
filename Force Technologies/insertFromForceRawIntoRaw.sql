/* For a given vessel, insert data from Force Database table RawData into current
 Database table RawData, after some modification. */

DROP PROCEDURE IF EXISTS insertFromForceRawIntoRaw;

delimiter //

CREATE PROCEDURE insertFromForceRawIntoRaw(imo INT)

BEGIN

CALL createTempForceRaw(imo);
/* CALL updateFromBunkerNote(imo); */

INSERT INTO rawdata (IMO_Vessel_Number,
							Latitude,
							Longitude,
							Shaft_Power,
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
                             Delivered_Power,
                             Displacement
                             )
SELECT IMO_Vessel_Number,
							Latitude,
							Longitude,
							 Shaft_Power,
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
                             Delivered_Power,
                             Displacement
							 FROM tempForceRaw
								ON DUPLICATE KEY UPDATE 
									IMO_Vessel_Number = VALUES(IMO_Vessel_Number),
									Latitude = VALUES(Latitude),
									Longitude = VALUES(Longitude),
                                    Shaft_Power = VALUES(Shaft_Power),
                                    Water_Depth = VALUES(Water_Depth),
                                    DateTime_UTC = VALUES(DateTime_UTC),
                                    Relative_Wind_Speed = VALUES(Relative_Wind_Speed),
                                    Relative_Wind_Direction = VALUES(Relative_Wind_Direction),
                                    Speed_Over_Ground = VALUES(Speed_Over_Ground),
                                    Speed_Through_Water = VALUES(Speed_Through_Water),
                                    Shaft_Revolutions = VALUES(Shaft_Revolutions),
                                    Static_Draught_Fore = VALUES(Static_Draught_Fore),
                                    Static_Draught_Aft = VALUES(Static_Draught_Aft),
                                    Seawater_Temperature = VALUES(Seawater_Temperature),
                                    Air_Temperature = VALUES(Air_Temperature),
                                    Air_Pressure = VALUES(Air_Pressure),
                                    Mass_Consumed_Fuel_Oil = VALUES(Mass_Consumed_Fuel_Oil),
                                    Delivered_Power = VALUES(Delivered_Power),
                                    Displacement = VALUES(Displacement)
									;
END;