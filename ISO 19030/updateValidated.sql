DROP PROCEDURE IF EXISTS updateValidated;

delimiter //

CREATE PROCEDURE updateValidated()

BEGIN
	
SET @startTime := (SELECT TO_SECONDS(MIN(DateTime_UTC)) FROM tempRawISO);

UPDATE tempRawISO t7
JOIN
(SELECT t6.id, t6.DateTime_UTC,
			Std_Shaft_Revolutions,
			Std_Speed_Through_Water,
			Std_Speed_Over_Ground,
            @lasth := IFNULL(InvalidR, @lasth) AS InvalidR,
			@lasti := IFNULL(Std_Shaft_Revolutions > 3, @lasti) AS InvalidRPM,
			@lastj := IFNULL(Std_Speed_Through_Water > 0.5, @lastj) AS InvalidSTW,
			@lastk := IFNULL(Std_Speed_Over_Ground > 0.5, @lastk) AS InvalidSOG
	FROM tempRawISO t6
	LEFT JOIN
	(SELECT id, DateTime_UTC, 
			SQRT(AVG(POWER(Delta_Rudder_Angle, 2))) AS Std_Rudder_Angle,
            Delta_Rudder_Angle,
			Std_Shaft_Revolutions,
			Std_Speed_Through_Water,
			Std_Speed_Over_Ground,
            @lasth := IFNULL(SQRT(AVG(POWER(Delta_Rudder_Angle, 2))) > 1, @lasth) AS InvalidR,
			@lasti := IFNULL(Std_Shaft_Revolutions > 3, @lasti) AS InvalidRPM,
			@lastj := IFNULL(Std_Speed_Through_Water > 0.5, @lastj) AS InvalidSTW,
			@lastk := IFNULL(Std_Speed_Over_Ground > 0.5, @lastk) AS InvalidSOG
            FROM
		(SELECT
			t2.id, t2.DateTime_UTC,
			CASE mod(ABS(t2.Rudder_Angle - atan2r), 360) > 180
				WHEN TRUE THEN 360 - mod(ABS(t2.Rudder_Angle - atan2r), 360)
				WHEN FALSE THEN mod(ABS(t2.Rudder_Angle - atan2r), 360)
			END AS Delta_Rudder_Angle,
			Std_Shaft_Revolutions,
			Std_Speed_Through_Water,
			Std_Speed_Over_Ground
		FROM
		(SELECT t1.id, t1.DateTime_UTC,
					@lasta := IFNULL(Sinr, @lasta) AS Sinr,
					@lastb := IFNULL(Cosr, @lastb) AS Cosr,
					@lastc := IFNULL(atan2r, @lastc) AS atan2r,
					@lastd := IFNULL(modCon, @lastd) AS modCon,
					@laste := IFNULL(Std_Shaft_Revolutions, @laste)   AS Std_Shaft_Revolutions,
					@lastf := IFNULL(Std_Speed_Through_Water, @lastf) AS Std_Speed_Through_Water,
					@lastg := IFNULL(Std_Speed_Over_Ground, @lastg)   AS Std_Speed_Over_Ground,
					t1.Rudder_Angle, ri
				FROM
					(SELECT id, DateTime_UTC,
						 AVG(SIN(Rudder_Angle)) AS Sinr,
						 AVG(COS(Rudder_Angle)) AS Cosr,
						 ATAN2(AVG(SIN(Rudder_Angle)), AVG(COS(Rudder_Angle))) AS atan2r,
						 Rudder_Angle,
						 ABS(Rudder_Angle - ATAN2(AVG(SIN(Rudder_Angle)), AVG(COS(Rudder_Angle)))) AS absdiff,
						 mod(ABS(Rudder_Angle - ATAN2(AVG(SIN(Rudder_Angle)), AVG(COS(Rudder_Angle)))), 360) AS ri,
						 mod(ABS(Rudder_Angle - ATAN2(AVG(SIN(Rudder_Angle)), AVG(COS(Rudder_Angle)))), 360) > 180 AS modCon,
						 STD(Shaft_Revolutions)   AS Std_Shaft_Revolutions,
						 STD(Speed_Through_Water) AS Std_Speed_Through_Water,
						 STD(Speed_Over_Ground)   AS Std_Speed_Over_Ground
					FROM tempRawISO
						GROUP BY FLOOR((TO_SECONDS(DateTime_UTC) - @startTime)/(600))) t0
					RIGHT JOIN tempRawISO t1
						ON t0.id = t1.id
							CROSS JOIN (SELECT @lasta := 0) AS var_a
							CROSS JOIN (SELECT @lastb := 0) AS var_b
							CROSS JOIN (SELECT @lastc := 0) AS var_c
							CROSS JOIN (SELECT @lastd := 0) AS var_d
							CROSS JOIN (SELECT @laste := 0) AS var_e
							CROSS JOIN (SELECT @lastf := 0) AS var_f
							CROSS JOIN (SELECT @lastg := 0) AS var_g) t2) t3
							GROUP BY FLOOR((TO_SECONDS(DateTime_UTC) - @startTime)/(600))) t5
								ON t5.id = t6.id
								CROSS JOIN (SELECT @lasth := 0) AS var_h
								CROSS JOIN (SELECT @lasti := 0) AS var_i
								CROSS JOIN (SELECT @lastj := 0) AS var_j
								CROSS JOIN (SELECT @lastk := 0) AS var_k) t8
                                ON t7.id = t8.id
									SET t7.Validated = NOT InvalidRPM AND
														NOT InvalidSTW AND
														NOT InvalidSOG AND
														NOT InvalidR
																	;

/* Mark analysis as Validated */
SET @timeStep := (SELECT (SELECT to_seconds(DateTime_UTC) FROM tempRawISO WHERE Speed_Over_Ground IS NOT NULL LIMIT 1, 1) - 
	(SELECT to_seconds(DateTime_UTC) FROM tempRawISO WHERE Speed_Over_Ground IS NOT NULL LIMIT 0, 1) );
IF @timeStep < 600 THEN
	SET @Validated := TRUE;
ELSE
	SET @Validated := FALSE;
    UPDATE tempRawISO SET Validated = FALSE;
END IF;

CALL IMOStartEnd(@imo, @startd, @endd);
INSERT INTO StandardCompliance (IMO_Vessel_Number, StartDate, EndDate, Validated)
VALUES (@imo, @startd, @endd, @Validated) ON DUPLICATE KEY UPDATE Validated = VALUES(Validated);


/* UPDATE tempRawISO t3
    INNER JOIN
		(SELECT t2.id, 
			@lasta := IFNULL(Std_Shaft_Revolutions, @lasta) AS Std_Shaft_Revolutions,
			@lastb := IFNULL(Std_Speed_Through_Water, @lastb) AS Std_Speed_Through_Water,
			@lastd := IFNULL(Std_Speed_Over_Ground, @lastd) AS Std_Speed_Over_Ground,
			@lastf := IFNULL(SQRT(AVG(POWER(Delta_Rudder_Angle, 2))), @lastf) AS Std_Rudder_Angle
			FROM
				(SELECT t1.id, DateTime_UTC, Std_Shaft_Revolutions, Std_Speed_Through_Water, Std_Speed_Over_Ground, Avg_Rudder_Angle, Std_Rudder_Angle, Delta_Rudder_Angle
				FROM
					(SELECT id, DateTime_UTC,
						STD(Shaft_Revolutions) AS    Std_Shaft_Revolutions,
						STD(Speed_Through_Water) AS  Std_Speed_Through_Water,
						STD(Speed_Over_Ground) AS    Std_Speed_Over_Ground,
						ATAN2(AVG(SIN(Rudder_Angle)), AVG(COS(Rudder_Angle))) AS Avg_Rudder_Angle,
						STD(Rudder_Angle) AS         Std_Rudder_Angle
							FROM tempRawISO
								GROUP BY FLOOR((TO_SECONDS(DateTime_UTC) - @startTime)/(600))) t1
					JOIN
						(SELECT id,
							CASE mod(ABS(Rudder_Angle - ATAN2(AVG(SIN(Rudder_Angle)), AVG(COS(Rudder_Angle)))), 360) > 180
								WHEN TRUE THEN 360 - mod(ABS(Rudder_Angle - ATAN2(AVG(SIN(Rudder_Angle)), AVG(COS(Rudder_Angle)))), 360)
								WHEN FALSE THEN mod(ABS(Rudder_Angle - ATAN2(AVG(SIN(Rudder_Angle)), AVG(COS(Rudder_Angle)))), 360)
							END AS Delta_Rudder_Angle
							FROM tempRawISO
								GROUP BY FLOOR((TO_SECONDS(DateTime_UTC) - @startTime)/(600))) t0
					ON t1.id = t0.id)
						RIGHT JOIN tempRawISO t2
						ON t1.id = t2.id
						CROSS JOIN (SELECT @lasta := 0) AS var_a
						CROSS JOIN (SELECT @lastb := 0) AS var_b
						CROSS JOIN (SELECT @lastd := 0) AS var_d
						CROSS JOIN (SELECT @lastf := 0) AS var_f) t4
						ON t3.id = t4.id
							SET t3.Validated = Std_Shaft_Revolutions <= 3 AND
											Std_Speed_Through_Water <= 0.5 AND
											Std_Speed_Over_Ground <= 0.5 AND
											Std_Rudder_Angle <= 1
																; */
END;