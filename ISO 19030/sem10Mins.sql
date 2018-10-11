/* Calculate 10 minute standard error of mean */

DROP TABLE IF EXISTS `inservice`.sem10Mins;
CREATE TABLE `inservice`.sem10Mins LIKE mu10Mins;

SET @startTime := (SELECT MIN(DateTime_UTC) from `inservice`.tempRawISO);
SET @firstgroup := (SELECT FLOOR((TO_SECONDS(MIN(DateTime_UTC)) - TO_SECONDS(@startTime))/(600)) FROM `inservice`.tempRawISO);

INSERT INTO `inservice`.sem10Mins (
						Rudder_Angle,
						Relative_Wind_Direction,
						Ship_Heading, 
                        Speed_Through_Water, 
						Delivered_Power, 
						Relative_Wind_Speed, 
						Speed_Over_Ground, 
						Shaft_Revolutions, 
						Water_Depth, 
                        Air_Temperature,
						Seawater_Temperature)
            (SELECT
                 SQRT(AVG(POWER(Rudder_Angle, 2))),
                 SQRT(AVG(POWER(Relative_Wind_Direction, 2))),
                 SQRT(AVG(POWER(Ship_Heading, 2))),
                 SQRT(AVG(POWER(Speed_Through_Water, 2))),
                 SQRT(AVG(POWER(Delivered_Power, 2))),
                 SQRT(AVG(POWER(Relative_Wind_Speed, 2))),
                 SQRT(AVG(POWER(Speed_Over_Ground, 2))),
                 SQRT(AVG(POWER(Shaft_Revolutions, 2))),
                 SQRT(AVG(POWER(Water_Depth, 2))),
                 SQRT(AVG(POWER(Air_Temperature, 2))),
                 SQRT(AVG(POWER(Seawater_Temperature, 2)))
			FROM `inservice`.tempRawISO
				GROUP BY FLOOR((TO_SECONDS(DateTime_UTC) - TO_SECONDS(@startTime))/(600)));