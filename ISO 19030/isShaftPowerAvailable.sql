/* Check if shaft power is available */

delimiter //

CREATE PROCEDURE isShaftPowerAvailable(imo INT, OUT isAvailable BOOLEAN)
BEGIN
	
    /* Check if torque and rpm are both not all NULL */
    SET isAvailable = FALSE;
    
END;