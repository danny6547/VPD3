/* Process data for vessel performance analysis as described in ISO 19030-2 */

delimiter //

CREATE PROCEDURE ISO19030(imo int)
BEGIN

	/* Get retreived data set 5.3.3 */
    CALL createTempRawISO(imo);
    CALL removeInvalidRecords();
    CALL sortOnDateTime();
    
    /* Normalise frequency rates 5.3.3.1 */
    
    /* Get validated data set 5.3.4 */
    
    /* Correct for environmental factors 5.3.5 */
    CALL updateDeliveredPower(imo);
    CALL removeFOCBelowMinimum(imo);
    
    CALL updateWindResistanceRelative(imo);
	CALL updateAirResistanceNoWind(imo);
	CALL updateWindResistanceCorrection(imo);
    
    CALL updateCorrectedPower();
    
    /* Calculate Performance Values 5.3.6.2 */
    CALL updateExpectedSpeed(imo);
    
    /* Calculate Performance Values 5.3.6.1 */
    CALL updateSpeedLoss();
    
    /* Calculate filter */
    CALL filterSFOCOutOfRange(imo);
    
END;