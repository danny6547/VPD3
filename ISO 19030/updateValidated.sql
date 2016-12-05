DROP PROCEDURE IF EXISTS updateValidated;

delimiter //

CREATE PROCEDURE updateValidated()

BEGIN
	
SET @startTime := (SELECT TO_SECONDS(MIN(DateTime_UTC)) FROM tempRawISO);

UPDATE tempRawISO t3
    INNER JOIN
		(SELECT t2.id, 
			@lasta := IFNULL(Std_Shaft_Revolutions, @lasta) AS Std_Shaft_Revolutions,
			@lastb := IFNULL(Std_Speed_Through_Water, @lastb) AS Std_Speed_Through_Water,
			@lastd := IFNULL(Std_Speed_Over_Ground, @lastd) AS Std_Speed_Over_Ground,
			@lastf := IFNULL(Std_Rudder_Angle, @lastf) AS Std_Rudder_Angle
					FROM
						(SELECT id, DateTime_UTC,
							STD(Shaft_Revolutions) AS    Std_Shaft_Revolutions,                     
							STD(Speed_Through_Water) AS  Std_Speed_Through_Water,                        
							STD(Speed_Over_Ground) AS    Std_Speed_Over_Ground,                 
							STD(Rudder_Angle) AS         Std_Rudder_Angle       
								FROM tempRawISO
									GROUP BY FLOOR((TO_SECONDS(DateTime_UTC) - @startTime)/(600))) t1
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
											;
END;