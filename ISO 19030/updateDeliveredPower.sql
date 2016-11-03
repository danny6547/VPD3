/* Update delivered power */

delimiter //

CREATE PROCEDURE updateDeliveredPower(imo INT)
BEGIN
	
    /* DECLARATIONS */
    /* DECLARE isAvail BOOLEAN; */
    
    /* Check if torsio-metre data available 
    CALL log_msg(concat('isShaftAvail = ', @isShaftAvail));
		CALL log_msg(concat('UPDATE shaft power called')); */
	DECLARE powerIncalculable CONDITION FOR SQLSTATE '45000';
	
    CALL isShaftPowerAvailable(imo, @isShaftAvail);
    CALL isBrakePowerAvailable(imo, @isBrakeAvail, @isMassNeeded);
    
    IF @isShaftAvail THEN
		
        CALL updateShaftPower(imo);
        UPDATE tempRawISO SET Delivered_Power = Shaft_Power;
		
    /* Check if engine data available */
    ELSEIF @isBrakeAvail THEN
		
		IF @isMassNeeded THEN
			CALL updateMassFuelOilConsumed(imo);
        END IF;
		
		CALL updateBrakePower(imo);
        UPDATE tempRawISO SET Delivered_Power = Brake_Power;
		
    /* Error if value cannot be calculated */
    ELSE
		
		SIGNAL powerIncalculable
		  SET MESSAGE_TEXT = 'Delivered Power cannot be calculated without either sufficient inputs for shaft power or brake power';
		
    END IF;
END;