/* Check if shaft power can be calculated */
/* Returns TRUE in output isAvailable when there is at least one row containing both non-NULL values for 
Shaft_Torque and Shaft_Revolutions. */


DROP PROCEDURE IF EXISTS isShaftPowerAvailable()


delimiter //

CREATE PROCEDURE isShaftPowerAvailable(vcid INT, OUT isAvailable BOOLEAN)
BEGIN
	
    SET isAvailable = FALSE;
    
    /* Check if torque and rpm are both not all NULL */
    IF (SELECT COUNT(*) FROM `inservice`.tempRawISO WHERE Shaft_Torque IS NOT NULL AND Shaft_Revolutions IS NOT NULL) > 0 THEN
    
		SET isAvailable = TRUE;
        
    END IF;
    
END;