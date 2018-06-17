/* Detect rows where displacement is outside the range of +/-5% of the 
nearest value in the SpeedPower table. */




DROP PROCEDURE IF EXISTS filterSpeedPowerLookup;

delimiter //

CREATE PROCEDURE filterSpeedPowerLookup(vcid INT)
BEGIN
	
    /* 
    /* Declarations */
    /* DECLARE numRows INT;
    SET numRows := (SELECT COUNT(*) FROM tempRawISO);
    
    /* Create temporary table for speed-power data look-up */
	/* DROP TABLE IF EXISTS tempSpeedPowerConditions;
	CREATE TABLE tempSpeedPowerConditions (id INT PRIMARY KEY AUTO_INCREMENT,
									Displacement DOUBLE(20, 10),
									Displacement_Difference_With_Nearest DOUBLE(20, 3),
									Displacement_Nearest DOUBLE(20, 3),
									Displacement_Diff_PC DOUBLE(10, 5),
									Displacement_Condition BOOLEAN,
                                    Trim DOUBLE(10, 8),
                                    Trim_Nearest DOUBLE(10, 8),
									Trim_Condition BOOLEAN,
									Nearest_Neighbour_Condition BOOLEAN);
    
    /* Update trim */
    /* UPDATE tempRawISO SET Trim = Static_Draught_Fore - Static_Draught_Aft;
    
	/* Find nearest displacement value */
    /* INSERT INTO tempSpeedPowerConditions (Displacement, Trim) SELECT Displacement, Trim FROM tempRawISO WHERE Displacement IS NOT NULL;
    CALL log_msg('Max Displacement = ', (SELECT MAX(Displacement) FROM tempSpeedPowerConditions));
    
	DROP TABLE IF EXISTS tempTable1;
	CREATE TABLE tempTable1 (id INT PRIMARY KEY AUTO_INCREMENT, disps DOUBLE(20, 10), lookupDisps DOUBLE(20, 10), `Abs Difference` DOUBLE(20, 10));
	INSERT INTO tempTable1 (disps, lookupDisps, `Abs Difference`)
		(SELECT a.Displacement, b.Displacement, ABS(a.Displacement - b.Displacement) AS 'Abs Difference'
			FROM tempSpeedPowerConditions a
				JOIN speedPowerCoefficients b
					ORDER BY b.Displacement);
    
    CALL log_msg('disps 1 = ', (SELECT disps FROM tempTable1 LIMIT 1));
    CALL log_msg('lookupDisps 1 = ', (SELECT lookupDisps FROM tempTable1 LIMIT 1));
    CALL log_msg('`Abs Difference` 1 = ', (SELECT `Abs Difference` FROM tempTable1 LIMIT 1));
    
    /* UPDATE tempSpeedPowerConditions a
		INNER JOIN tempTable1 b
			ON a.Displacement = b.disps
				SET
                a.Displacement_Nearest = b.disps ORDER BY `Abs Difference` LIMIT numRows;
    /* UPDATE tempSpeedPowerConditions a,  tempTable1 b SET a.Displacement_Nearest = (SELECT b.disps FROM tempTable1 ORDER BY `Abs Difference` LIMIT numRows); */
	/*INSERT INTO tempSpeedPowerConditions (Displacement_Nearest) (SELECT disps FROM tempTable1 ORDER BY `Abs Difference` LIMIT numRows); */
    
    /* DROP TABLE IF EXISTS NearestDisplacement;
	CREATE TABLE NearestDisplacement (id INT PRIMARY KEY AUTO_INCREMENT, Displacement DOUBLE(20, 10), Displacement_Difference_With_Nearest DOUBLE(20, 3), Displacement_Nearest DOUBLE(20, 3));
    INSERT INTO NearestDisplacement (Displacement, Displacement_Nearest, Displacement_Difference_With_Nearest) (SELECT disps, lookupDisps, `Abs Difference` FROM tempTable1 ORDER BY `Abs Difference` LIMIT numRows);
    UPDATE tempSpeedPowerConditions a
		INNER JOIN NearestDisplacement b
			ON a.Displacement = b.Displacement
				SET
                a.Displacement_Nearest = b.Displacement_Nearest,
                a.Displacement_Difference_With_Nearest = b.Displacement_Difference_With_Nearest;
	
    CALL log_msg('Displacement_Nearest 1 = ', (SELECT Displacement_Nearest FROM tempSpeedPowerConditions LIMIT 1));
    
    /* UPDATE tempSpeedPowerConditions SET Displacement_Difference_With_Nearest = (SELECT MIN(ABS(Difference)) AS 'Difference_With_Speed_Power' FROM 
		(SELECT (tempRawISO.Displacement - speedPower.Displacement) AS 'Difference' FROM tempRawISO
			JOIN speedPower WHERE tempRawISO.IMO_Vessel_Number = imo) AS tempTable1 GROUP BY Displacement);
    CALL log_msg('Max DWN = ', (SELECT MAX(Displacement_Difference_With_Nearest) FROM tempSpeedPowerConditions));
    
    UPDATE tempSpeedPowerConditions SET Displacement_Nearest = Displacement + Displacement_Difference_With_Nearest;
    CALL log_msg('Max NISP = ', (SELECT MAX(Displacement_Nearest) FROM tempSpeedPowerConditions)); */
    
    /* Update Displacement Condition */
    /* UPDATE tempSpeedPowerConditions SET Displacement_Diff_PC = ( Displacement_Difference_With_Nearest / Displacement_Nearest )*100;
    UPDATE tempSpeedPowerConditions SET Displacement_Condition = Displacement_Diff_PC > 5;
    CALL log_msg('Max DispCond = ', (SELECT MAX(Displacement_Condition) FROM tempSpeedPowerConditions));
    
    /* Update Trim Condition SELECT Trim FROM tempRawISO */
	/* DROP TABLE IF EXISTS tempTable3;
	CREATE TABLE tempTable3 (id INT PRIMARY KEY AUTO_INCREMENT, rawTrim DOUBLE(20, 10), lookupTrim DOUBLE(20, 10), `Abs Difference` DOUBLE(20, 10));
	INSERT INTO tempTable3 (rawTrim, lookupTrim, `Abs Difference`)
		(SELECT a.Trim, b.Trim, ABS(a.Trim - b.Trim) AS 'Abs Difference'
			FROM tempSpeedPowerConditions a
				JOIN speedPowerCoefficients b
					ORDER BY b.Trim);
                    
    UPDATE tempSpeedPowerConditions a 
	INNER JOIN (SELECT rawTrim, lookupTrim, `Abs Difference` FROM tempTable3 ORDER BY `Abs Difference` LIMIT 2) b
		ON a.Trim = b.rawTrim
			SET a.Trim_Nearest = b.lookupTrim,
				a.Trim_Condition = (ABS(a.Trim) - ABS(a.Trim_Nearest)) > (0.002 * (SELECT LBP FROM Vessels WHERE IMO_Vessel_Number = 9450648));
    
    /* UPDATE tempSpeedPowerConditions a
		INNER JOIN tempRawISO b
			ON a.Displacement = b.Displacement
				SET
                a.Trim_Condition = ABS(b.Trim) > (0.002 * (SELECT LBP FROM Vessels WHERE IMO_Vessel_Number = imo)); */
    
    /* UPDATE tempSpeedPowerConditions, tempRawISO SET Trim_Condition = CASE
		WHEN ABS(tempRawISO.Trim) > (0.002 * (SELECT LBP FROM Vessels WHERE IMO_Vessel_Number = imo))
        THEN TRUE
        ELSE FALSE
	END; */
    /* CALL log_msg('Max TrimCond = ', (SELECT MAX(Trim_Condition) FROM tempSpeedPowerConditions));
    
    /* Update raw data table with conditions */
    /* UPDATE tempRawISO t
		INNER JOIN tempSpeedPowerConditions d
			ON t.Displacement = d.Displacement
				SET
                t.Filter_SpeedPower_Disp = Displacement_Condition,
                t.Filter_SpeedPower_Trim = Trim_Condition;
    CALL log_msg('Max tempRaw Dist Cond = ', (SELECT MAX(Filter_SpeedPower_Disp) FROM tempRawISO));
    
    /* Update Nearest Neighbour Condition */
	/* UPDATE tempSpeedPowerConditions
		SET Nearest_Neighbour_Condition = CASE
			WHEN Displacement_Condition = TRUE AND Trim_Condition = TRUE THEN TRUE
			ELSE FALSE
		END; */
    
    /* Delete unwanted tables */
    
    /* Get upper and lower limits */
    
    /* Is value between limits? */
    
   /* Get boolean column indicating which values of trim and displacement are outside the ranges for nearest-neighbour interpolation */
   /* UPDATE tempRawISO SET Filter_SpeedPower_Disp_Trim = id NOT IN (SELECT Cid FROM
	(SELECT c.id AS Cid, d.id AS Did, `Actual Displacement`, `Actual Trim`, SPTrim, SPDisplacement FROM 
			(SELECT 
				 b.id, 
				 a.Trim AS 'SPTrim',
				 b.Trim AS 'Actual Trim',
				 `Lower Trim`,
				 `Upper Trim`,
				 (a.Trim > `Lower Trim` AND a.Trim < `Upper Trim`) AS ValidTrim
				 FROM speedpowercoefficients a
				 JOIN
					(SELECT
							id,
						   Trim,
						  (Trim - 0.002*(SELECT LBP FROM Vessels WHERE IMO_Vessel_Number = imo)) AS 'Lower Trim',
						  (Trim + 0.002*(SELECT LBP FROM Vessels WHERE IMO_Vessel_Number = imo)) AS 'Upper Trim'
					FROM tempRawISO) AS b) AS c
		JOIN
			(SELECT
				 b.id, 
				 a.Displacement AS 'SPDisplacement',
				 b.Displacement AS 'Actual Displacement',
				 `Lower Displacement`,
				 `Upper Displacement`,
				 (a.Displacement > `Lower Displacement` AND a.Displacement < `Upper Displacement`) AS ValidDisplacement
				 FROM speedpowercoefficients a
				 JOIN
					(SELECT 
							id,
						   Displacement,
						  (Displacement*0.95) AS 'Lower Displacement',
						  (Displacement*1.05) AS 'Upper Displacement'
					FROM tempRawISO) AS b) AS d
		WHERE c.ValidTrim = 1 AND
			  d.ValidDisplacement = 1
			) e
		WHERE Cid = DiD
		GROUP BY Cid)
        ; */
	
    /* Update column giving the nearest value of Displacement and Trim for which the Displacement and Trim conditions are both satisfied */
	/* UPDATE tempRawISO f
	JOIN (SELECT * FROM (SELECT c.id AS Cid, d.id AS Did, `Actual Displacement`, `Actual Trim`, SPTrim, SPDisplacement FROM
				(SELECT
					 b.id,
					 a.Trim AS 'SPTrim',
					 b.Trim AS 'Actual Trim',
					 `Lower Trim`,
					 `Upper Trim`,
					 (a.Trim > `Lower Trim` AND a.Trim < `Upper Trim`) AS ValidTrim
					 FROM speedpowercoefficients a
					 JOIN
						(SELECT
								id,
							   Trim,
							  (Trim - 0.002*(SELECT LBP FROM Vessels WHERE IMO_Vessel_Number = imo)) AS 'Lower Trim',
							  (Trim + 0.002*(SELECT LBP FROM Vessels WHERE IMO_Vessel_Number = imo)) AS 'Upper Trim'
						FROM tempRawISO) AS b) AS c
			JOIN
				(SELECT
					 b.id,
					 a.Displacement AS 'SPDisplacement',
					 b.Displacement AS 'Actual Displacement',
					 `Lower Displacement`,
					 `Upper Displacement`,
					 (a.Displacement > `Lower Displacement` AND a.Displacement < `Upper Displacement`) AS ValidDisplacement
					 FROM speedpowercoefficients a
					 JOIN
						(SELECT
								id,
							   Displacement,
							  (Displacement*0.95) AS 'Lower Displacement',
							  (Displacement*1.05) AS 'Upper Displacement'
						FROM tempRawISO) AS b) AS d
			WHERE c.ValidTrim = 1 AND
				  d.ValidDisplacement = 1
				) e
			WHERE Cid = DiD
			GROUP BY Cid) g
	ON f.id = g.Cid
    SET f.NearestDisplacement = g.SPDisplacement,
		f.NearestTrim = g.SPTrim
        ;*/
	
    /* Get valid trim and nearest trim */
    /*
    UPDATE tempRawISO t
		JOIN (
			SELECT c.id, c.SPTrim, c.ValidTrim
				FROM (SELECT 
					 b.id, 
					 a.Trim AS 'SPTrim',
					 b.Trim AS 'Actual Trim',
					 `Lower Trim`,
					 `Upper Trim`,
					 (a.Trim > `Lower Trim` AND a.Trim < `Upper Trim`) AS ValidTrim,
					 ABS((ABS(a.Trim) - ABS(b.Trim))) AS DiffTrim
					 FROM speedpowercoefficients a
					 JOIN
						(SELECT
								id,
								IMO_Vessel_Number,
							   Trim,
							  (Trim - 0.002*(SELECT LBP FROM Vessels WHERE IMO_Vessel_Number = imo)) AS 'Lower Trim',
							  (Trim + 0.002*(SELECT LBP FROM Vessels WHERE IMO_Vessel_Number = imo)) AS 'Upper Trim'
						FROM tempRawISO) AS b
							WHERE a.ModelID IN (SELECT Speed_Power_Model FROM vesselspeedpowermodel WHERE IMO_Vessel_Number = imo)) AS c
					 INNER JOIN
						(
						SELECT f.id, 'SPTrim', 'Actual Trim', `Lower Trim`, `Upper Trim`, ValidTrim, MIN(DiffTrim) AS MinDiff
						FROM (SELECT 
								 d.id, 
								 a.Trim AS 'SPTrim',
								 d.Trim AS 'Actual Trim',
								 `Lower Trim`,
								 `Upper Trim`,
								 (a.Trim > `Lower Trim` AND a.Trim < `Upper Trim`) AS ValidTrim,
								 ABS((ABS(a.Trim) - ABS(d.Trim))) AS DiffTrim
								 FROM speedpowercoefficients a
								 JOIN
									(SELECT
											id,
											IMO_Vessel_Number,
										   Trim,
										  (Trim - 0.002*(SELECT LBP FROM Vessels WHERE IMO_Vessel_Number = imo)) AS 'Lower Trim',
										  (Trim + 0.002*(SELECT LBP FROM Vessels WHERE IMO_Vessel_Number = imo)) AS 'Upper Trim'
									FROM tempRawISO) AS d
							WHERE a.ModelID IN (SELECT Speed_Power_Model FROM vesselspeedpowermodel WHERE IMO_Vessel_Number = imo)) AS f
							GROUP BY id) AS e /* 'SPTrim', 'Actual Trim', `Lower Trim`, `Upper Trim`,  */ 
/*					  ON
						c.id= e.id AND
						c.DiffTrim = e.MinDiff
					  GROUP BY c.id) w
                    ON t.id = w.id
		SET t.Filter_SpeedPower_Trim = NOT(w.ValidTrim),
			t.NearestTrim = w.SPTrim
				;*/
	
    UPDATE tempRawISO SET Filter_SpeedPower_Disp = FALSE WHERE Filter_SpeedPower_Disp IS NULL;
    UPDATE tempRawISO SET Filter_SpeedPower_Trim = FALSE WHERE Filter_SpeedPower_Trim IS NULL;
	UPDATE tempRawISO SET Filter_SpeedPower_Disp_Trim = FALSE WHERE Filter_SpeedPower_Disp_Trim IS NULL;
    
    /* Get valid displacement and nearest displacement */
    UPDATE `inservice`.tempRawISO t
		JOIN (
			SELECT z.id, z.ValidDisplacement, z.SPDisplacement AS 'Nearest_Displacement'
				FROM
					(SELECT
						 b.id,
                         /* a.IMO_Vessel_Number, */
						 a.Displacement AS 'SPDisplacement',
						 b.Displacement AS 'Actual Displacement',
						 `Lower Displacement`,
						 `Upper Displacement`,
						 (a.Displacement > `Lower Displacement` AND a.Displacement < `Upper Displacement`) AS ValidDisplacement,
						 ABS((ABS(a.Displacement) - ABS(b.Displacement))) AS DiffDisp
						 FROM `static`.speedpowercoefficientmodelvalue a
						 JOIN
							(SELECT
									id,
								   Displacement,
								  (Displacement*0.95) AS 'Lower Displacement',
								  (Displacement*1.05) AS 'Upper Displacement'
							FROM `inservice`.tempRawISO) AS b
						WHERE a.Speed_Power_Coefficient_Model_Id IN (SELECT Speed_Power_Coefficient_Model_Value_Id FROM `static`.SpeedPowerCoefficientModelValue 
																		WHERE Speed_Power_Coefficient_Model_Id = 
																			(SELECT Speed_Power_Coefficient_Model_Id FROM `static`.VesselConfiguration 
																				WHERE Vessel_Configuration_Id = vcid))) AS z
				INNER JOIN
					(
					SELECT d.id, SPDisplacement, `Actual Displacement`, `Lower Displacement`, `Upper Displacement`, ValidDisplacement, MIN(DiffDisp) AS MinDiff
					FROM (SELECT
						 b.id,
                         /* a.IMO_Vessel_Number, */
						 a.Displacement AS 'SPDisplacement',
						 b.Displacement AS 'Actual Displacement',
						 `Lower Displacement`,
						 `Upper Displacement`,
						 (a.Displacement > `Lower Displacement` AND a.Displacement < `Upper Displacement`) AS ValidDisplacement,
						 ABS((ABS(a.Displacement) - ABS(b.Displacement))) AS DiffDisp
						 FROM `static`.speedpowercoefficientmodelvalue a
						 JOIN
							(SELECT
									id,
								   Displacement,
								  (Displacement*0.95) AS 'Lower Displacement',
								  (Displacement*1.05) AS 'Upper Displacement'
							FROM `inservice`.tempRawISO) AS b
						WHERE a.Speed_Power_Coefficient_Model_Id IN (SELECT Speed_Power_Coefficient_Model_Value_Id FROM `static`.SpeedPowerCoefficientModelValue 
																		WHERE Speed_Power_Coefficient_Model_Id = 
																			(SELECT Speed_Power_Coefficient_Model_Id FROM `static`.VesselConfiguration 
																				WHERE Vessel_Configuration_Id = vcid))) AS d
					 GROUP BY id) AS x /* 'SPTrim', 'Actual Trim', `Lower Trim`, `Upper Trim`,  */ 
				  ON
					z.id= x.id AND
					z.DiffDisp = x.MinDiff
					GROUP BY z.id) w
                    ON t.id = w.id
			 SET t.Nearest_Displacement = w.Nearest_Displacement,
				 t.Filter_SpeedPower_Disp = NOT(w.ValidDisplacement);
    
    /* Get valid trim and nearest trim */
    UPDATE tempRawISO q
	JOIN 
		(SELECT a.id, b.Trim, NOT( a.Nearest_Trim >= (a.Trim - 0.002*(SELECT LBP FROM `static`.VesselConfiguration WHERE Vessel_Configuration_Id = vcid)) AND
				a.Nearest_Trim <= (a.Trim + 0.002*(SELECT LBP FROM `static`.VesselConfiguration WHERE Vessel_Configuration_Id = vcid)) ) AS 'FT'
			FROM tempRawISO a
			JOIN
			(
				SELECT t.id, s.Trim, s.Displacement FROM `static`.SpeedPowerCoefficientModelValue s
					JOIN tempRawISO t
						ON s.Displacement = t.Nearest_Displacement
							WHERE s.Speed_Power_Coefficient_Model_Id IN (SELECT Speed_Power_Coefficient_Model_Value_Id FROM `static`.SpeedPowerCoefficientModelValue 
																		WHERE Speed_Power_Coefficient_Model_Id = 
																			(SELECT Speed_Power_Coefficient_Model_Id FROM `static`.VesselConfiguration 
																				WHERE Vessel_Configuration_Id = vcid))
						  ) b
					ON a.id = b.id) w
						ON q.id = w.id
                        SET q.Filter_SpeedPower_Trim = w.FT,
							q.Nearest_Trim			 = w.Trim;
                            
    /* Get valid trim and nearest trim, again, because it doesn't work the first time... */
    UPDATE tempRawISO q
	JOIN 
		(SELECT a.id, b.Trim, NOT( a.Nearest_Trim >= (a.Trim - 0.002*(SELECT LBP FROM `static`.VesselConfiguration WHERE Vessel_Configuration_Id = vcid)) AND
				a.Nearest_Trim <= (a.Trim + 0.002*(SELECT LBP FROM `static`.VesselConfiguration WHERE Vessel_Configuration_Id = vcid)) ) AS 'FT'
			FROM tempRawISO a
			JOIN
			(
				SELECT t.id, s.Trim, s.Displacement FROM `static`.SpeedPowerCoefficientModelValue s
					JOIN tempRawISO t
						ON s.Displacement = t.Nearest_Displacement
							WHERE s.Speed_Power_Coefficient_Model_Id IN (SELECT Speed_Power_Coefficient_Model_Value_Id FROM `static`.SpeedPowerCoefficientModelValue 
																		WHERE Speed_Power_Coefficient_Model_Id = 
																			(SELECT Speed_Power_Coefficient_Model_Id FROM `static`.VesselConfiguration 
																				WHERE Vessel_Configuration_Id = vcid))
						  ) b
					ON a.id = b.id) w
						ON q.id = w.id
                        SET q.Filter_SpeedPower_Trim = w.FT,
							q.Nearest_Trim			 = w.Trim;
	
	/* Get boolean column indicating which values of trim and displacement are outside the ranges for nearest-neighbour interpolation */
	UPDATE tempRawISO SET Filter_SpeedPower_Disp_Trim = (Filter_SpeedPower_Disp OR Filter_SpeedPower_Trim);
    
    /*       
    UPDATE tempRawISO a
	JOIN (
			SELECT t.id, s.Trim, s.Displacement FROM speedpowercoefficients s
				JOIN tempRawISO t
					ON s.Displacement = t.NearestDisplacement
						WHERE s.ModelID IN (SELECT Speed_Power_Model FROM vesselspeedpowermodel WHERE IMO_Vessel_Number = imo)
		  ) b
	ON a.id = b.id
		SET a.NearestTrim = b.Trim,
			a.Filter_SpeedPower_Trim = NOT( a.NearestTrim >= (a.Trim - 0.002*(SELECT LBP FROM Vessels WHERE IMO_Vessel_Number = imo)) AND
											a.NearestTrim <= (a.Trim + 0.002*(SELECT LBP FROM Vessels WHERE IMO_Vessel_Number = imo)) );
    */
    
END