/* For a given vessel, insert data from Force Database table RawData into current
 Database table RawData, after some modification. */

DROP PROCEDURE IF EXISTS insertFromForceSeaReportsIntoRaw;

delimiter //

CREATE PROCEDURE insertFromForceSeaReportsIntoRaw(imo INT)

BEGIN

CALL createTempForceRaw_SeaReports(imo);
/* CALL updateFromBunkerNote(imo); */

INSERT INTO rawdata (IMO_Vessel_Number,
							DateTime_UTC,
                            Latitude,
                            Longitude,
							Shaft_Power,
							Water_Depth, 
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
                             Ship_Heading,
                             Shaft_Torque
                             )
SELECT IMO_Vessel_Number,
							 DateTime_UTC,
                             Latitude,
                             Longitude,
							 Shaft_Power,
							 Water_Depth,
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
                             Ship_Heading,
                             Shaft_Torque
							 FROM tempForceRaw_SR
								ON DUPLICATE KEY UPDATE 
									IMO_Vessel_Number = VALUES(IMO_Vessel_Number),
                                    DateTime_UTC = VALUES(DateTime_UTC),
									Latitude = VALUES(Latitude),
                                    Longitude = VALUES(Longitude),
                                    Shaft_Power = VALUES(Shaft_Power),
                                    Water_Depth = VALUES(Water_Depth),
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
                                    Ship_Heading = VALUES(Ship_Heading),
                                    Shaft_Torque = VALUES(Shaft_Torque)
									;
END;