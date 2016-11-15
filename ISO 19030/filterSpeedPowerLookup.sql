/* Detect rows where displacement is outside the range of +/-5% of the nearest value in the SpeedPower table*/

DROP PROCEDURE IF EXISTS filterSpeedPowerLookup;

delimiter //

CREATE PROCEDURE filterSpeedPowerLookup(imo INT)
BEGIN
	
    /* Declarations */
    DECLARE numRows INT;
    SET numRows := (SELECT COUNT(*) FROM tempRawISO);
    
    /* Create temporary table for speed-power data look-up */
	DROP TABLE IF EXISTS tempSpeedPowerConditions;
	CREATE TABLE tempSpeedPowerConditions (id INT PRIMARY KEY AUTO_INCREMENT,
									Displacement DOUBLE(20, 10),
									Difference_With_Nearest DOUBLE(20, 3),
									Nearest_In_Speed_Power DOUBLE(20, 3),
									Difference_PC DOUBLE(10, 5),
									Displacement_Condition BOOLEAN,
									Trim_Condition BOOLEAN,
									Nearest_Neighbour_Condition BOOLEAN);
    
	/* Find nearest displacement value */
    INSERT INTO tempSpeedPowerConditions (Displacement) SELECT Displacement FROM tempRawISO;
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
                a.Nearest_In_Speed_Power = b.disps ORDER BY `Abs Difference` LIMIT numRows;
    /* UPDATE tempSpeedPowerConditions a,  tempTable1 b SET a.Nearest_In_Speed_Power = (SELECT b.disps FROM tempTable1 ORDER BY `Abs Difference` LIMIT numRows); */
	/*INSERT INTO tempSpeedPowerConditions (Nearest_In_Speed_Power) (SELECT disps FROM tempTable1 ORDER BY `Abs Difference` LIMIT numRows); */
    
    DROP TABLE IF EXISTS tempTable2;
	CREATE TABLE tempTable2 (id INT PRIMARY KEY AUTO_INCREMENT, Displacement DOUBLE(20, 10), Difference_With_Nearest DOUBLE(20, 3), Nearest_In_Speed_Power DOUBLE(20, 3));
    INSERT INTO tempTable2 (Displacement, Nearest_In_Speed_Power, Difference_With_Nearest) (SELECT disps, lookupDisps, `Abs Difference` FROM tempTable1 ORDER BY `Abs Difference` LIMIT numRows);
    UPDATE tempSpeedPowerConditions a
		INNER JOIN tempTable2 b
			ON a.Displacement = b.Displacement
				SET
                a.Nearest_In_Speed_Power = b.Nearest_In_Speed_Power,
                a.Difference_With_Nearest = b.Difference_With_Nearest;
	
    CALL log_msg('Nearest_In_Speed_Power 1 = ', (SELECT Nearest_In_Speed_Power FROM tempSpeedPowerConditions LIMIT 1));
    
    /* UPDATE tempSpeedPowerConditions SET Difference_With_Nearest = (SELECT MIN(ABS(Difference)) AS 'Difference_With_Speed_Power' FROM 
		(SELECT (tempRawISO.Displacement - speedPower.Displacement) AS 'Difference' FROM tempRawISO
			JOIN speedPower WHERE tempRawISO.IMO_Vessel_Number = imo) AS tempTable1 GROUP BY Displacement);
    CALL log_msg('Max DWN = ', (SELECT MAX(Difference_With_Nearest) FROM tempSpeedPowerConditions));
    
    UPDATE tempSpeedPowerConditions SET Nearest_In_Speed_Power = Displacement + Difference_With_Nearest;
    CALL log_msg('Max NISP = ', (SELECT MAX(Nearest_In_Speed_Power) FROM tempSpeedPowerConditions)); */
    
    /* Update Displacement Condition */
    UPDATE tempSpeedPowerConditions SET Difference_PC = ( Difference_With_Nearest / Nearest_In_Speed_Power )*100;
    UPDATE tempSpeedPowerConditions SET Displacement_Condition = Difference_PC > 5;
    CALL log_msg('Max DispCond = ', (SELECT MAX(Displacement_Condition) FROM tempSpeedPowerConditions));
    
    /* Update trim */
    UPDATE tempRawISO SET Trim = Static_Draught_Fore - Static_Draught_Aft;
    
    /* Update Trim Condition SELECT Trim FROM tempRawISO */
    UPDATE tempSpeedPowerConditions a
		INNER JOIN tempRawISO b
			ON a.Displacement = b.Displacement
				SET
                a.Trim_Condition = ABS(b.Trim) > (0.002 * (SELECT LBP FROM Vessels WHERE IMO_Vessel_Number = imo));
    
    
    /* UPDATE tempSpeedPowerConditions, tempRawISO SET Trim_Condition = CASE
		WHEN ABS(tempRawISO.Trim) > (0.002 * (SELECT LBP FROM Vessels WHERE IMO_Vessel_Number = imo))
        THEN TRUE
        ELSE FALSE
	END; */
    CALL log_msg('Max TrimCond = ', (SELECT MAX(Trim_Condition) FROM tempSpeedPowerConditions));
    
    /* Update raw data table with conditions */
    UPDATE tempRawISO t
		INNER JOIN tempSpeedPowerConditions d
			ON t.Displacement = d.Displacement /* !! */
				SET
                t.FilterSPDisp = Displacement_Condition,
                t.FilterSPTrim = Trim_Condition;
    CALL log_msg('Max tempRaw Dist Cond = ', (SELECT MAX(FilterSPDisp) FROM tempRawISO));
    
    /* Update Nearest Neighbour Condition */
	UPDATE tempSpeedPowerConditions
		SET Nearest_Neighbour_Condition = CASE
			WHEN Displacement_Condition = TRUE AND Trim_Condition = TRUE THEN TRUE
			ELSE FALSE
		END;
    
    /* Get upper and lower limits */
    
    /* Is value between limits? */
    
    
END