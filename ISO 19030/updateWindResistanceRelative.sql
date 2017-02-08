/* Update Wind Resistance Relative based on equation G2. */

USE hull_performance;

DROP PROCEDURE IF EXISTS updateWindResistanceRelative;

delimiter //

CREATE PROCEDURE updateWindResistanceRelative(imo INT)
BEGIN
    
	UPDATE tempRawISO
	SET Wind_Resistance_Relative =
		0.5 *
		Air_Density *
		POWER(Relative_Wind_Speed, 2) *
        Transverse_Projected_Area_Current * 
		( SELECT Coefficient FROM WindCoefficientDirection WHERE IMO_Vessel_Number = imo AND Relative_Wind_Direction >= Start_Direction AND Relative_Wind_Direction < End_Direction);
	
END;