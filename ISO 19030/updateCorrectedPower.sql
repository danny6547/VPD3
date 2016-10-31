/* Correct delivered power values for environmental factors */

delimiter //

CREATE PROCEDURE updateCorrectedPower()
BEGIN
	
	UPDATE tempRawISO
	SET Corrected_Power = Delivered_Power - Wind_Resistance_Correction;
	
END;