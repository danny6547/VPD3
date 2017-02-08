/* Update delivered power from either shaft power or delivered power. 
Procedure will check if shaft power if already provided and, if so, assign
it to delivered power. If not, it will check whether shaft power can be 
calculated and, if so, it will call updateShaftPower. If not, it will check 
whether brake power can be calculated and if so, it will call 
updateBrakePower. If not, an error will be returned. */

USE hull_performance;


DROP PROCEDURE IF EXISTS updateDeliveredPower;

delimiter //

CREATE PROCEDURE updateDeliveredPower(imo INT)
BEGIN
	
    /* DECLARATIONS */
    /* DECLARE isAvail BOOLEAN; */
    
    /* Check if torsio-metre data available 
    CALL log_msg(concat('isShaftAvail = ', @isShaftAvail));
		CALL log_msg(concat('UPDATE shaft power called')); */
	DECLARE powerIncalculable CONDITION FOR SQLSTATE '45000';
    
    DECLARE isShaftRequired BOOLEAN Default TRUE;
    SET isShaftRequired := (SELECT COUNT(*) FROM tempRawISO WHERE Shaft_Power IS NOT NULL) = 0;
	
    CALL isShaftPowerAvailable(imo, @isShaftAvail);
    CALL isBrakePowerAvailable(imo, @isBrakeAvail, @isMassNeeded);
    
    IF NOT isShaftRequired THEN
    
		UPDATE tempRawISO SET Delivered_Power = Shaft_Power;
    
    ELSEIF @isShaftAvail THEN
		
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