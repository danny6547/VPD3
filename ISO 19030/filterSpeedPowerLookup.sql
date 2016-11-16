/* Detect rows where displacement is outside the range of +/-5% of the nearest value in the SpeedPower table*/

DROP PROCEDURE IF EXISTS filterSpeedPowerLookup;

delimiter //

CREATE PROCEDURE filterSpeedPowerLookup(imo INT)
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
                t.FilterSPDisp = Displacement_Condition,
                t.FilterSPTrim = Trim_Condition;
    CALL log_msg('Max tempRaw Dist Cond = ', (SELECT MAX(FilterSPDisp) FROM tempRawISO));
    
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
   UPDATE tempRawISO SET FilterSPDispTrim = FALSE;
	/* UPDATE tempRawISO SET FilterSPDispTrim = id IN (SELECT Cid FROM
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
						  (Trim - 0.002*(SELECT LBP FROM Vessels WHERE IMO_Vessel_Number = 9450648)) AS 'Lower Trim',
						  (Trim + 0.002*(SELECT LBP FROM Vessels WHERE IMO_Vessel_Number = 9450648)) AS 'Upper Trim'
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
END