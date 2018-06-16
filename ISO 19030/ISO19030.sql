/* Process data for vessel performance analysis as described in ISO 19030-2 */


DROP PROCEDURE IF EXISTS ISO19030;

delimiter //

CREATE PROCEDURE ISO19030(imo int)
BEGIN
	
	/* Get retreived data set 5.3.3 */
    CALL `inservice`.createTempRawISO(imo);
    CALL `inservice`.removeInvalidRecords();
    CALL `inservice`.sortOnDateTime();
    CALL `inservice`.updateDefaultValues();
    
    /* Normalise frequency rates 5.3.3.1 */
    CALL `inservice`.normaliseHigherFreq();
    CALL `inservice`.normaliseLowerFreq();
    
    /* Get validated data set 5.3.4 */
    CALL `inservice`.updateChauvenetCriteria();
    CALL `inservice`.updateValidated();
    
    CALL `inservice`.updateDisplacement(imo);
    CALL `inservice`.updateTrim();
    CALL `inservice`.filterSpeedPowerLookup(imo);
    
    /* Correct for environmental factors 5.3.5 */
    CALL `inservice`.updateDeliveredPower(imo);
    CALL `inservice`.updateAirDensity();
    CALL `inservice`.updateTransProjArea(imo);
    CALL `inservice`.updateWindReference();
    CALL `inservice`.updateWindResistanceRelative(imo);
	CALL `inservice`.updateAirResistanceNoWind(imo);
	CALL `inservice`.updateWindResistanceCorrection(imo);
    CALL `inservice`.updateCorrectedPower();
    
    /* Calculate Performance Values, Expected Speed 5.3.6.2 */
    CALL `inservice`.updateExpectedSpeed(imo);
    
    /* Calculate Performance Values, Percentage speed loss 5.3.6.1 */
    CALL `inservice`.updateSpeedLoss();
    
    /* Calculate filter */
    CALL `inservice`.filterSFOCOutOfRange(imo);
    CALL `inservice`.filterPowerBelowMinimum(imo);
    CALL `inservice`.filterReferenceConditions(imo);
END;