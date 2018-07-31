/* Insert data from tempMarorkaRaw into RawData for a given vessel, after some 
modification. */

DROP PROCEDURE IF EXISTS insertFromMarorkaRawIntoRaw;

delimiter //

CREATE PROCEDURE insertFromMarorkaRawIntoRaw()

BEGIN

/* CALL createTempMarorkaRaw(); */
/* CALL updateFromBunkerNote(imo); */

INSERT INTO rawdata (Vessel_Id,
							Water_Depth, 
							Timestamp,
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
                             Shaft_Power,
                             Ship_Heading,
                             Shaft_Torque,
                             Rudder_Angle,
                             Seawater_Temperature
                             /* Displacement */
                             )
SELECT (SELECT Vessel_Id FROM Vessel WHERE IMO = IMONo),
							 `Sea depth [m]`, 
							 DateTime_UTC,
							 `Relative wind speed [m/s]`,
							 `Relative wind direction`,
							 `GPS speed [knots]` * 0.514444444,
                             `Log speed [knots]` * 0.514444444,
							 `Shaft rpm [rpm]`,
							 `Draft fore [m]`,
							 `Draft aft [m]`,
							 /* Seawater_Temperature, */
							 /* Air_Temperature, */
							 /* Air_Pressure, */
							 `ME consumed [MT]`,
                             `Shaft power [kW]`,
                             `COG heading`,
                             `Shaft Torque [kNm]`,
                             `Rudder Angle`,
                             `Seawater temperature`
                             /* Draft_Displacement_Actual */
							 FROM tempMarorkaRaw
								ON DUPLICATE KEY UPDATE 
									Vessel_Id = VALUES(Vessel_Id),
                                    Water_Depth = VALUES(Water_Depth),
                                    Timestamp = VALUES(Timestamp),
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
                                    Shaft_Power = VALUES(Shaft_Power),
									 Ship_Heading = VALUES(Ship_Heading),
									 Shaft_Torque = VALUES(Shaft_Torque),
									 Rudder_Angle = VALUES(Rudder_Angle),
									 Seawater_Temperature = VALUES(Seawater_Temperature)
                                    /* Displacement = VALUES(Displacement) */
									;
END;