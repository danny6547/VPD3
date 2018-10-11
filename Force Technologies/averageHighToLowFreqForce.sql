/* Combine autologged data with noon-data columns, by averaging the higher-frequency data over the corresponding period of nin temp Force raw table to match those of table RawData, based on the RawData definitions given in the ISO 19030 standard */

DROP PROCEDURE IF EXISTS averageHighToLowFreqForce;

delimiter //

CREATE PROCEDURE averageHighToLowFreqForce(imo INT)
BEGIN
	
	DELETE FROM `force`.rawdata WHERE IMO_Vessel_Number = @imo;
    
    INSERT INTO `force`.rawdata (DateTime_UTC, IMO_Vessel_Number, Mass_Consumed_Fuel_Oil, Latitude, Longitude, Speed_Over_Ground, Speed_Through_Water, 
		Relative_Wind_Speed, Ship_Heading, Relative_Wind_Direction, Air_Temperature, Air_Pressure, Rudder_Angle, Water_Depth, 
        Shaft_Power, Shaft_Revolutions, Shaft_Torque, Static_Draught_Aft, Static_Draught_Fore, Delivered_Power, Displacement)
	SELECT ADDTIME(report_start_utc, SEC_TO_TIME(TIME_TO_SEC(timediff(report_end_utc, report_start_utc))/2)) as 'DateTime_UTC', 
		IMO_Vessel_Number,
		main_engine_hfo_consumption AS 'Mass_Consumed_Fuel_Oil', 
		AVG(Latitude) AS 'Latitude',
		AVG(Longitude) AS 'Longitude',
		AVG(Speed_Over_Ground) AS 'Speed_Over_Ground',
		AVG(Speed_Through_Water) AS 'Speed_Through_Water',
		AVG(Relative_Wind_Speed) AS 'Relative_Wind_Speed',
		AVG(Ship_Heading) AS 'Ship_Heading',
		AVG(Relative_Wind_Direction) AS 'Relative_Wind_Direction',
		AVG(Air_Temperature) AS 'Air_Temperature',
		AVG(Air_Pressure) AS 'Air_Pressure',
		AVG(Rudder_Angle) AS 'Rudder_Angle',
		AVG(Water_Depth) AS 'Water_Depth',
		AVG(Shaft_Power) AS 'Shaft_Power',
		AVG(Shaft_Revolutions) AS 'Shaft_Revolutions',
		AVG(Shaft_Torque) AS 'Shaft_Torque',
		AVG(Static_Draught_Aft) AS 'Static_Draught_Aft',
		AVG(Static_Draught_Fore) AS 'Static_Draught_Fore',
		AVG(Delivered_Power) AS 'Delivered_Power',
		AVG(Displacement) AS 'Displacement'
		FROM `force`.tempforceraw
			WHERE report_end_utc AND report_start_utc IS NOT NULL
				GROUP BY ADDTIME(report_start_utc, SEC_TO_TIME(TIME_TO_SEC(timediff(report_end_utc, report_start_utc))/2))
	ON DUPLICATE KEY UPDATE
		DateTime_UTC = VALUES(DateTime_UTC),
		IMO_Vessel_Number = VALUES(IMO_Vessel_Number),
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
		Displacement = VALUES(Displacement)
			;
END;