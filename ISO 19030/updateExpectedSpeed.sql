/* Calculate expected speed from delivered power and speed-power-draft-trim data */

delimiter //

CREATE PROCEDURE updateExpectedSpeed(imo INT)
BEGIN
	
    
    /* Update Displacement Condition */
    /*UPDATE tempSpeedPowerConditions SET Displacement = (SELECT Displacement FROM tempRawISO);
    UPDATE tempSpeedPowerConditions SET Difference_With_Nearest = (SELECT MIN(ABS(Difference)) AS 'Difference_With_Speed_Power' FROM 
		(SELECT (tempRawISO.Displacement - speedPower.Displacement) AS 'Difference' FROM tempRawISO
			JOIN speedPower WHERE IMO_Vessel_Number = imo) AS tempTable1 GROUP BY tempRawISO.Displacement);
    UPDATE tempSpeedPowerConditions SET Nearest_In_Speed_Power = Displacement + Difference_With_Nearest;
    UPDATE tempSpeedPowerConditions SET Difference_PC = ( Difference_With_Nearest / Nearest_In_Speed_Power )*100; 
    UPDATE tempSpeedPowerConditions SET Displacement_Condition = Difference_PC <= 5;
    
    /* Update Trim Condition */
    /*UPDATE tempSpeedPowerConditions SET Trim_Condition = CASE
		WHEN (SELECT Trim FROM tempRawISO) > (0.002 * (SELECT LBP FROM Vessels WHERE IMO_Vessel_Number = imo))
        THEN TRUE
        ELSE FALSE
	END;
    
    /* Update Nearest Neighbour Condition */
	/*UPDATE tempSpeedPowerConditions 
		SET Nearest_Neighbour_Condition = CASE
			WHEN Displacement_Cond = TRUE AND Trim_Condition = TRUE THEN TRUE
			ELSE FALSE
		END; */
	
    /* Calculate expected speed from fitted speed-power curve */
	UPDATE tempRawISO SET Expected_Speed_Through_Water = ((SELECT Exponent_A FROM speedPowerCoefficients WHERE IMO_Vessel_Number = imo) * LOG(Delivered_Power))
														+ (SELECT Exponent_B FROM speedPowerCoefficients WHERE IMO_Vessel_Number = imo);
    
	/* /* Case where all delivered power values match those in SpeedPower */
	/* SELECT Speed FROM SpeedPower WHERE IMO = imo AND Power = (SELECT Delivered_Power FROM tempRawISO); */
	
	/* Case where delivered power values are within range but don't exactly match those in SpeedPower */
    /* SELECT Speed FROM SpeedPower WHERE IMO = imo AND Power > (SELECT Delivered_Power FROM tempRawISO); */
	
END