/* Calculate shaft power from torque and revolutions */


DROP PROCEDURE IF EXISTS updateShaftPower;

delimiter //

CREATE PROCEDURE updateShaftPower()
BEGIN
	
	UPDATE tempRawISO SET Shaft_Power = Shaft_Torque * Shaft_Revolutions * (2 * PI() / 60);
END