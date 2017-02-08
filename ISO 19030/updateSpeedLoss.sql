/* Calculate speed loss as a percentage */

USE hull_performance;


delimiter //

CREATE PROCEDURE updateSpeedLoss()
BEGIN

	UPDATE tempRawISO SET Speed_Loss = (100 * (Speed_Through_Water - Expected_Speed_Through_Water) / Expected_Speed_Through_Water);

END;