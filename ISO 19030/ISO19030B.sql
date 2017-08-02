/* Process data for vessel performance analysis as described in ISO 19030-2 */

DROP PROCEDURE IF EXISTS ISO19030B;

delimiter //

CREATE PROCEDURE ISO19030B(imo int)
BEGIN
	
    CALL updateDisplacement(imo);
	CALL filterSpeedPowerLookup(imo);
    CALL updateNearestTrim(imo);
    
    /* Correct for environmental factors 5.3.5 */
    CALL updateDeliveredPower(imo);
    CALL updateAirDensity();
    CALL updateTransProjArea(imo);
    CALL updateWindReference();
END;