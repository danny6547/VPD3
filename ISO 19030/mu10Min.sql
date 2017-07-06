/* Calculate 10 minute averages */

INSERT INTO mu10Mins (
						DateTime_UTC,
						Rudder_Angle,
						Relative_Wind_Direction,
						Ship_Heading, 
                        Speed_Through_Water, 
						Delivered_Power, 
						Relative_Wind_Speed, 
						Speed_Over_Ground, 
						Shaft_Revolutions, 
						Water_Depth, 
						Seawater_Temperature,
                        Air_Temperature,
                        N)
            (SELECT 
				 DateTime_UTC,
				 ATAN2(AVG(SIN(Rudder_Angle)), AVG(COS(Rudder_Angle))) AS Rudder_Angle,
				 ATAN2(AVG(SIN(Relative_Wind_Direction)), AVG(COS(Relative_Wind_Direction))) AS Relative_Wind_Direction,
                 ATAN2(AVG(SIN(Ship_Heading)), AVG(COS(Ship_Heading))) AS Ship_Heading,
                 AVG(Speed_Through_Water) AS Speed_Through_Water,
                 AVG(Delivered_Power) AS Delivered_Power,
                 AVG(Relative_Wind_Speed) AS Relative_Wind_Speed,
                 AVG(Speed_Over_Ground) AS Speed_Over_Ground,
                 AVG(Shaft_Revolutions) AS Shaft_Revolutions,
                 AVG(Water_Depth) AS Water_Depth,
                 AVG(Seawater_Temperature) AS Seawater_Temperature,
                 AVG(Air_Temperature) AS Air_Temperature,
                 COUNT(*) AS N
			FROM tempRawISO
				GROUP BY FLOOR((TO_SECONDS(DateTime_UTC) - TO_SECONDS(@startTime))/(600)));