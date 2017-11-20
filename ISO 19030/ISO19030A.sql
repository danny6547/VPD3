/* Process data for vessel performance analysis as described in ISO 19030-2 */

DROP PROCEDURE IF EXISTS ISO19030A;

delimiter //

CREATE PROCEDURE ISO19030A(imo int)
BEGIN
	
    /* Create Temporary table for analysis */
    CALL createTempRawISO(imo);
    
    /* Remove data which cannot be used in calculations */
    CALL cleanData();
    
	/* Get retreived data set 5.3.3 */
    CALL removeInvalidRecords();
    CALL sortOnDateTime();
    CALL updateDefaultValues();
    
    /* Normalise frequency rates 5.3.3.1 */
    /*CALL normaliseHigherFreq();
    CALL normaliseLowerFreq();*/
    
    /* Get validated data set 5.3.4 */
    CALL updateChauvenetCriteria();
    CALL updateValidated();
    
    CALL updateTrim();
END;