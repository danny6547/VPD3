/* Calculate individual errors of data from the 10-minute mean */

SET @startTime := (SELECT MIN(DateTime_UTC) from `inservice`.tempRawISO);
SET @firstgroup := (SELECT FLOOR((TO_SECONDS(MIN(DateTime_UTC)) - TO_SECONDS(@startTime))/(600)) FROM `inservice`.tempRawISO);

INSERT INTO del10Mins (
						Speed_Over_Ground, 
						Relative_Wind_Speed, 
						Shaft_Revolutions, 
						Water_Depth, 
						Seawater_Temperature,
                        Speed_Through_Water, 
						Delivered_Power,
						Air_Temperature,
						Rudder_Angle,
						Relative_Wind_Direction,
						Ship_Heading)
	SELECT
			ABS(t.Speed_Over_Ground - mu.Speed_Over_Ground) AS Speed_Over_Ground,
			ABS(t.Relative_Wind_Speed - mu.Relative_Wind_Speed) AS Relative_Wind_Speed,
			ABS(t.Shaft_Revolutions - mu.Shaft_Revolutions) AS Shaft_Revolutions,
			ABS(t.Water_Depth - mu.Water_Depth) AS Water_Depth,
			ABS(t.Seawater_Temperature - mu.Seawater_Temperature) AS Seawater_Temperature,
			ABS(t.Speed_Through_Water - mu.Speed_Through_Water) AS Speed_Through_Water,
			ABS(t.Delivered_Power - mu.Delivered_Power) AS Delivered_Power,
			ABS(t.Air_Temperature - mu.Air_Temperature) AS Air_Temperature,
			CASE mod(ABS(t.Rudder_Angle - mu.Rudder_Angle), 360) > 180
				WHEN TRUE THEN 360 - mod(ABS(t.Rudder_Angle - mu.Rudder_Angle), 360)
				WHEN FALSE THEN mod(ABS(t.Rudder_Angle - mu.Rudder_Angle), 360)
			END AS Rudder_Angle,
			CASE mod(ABS(t.Relative_Wind_Direction - mu.Relative_Wind_Direction), 360) > 180
				WHEN TRUE THEN 360 - mod(ABS(t.Relative_Wind_Direction - mu.Relative_Wind_Direction), 360)
				WHEN FALSE THEN mod(ABS(t.Relative_Wind_Direction - mu.Relative_Wind_Direction), 360)
			END AS Relative_Wind_Direction,
			CASE mod(ABS(t.Ship_Heading - mu.Ship_Heading), 360) > 180
				WHEN TRUE THEN 360 - mod(ABS(t.Ship_Heading - mu.Ship_Heading), 360)
				WHEN FALSE THEN mod(ABS(t.Ship_Heading - mu.Ship_Heading), 360)
			END AS Ship_Heading
				FROM `inservice`.tempRawISO t
					JOIN `inservice`.mu10Mins mu
						ON mu.id = FLOOR((TO_SECONDS(t.DateTime_UTC) - TO_SECONDS(@startTime))/(600)) - @firstgroup + 1;