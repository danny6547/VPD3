/* Update delivered power */

delimiter //

CREATE PROCEDURE updateDeliveredPower(imo INT)
BEGIN
	
    /* DECLARATIONS */
    /* DECLARE isAvail BOOLEAN; */
    
    /* Check if torsio-metre data available */
    CALL isShaftPowerAvailable(1234568, @isAvail);
    
    CALL log_msg(concat('isAVAIL = ', @isAvail));
    
    IF (SELECT @isAvail) THEN
		
        CALL updateShaftPower(imo);
		CALL log_msg(concat('UPDATE shaft power called'));
        UPDATE tempRawISO SET Delivered_Power = Shaft_Power;
    
    /* Check if engine data available */
    
    
    /* Error if value cannot be calculated */
    
    
    END IF;
    
END;