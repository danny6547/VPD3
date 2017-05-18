/* Process data for vessel performance analysis as described in ISO 19030-2 */


DROP PROCEDURE IF EXISTS ISO19030;

delimiter //

CREATE PROCEDURE ISO19030(imo int)
BEGIN
	
	/* Get retreived data set 5.3.3 */
    CALL createTempRawISO(imo);
    CALL removeInvalidRecords();
    CALL sortOnDateTime();
    
    /* Normalise frequency rates 5.3.3.1 */
    CALL normaliseHigherFreq();
    CALL normaliseLowerFreq();
    
    /* Get validated data set 5.3.4 */
    CALL updateChauvenetCriteria();
    CALL updateValidated();
    
    /* Correct for environmental factors 5.3.5 */
    CALL updateDeliveredPower(imo);
    
    CALL updateAirDensity();
    CALL updateTransProjArea(imo);
    CALL updateWindReference();
    CALL updateWindResistanceRelative(imo);
	CALL updateAirResistanceNoWind(imo);
	CALL updateWindResistanceCorrection(imo);
    
    CALL updateDisplacement(imo);
    CALL updateTrim();
    CALL filterSpeedPowerLookup(imo);
    
    CALL updateCorrectedPower();
    
    /* Calculate Performance Values 5.3.6.2 */
    CALL updateExpectedSpeed(imo);
    
    /* Calculate Performance Values 5.3.6.1 */
    CALL updateSpeedLoss();
    
    /* Calculate filter */
    CALL filterSFOCOutOfRange(imo);
    CALL filterPowerBelowMinimum(imo);
    
END;