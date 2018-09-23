/* Calculate speed loss as a percentage */


DROP PROCEDURE IF EXISTS updateSpeedLoss;

delimiter //

CREATE PROCEDURE updateSpeedLoss()
BEGIN

	UPDATE tempRawISO SET Speed_Loss = (Speed_Through_Water - Expected_Speed_Through_Water) / Expected_Speed_Through_Water;

END;