/* Calculate expected speed from delivered power and speed,power,draft,trim 
data */




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
    
    /* Check whether Admiralty formula should be used to correct for displacement */
    UPDATE tempRawISO SET Displacement_Correction_Needed = FALSE;
    UPDATE tempRawISO SET Displacement_Correction_Needed = TRUE WHERE NearestDisplacement > Displacement*1.05 OR NearestDisplacement < Displacement*0.95;
    
    /* Get coefficients of speed, power curve for nearest diplacement, trim */ 
    UPDATE IGNORE tempRawISO ii JOIN
	(SELECT i.id, i.IMO_Vessel_Number, NearestDisplacement, NearestTrim, i.Displacement, i.Trim, s.Coefficient_A, s.Coefficient_B, s.Coefficient_C FROM tempRawISO i
		JOIN speedpowercoefficients s
			ON i.IMO_Vessel_Number = s.IMO_Vessel_Number AND
			   i.NearestDisplacement = s.Displacement AND
			   i.NearestTrim = s.Trim) si
	ON ii.id = si.id
	SET Expected_Speed_Through_Water = (Coefficient_A*POWER(Corrected_Power, 2) + Coefficient_B*Corrected_Power + Coefficient_C) * POWER( POWER(ii.Displacement, (2/3)) / POWER(ii.NearestDisplacement, (2/3)), (1/3)) /* Exponent_A*LOG(ABS(Corrected_Power)) + Exponent_B */
    WHERE Displacement_Correction_Needed IS FALSE;
    
    /* Get coefficients of speed, power curve for nearest diplacement, trim */ 
    UPDATE IGNORE tempRawISO ii JOIN
	(SELECT i.id, i.IMO_Vessel_Number, NearestDisplacement, NearestTrim, i.Displacement, i.Trim, s.Coefficient_A, s.Coefficient_B, s.Coefficient_C FROM tempRawISO i
		JOIN speedpowercoefficients s
			ON i.IMO_Vessel_Number = s.IMO_Vessel_Number AND
			   i.NearestDisplacement = s.Displacement AND
			   i.NearestTrim = s.Trim) si
	ON ii.id = si.id
	SET Expected_Speed_Through_Water = (Coefficient_A*POWER(Corrected_Power, 2) + Coefficient_B*Corrected_Power + Coefficient_C) * POWER( POWER(ii.Displacement, (2/3)) / POWER(ii.NearestDisplacement, (2/3)), (1/3))
    WHERE Displacement_Correction_Needed IS TRUE;
END