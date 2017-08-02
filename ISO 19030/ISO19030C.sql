/* Process data for vessel performance analysis as described in ISO 19030-2 */


DROP PROCEDURE IF EXISTS ISO19030C;

delimiter //

CREATE PROCEDURE ISO19030C(imo int)
BEGIN
	
	CALL updateAirResistanceNoWind(imo);
	CALL updateWindResistanceCorrection(imo);
    CALL updateCorrectedPower();
    
    /* Calculate Performance Values, Expected Speed 5.3.6.2 */
    CALL updateExpectedSpeed(imo);
    
    /* Calculate Performance Values, Percentage speed loss 5.3.6.1 */
    CALL updateSpeedLoss();
    
    /* Calculate filter */
    CALL filterSFOCOutOfRange(imo);
    CALL filterPowerBelowMinimum(imo);
    CALL filterReferenceConditions(imo);
    
END;