/* Calculate expected speed from delivered power and speed-power-draft-trim data */

DROP PROCEDURE IF EXISTS updateExpectedSpeed;

delimiter //

CREATE PROCEDURE updateExpectedSpeed(imo INT)
BEGIN
	
    /* Calculate expected speed from fitted speed-power curve */
	UPDATE tempRawISO SET Expected_Speed_Through_Water = ((SELECT Exponent_A FROM speedPowerCoefficients WHERE IMO_Vessel_Number = imo AND Displacement = 137090) * LOG(Delivered_Power))
														+ (SELECT Exponent_B FROM speedPowerCoefficients WHERE IMO_Vessel_Number = imo AND Displacement = 137090);
    
END