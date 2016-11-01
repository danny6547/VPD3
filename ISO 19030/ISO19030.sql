/* Process data for vessel performance analysis as described in ISO 19030-2 */

delimiter //

CREATE PROCEDURE ISO19030(imo int)
BEGIN

	/* Get retreived data set */
    CALL createTempRawISO(imo);
    
    /* Normalise frequency rates */
    
    /* Get validated data set */
    
    /* Correct for environmental factors */
    CALL updateDeliveredPower(imo);
    
    CALL updateCorrectPower(imo);
    

END;