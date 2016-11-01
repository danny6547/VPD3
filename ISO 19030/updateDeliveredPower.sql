/* Update delivered power */

delimiter //

CREATE PROCEDURE updateDeliveredPower(imo INT)
BEGIN
	
    /* Check if torsio-metre data available */
    IF (SELECT COUNT(*) FROM tempRawISO WHERE Shaft_Power IS NULL) = 0 THEN
		
        UPDATE tempRawISO SET Delivered_Power = Shaft_Power;
    
    /* Check if engine data available */
    
    
    /* Error if value cannot be calculated */
    
    
    END IF;
    
END;