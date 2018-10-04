/* Process data for vessel performance analysis as described in ISO 19030-2 */


DROP PROCEDURE IF EXISTS ISO19030;

delimiter //

CREATE PROCEDURE ISO19030(vcid int)
BEGIN
	
	/* Get retreived data set 5.3.3 */
    CALL createTempRawISO(vcid);
    CALL removeInvalidRecords();
    CALL sortOnDateTime();
    CALL updateDefaultValues();
    
    /* Normalise frequency rates 5.3.3.1 */
    CALL normaliseHigherFreq();
    CALL normaliseLowerFreq();
    
    /* Get validated data set 5.3.4 */
    CALL updateChauvenetCriteria();
    CALL updateValidated();
    
    CALL updateDisplacement(vcid);
    CALL updateTrim();
    CALL filterSpeedPowerLookup(vcid);
    
    /* Correct for environmental factors 5.3.5 */
    CALL updateDeliveredPower(vcid);
    CALL updateAirDensity();
    CALL updateTransProjArea(vcid);
    CALL updateWindReference(vcid);
    CALL updateWindResistanceRelative(vcid);
	CALL updateAirResistanceNoWind(vcid);
	CALL updateWindResistanceCorrection(vcid);
    CALL updateCorrectedPower();
    
    /* Calculate Performance Values, Expected Speed 5.3.6.2 */
    CALL updateExpectedSpeed(vcid);
    
    /* Calculate Performance Values, Percentage speed loss 5.3.6.1 */
    CALL updateSpeedLoss();
    
    /* Calculate filter */
    CALL filterSFOCOutOfRange(vcid);
    CALL filterPowerBelowMinimum(vcid);
    CALL filterReferenceConditions(vcid);
END;