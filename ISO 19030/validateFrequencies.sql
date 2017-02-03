/* Check whether data shows that measurement frequencies are sufficient for 
ISO19030-2 standard.
Procedure must be called prior to data being averaged over higher-
frequencies or repeated over lower-frequencies. */

DROP PROCEDURE IF EXISTS validateFrequencies;

delimiter //

CREATE PROCEDURE validateFrequencies(OUT valSTWt BOOLEAN,
									 OUT valDelt BOOLEAN,
									 OUT valShRt BOOLEAN,
									 OUT valRWSt BOOLEAN,
									 OUT valRWDt BOOLEAN,
									 OUT valSOGt BOOLEAN,
									 OUT valHeat BOOLEAN,
									 OUT valRudt BOOLEAN,
									 OUT valWDpt BOOLEAN,
									 OUT valTmpt BOOLEAN)

BEGIN

/* DECLARATIONS */
DECLARE minSTWt INT;
DECLARE minDelt INT;
DECLARE minShRt INT;
DECLARE minRWSt INT;
DECLARE minRWDt INT;
DECLARE minSOGt INT;
DECLARE minHeat INT;
DECLARE minRudt INT;
DECLARE minWDpt INT;
DECLARE minTmpt INT;

/* 
DECLARE valSTWt BOOLEAN;
DECLARE valDelt BOOLEAN;
DECLARE valShRt BOOLEAN;
DECLARE valRWSt BOOLEAN;
DECLARE valRWDt BOOLEAN;
DECLARE valSOGt BOOLEAN;
DECLARE valHeat BOOLEAN;
DECLARE valRudt BOOLEAN;
DECLARE valWDpt BOOLEAN;
DECLARE valTmpt BOOLEAN;
*/

/* Check for speed through water */
SET minSTWt := 
	(SELECT MIN(TO_SECONDS(f2.DateTime_UTC) - TO_SECONDS(f.DateTime_UTC))
		FROM (SELECT (@id3 := @id3 + 1) AS id3, id, DateTime_UTC
			FROM (SELECT id, DateTime_UTC, Speed_Through_Water FROM tempRawISO WHERE Speed_Through_Water IS NOT NULL) t1
				CROSS JOIN (SELECT @id3 := 0) AS dummy) f
					LEFT OUTER JOIN
									(SELECT (@id4 := @id4 + 1) AS id4, id, DateTime_UTC
										FROM (SELECT id, DateTime_UTC, Speed_Through_Water FROM tempRawISO WHERE Speed_Through_Water IS NOT NULL) t1
											CROSS JOIN (SELECT @id4 := 0) AS dummy) f2
						ON  f2.id4 = (f.id3 +1));

/* Check for Delivered Power */
SET minDelt :=
	(SELECT MIN(TO_SECONDS(f2.DateTime_UTC) - TO_SECONDS(f.DateTime_UTC))
		FROM (SELECT (@id3 := @id3 + 1) AS id3, id, DateTime_UTC
			FROM (SELECT id, DateTime_UTC, Delivered_Power FROM tempRawISO WHERE Delivered_Power IS NOT NULL) t1
				CROSS JOIN (SELECT @id3 := 0) AS dummy) f
					LEFT OUTER JOIN
									(SELECT (@id4 := @id4 + 1) AS id4, id, DateTime_UTC
										FROM (SELECT id, DateTime_UTC, Delivered_Power FROM tempRawISO WHERE Delivered_Power IS NOT NULL) t1
											CROSS JOIN (SELECT @id4 := 0) AS dummy) f2
						ON  f2.id4 = (f.id3 +1));

/* Check for Shaft Revolutions */
SET minShRt :=
	(SELECT MIN(TO_SECONDS(f2.DateTime_UTC) - TO_SECONDS(f.DateTime_UTC))
		FROM (SELECT (@id3 := @id3 + 1) AS id3, id, DateTime_UTC
			FROM (SELECT id, DateTime_UTC, Shaft_Revolutions FROM tempRawISO WHERE Shaft_Revolutions IS NOT NULL) t1
				CROSS JOIN (SELECT @id3 := 0) AS dummy) f
					LEFT OUTER JOIN
									(SELECT (@id4 := @id4 + 1) AS id4, id, DateTime_UTC
										FROM (SELECT id, DateTime_UTC, Shaft_Revolutions FROM tempRawISO WHERE Shaft_Revolutions IS NOT NULL) t1
											CROSS JOIN (SELECT @id4 := 0) AS dummy) f2
						ON  f2.id4 = (f.id3 +1));

/* Check for Relative Wind Speed */
SET minRWSt :=
	(SELECT MIN(TO_SECONDS(f2.DateTime_UTC) - TO_SECONDS(f.DateTime_UTC))
		FROM (SELECT (@id3 := @id3 + 1) AS id3, id, DateTime_UTC
			FROM (SELECT id, DateTime_UTC, Relative_Wind_Speed FROM tempRawISO WHERE Relative_Wind_Speed IS NOT NULL) t1
				CROSS JOIN (SELECT @id3 := 0) AS dummy) f
					LEFT OUTER JOIN
									(SELECT (@id4 := @id4 + 1) AS id4, id, DateTime_UTC
										FROM (SELECT id, DateTime_UTC, Relative_Wind_Speed FROM tempRawISO WHERE Relative_Wind_Speed IS NOT NULL) t1
											CROSS JOIN (SELECT @id4 := 0) AS dummy) f2
						ON  f2.id4 = (f.id3 +1));
                        
/* Check for Relative Wind Direction */
SET minRWDt :=
	(SELECT MIN(TO_SECONDS(f2.DateTime_UTC) - TO_SECONDS(f.DateTime_UTC))
		FROM (SELECT (@id3 := @id3 + 1) AS id3, id, DateTime_UTC
			FROM (SELECT id, DateTime_UTC, Relative_Wind_Direction FROM tempRawISO WHERE Relative_Wind_Direction IS NOT NULL) t1
				CROSS JOIN (SELECT @id3 := 0) AS dummy) f
					LEFT OUTER JOIN
									(SELECT (@id4 := @id4 + 1) AS id4, id, DateTime_UTC
										FROM (SELECT id, DateTime_UTC, Relative_Wind_Direction FROM tempRawISO WHERE Relative_Wind_Direction IS NOT NULL) t1
											CROSS JOIN (SELECT @id4 := 0) AS dummy) f2
						ON  f2.id4 = (f.id3 +1));
                        
/* Check for Speed Over Ground */
SET minSOGt :=
	(SELECT MIN(TO_SECONDS(f2.DateTime_UTC) - TO_SECONDS(f.DateTime_UTC))
		FROM (SELECT (@id3 := @id3 + 1) AS id3, id, DateTime_UTC
			FROM (SELECT id, DateTime_UTC, Speed_Over_Ground FROM tempRawISO WHERE Speed_Over_Ground IS NOT NULL) t1
				CROSS JOIN (SELECT @id3 := 0) AS dummy) f
					LEFT OUTER JOIN
									(SELECT (@id4 := @id4 + 1) AS id4, id, DateTime_UTC
										FROM (SELECT id, DateTime_UTC, Speed_Over_Ground FROM tempRawISO WHERE Speed_Over_Ground IS NOT NULL) t1
											CROSS JOIN (SELECT @id4 := 0) AS dummy) f2
						ON  f2.id4 = (f.id3 +1));
                        
/* Check for Ship Heading */
SET minHeat :=
	(SELECT MIN(TO_SECONDS(f2.DateTime_UTC) - TO_SECONDS(f.DateTime_UTC))
		FROM (SELECT (@id3 := @id3 + 1) AS id3, id, DateTime_UTC
			FROM (SELECT id, DateTime_UTC, Ship_Heading FROM tempRawISO WHERE Ship_Heading IS NOT NULL) t1
				CROSS JOIN (SELECT @id3 := 0) AS dummy) f
					LEFT OUTER JOIN
									(SELECT (@id4 := @id4 + 1) AS id4, id, DateTime_UTC
										FROM (SELECT id, DateTime_UTC, Ship_Heading FROM tempRawISO WHERE Ship_Heading IS NOT NULL) t1
											CROSS JOIN (SELECT @id4 := 0) AS dummy) f2
						ON  f2.id4 = (f.id3 +1));
                        
/* Check for Rudder Angle */
SET minRudt :=
	(SELECT MIN(TO_SECONDS(f2.DateTime_UTC) - TO_SECONDS(f.DateTime_UTC))
		FROM (SELECT (@id3 := @id3 + 1) AS id3, id, DateTime_UTC
			FROM (SELECT id, DateTime_UTC, Rudder_Angle FROM tempRawISO WHERE Rudder_Angle IS NOT NULL) t1
				CROSS JOIN (SELECT @id3 := 0) AS dummy) f
					LEFT OUTER JOIN
									(SELECT (@id4 := @id4 + 1) AS id4, id, DateTime_UTC
										FROM (SELECT id, DateTime_UTC, Rudder_Angle FROM tempRawISO WHERE Rudder_Angle IS NOT NULL) t1
											CROSS JOIN (SELECT @id4 := 0) AS dummy) f2
						ON  f2.id4 = (f.id3 +1));

/* Check for Water Depth */
SET minWDpt :=
	(SELECT MIN(TO_SECONDS(f2.DateTime_UTC) - TO_SECONDS(f.DateTime_UTC))
		FROM (SELECT (@id3 := @id3 + 1) AS id3, id, DateTime_UTC
			FROM (SELECT id, DateTime_UTC, Water_Depth FROM tempRawISO WHERE Water_Depth IS NOT NULL) t1
				CROSS JOIN (SELECT @id3 := 0) AS dummy) f
					LEFT OUTER JOIN
									(SELECT (@id4 := @id4 + 1) AS id4, id, DateTime_UTC
										FROM (SELECT id, DateTime_UTC, Water_Depth FROM tempRawISO WHERE Water_Depth IS NOT NULL) t1
											CROSS JOIN (SELECT @id4 := 0) AS dummy) f2
						ON  f2.id4 = (f.id3 +1));

/* Check for Water Temperature */
SET minTmpt :=
	(SELECT MIN(TO_SECONDS(f2.DateTime_UTC) - TO_SECONDS(f.DateTime_UTC))
		FROM (SELECT (@id3 := @id3 + 1) AS id3, id, DateTime_UTC
			FROM (SELECT id, DateTime_UTC, Seawater_Temperature FROM tempRawISO WHERE Seawater_Temperature IS NOT NULL) t1
				CROSS JOIN (SELECT @id3 := 0) AS dummy) f
					LEFT OUTER JOIN
									(SELECT (@id4 := @id4 + 1) AS id4, id, DateTime_UTC
										FROM (SELECT id, DateTime_UTC, Seawater_Temperature FROM tempRawISO WHERE Seawater_Temperature IS NOT NULL) t1
											CROSS JOIN (SELECT @id4 := 0) AS dummy) f2
						ON  f2.id4 = (f.id3 +1));

/* Compare timesteps to those in standard */
SET valSTWt :=  minSTWt < 15;
SET valDelt :=  minDelt < 15 AND minDelt = minSTWt;
SET valShRt :=  minShRt < 15;
SET valRWSt :=  minRWSt < 15;
SET valRWDt :=  minRWDt < 15;
SET valSOGt :=  minSOGt < 15;
SET valHeat :=  minHeat < 15;
SET valRudt :=  minRudt < 15;
SET valWDpt :=  minWDpt < 15;
SET valTmpt :=  minTmpt < 15;

END;