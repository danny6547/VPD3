/* Correct for Wind Resistance */

delimiter //

CREATE PROCEDURE updateWindResistanceRelative(imo INT)
BEGIN
	
    /* DECLARE WindResCoeff DOUBLE(10, 5); */
    
	UPDATE tempRawISO
	SET Wind_Resistance_Relative = 
		0.5 * 
		Air_Density * 
		POWER(Relative_Wind_Speed, 2) * 
		( SELECT Transverse_Projected_Area_Design FROM Vessels WHERE IMO = imo) * 
		( SELECT Coefficient FROM WindCoefficientDirection WHERE IMO = imo AND Relative_Wind_Direction >= Start_Direction AND Relative_Wind_Direction < End_Direction);
	
END;