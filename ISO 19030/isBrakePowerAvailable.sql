/* Check if brake power is available */

delimiter //

CREATE PROCEDURE isBrakePowerAvailable(imo INT, OUT isAvailable BOOLEAN)
BEGIN
	
    DECLARE MfocAvail BOOLEAN;
    DECLARE LCVAvail BOOLEAN;
    
    SET MfocAvail := FALSE;
    SET LCVAvail := FALSE;
    
    SET isAvailable = FALSE;
    
    /* Check if Mass of fuel oil consumed is not all NULL */
    IF (SELECT COUNT(*) FROM tempRawISO WHERE Mass_Consumed_Fuel_Oil IS NOT NULL) = 0 THEN
		
        /* Check if Mass of fuel oil consumed can be calculated */
        IF (SELECT COUNT(*) FROM tempRawISO WHERE Volume_Consumed_Fuel_Oil IS NOT NULL AND
												  Density_Fuel_Oil_15C  IS NOT NULL AND
                                                  Density_Change_Rate_Per_C  IS NOT NULL AND
                                                  Temp_Fuel_Oil_At_Flow_Meter IS NOT NULL
			) > 0 THEN
        
			SET MfocAvail := TRUE;
        END IF;
        
	ELSE
        
        SET MfocAvail := TRUE;
    END IF;
    
    /* Check if LCV is available */
    IF (SELECT COUNT(*) FROM tempRawISO WHERE Lower_Caloirifc_Value_Fuel_Oil IS NOT NULL) > 0 THEN
		SET LCVAvail := TRUE;
    END IF;
    
    /* Brake Power available when both are available */
	SET isAvailable = LCVAvail AND MfocAvail;
    
END;
