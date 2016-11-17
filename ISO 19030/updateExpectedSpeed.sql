/* Calculate expected speed from delivered power and speed-power-draft-trim data */

DROP PROCEDURE IF EXISTS updateExpectedSpeed;

delimiter //

CREATE PROCEDURE updateExpectedSpeed(imo INT)
BEGIN
	
    /* Calculate expected speed from fitted speed-power curve
	UPDATE tempRawISO SET Expected_Speed_Through_Water = ((SELECT Exponent_A FROM speedPowerCoefficients WHERE IMO_Vessel_Number = imo AND Displacement = 137090) * LOG(Delivered_Power))
														+ (SELECT Exponent_B FROM speedPowerCoefficients WHERE IMO_Vessel_Number = imo AND Displacement = 137090); */
    
	/* Calculate expected speed from fitted speed-power curve */ 
    /* UPDATE tempRawISO c
	INNER JOIN (
				SELECT b.Displacement, a.Exponent_A, a.Exponent_B, b.Nearest_In_Speed_Power
					FROM speedpowercoefficients a
						JOIN NearestDisplacement b
							ON a.Displacement = b.Nearest_In_Speed_Power
								WHERE a.IMO_Vessel_Number = imo
				) d
	ON c.Displacement = d.Displacement
	SET c.Expected_Speed_Through_Water = d.Exponent_A*LOG(ABS(c.Delivered_Power)) + d.Exponent_B; */ 
    
    /* Get coefficients of speed, power curve for nearest diplacement, trim */ 
    UPDATE tempRawISO ii JOIN
	(SELECT i.id, NearestDisplacement, NearestTrim, i.Displacement, i.Trim, s.Exponent_A, s.Exponent_B FROM tempRawISO i
		JOIN speedpowercoefficients s
			ON i.NearestDisplacement = s.Displacement AND
			   i.NearestTrim = s.Trim) si
	ON ii.id = si.id
	SET Expected_Speed_Through_Water = Exponent_A*LOG(ABS(Delivered_Power)) + Exponent_B;
    
END