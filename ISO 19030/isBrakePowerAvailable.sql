/* Check if brake power can be calculated.
Returns value of TRUE for parameter isAvailable when at least one non-NULL
value can be found in the same row for columns 
Lower_Caloirifc_Value_Fuel_Oil and Mass_Consumed_Fuel_Oil. If all data for 
Mass_Consumed_Fuel_Oil is NULL, output parameter isMassNeeded will have 
value TRUE indicating that the mass of consumed fuel oil can be calculated 
from the volume amongst other variables.
*/

delimiter //

CREATE PROCEDURE isBrakePowerAvailable(imo INT, OUT isAvailable BOOLEAN, OUT isMassNeeded BOOLEAN)
BEGIN
	
    DECLARE MfocAvail BOOLEAN;
    DECLARE LCVAvail BOOLEAN;
    
    SET MfocAvail := FALSE;
    SET LCVAvail := FALSE;
    
    SET isAvailable = FALSE;
    SET isMassNeeded = FALSE;
    
    /* Check if Mass of fuel oil consumed is not all NULL */
    IF (SELECT COUNT(*) FROM `inservice`.tempRawISO WHERE Mass_Consumed_Fuel_Oil IS NOT NULL) = 0 THEN
		
        /* Check if Mass of fuel oil consumed can be calculated */
        IF (SELECT COUNT(*) FROM `inservice`.tempRawISO WHERE Volume_Consumed_Fuel_Oil IS NOT NULL AND
												  Density_Fuel_Oil_15C  IS NOT NULL AND
                                                  Density_Change_Rate_Per_C  IS NOT NULL AND
                                                  Temp_Fuel_Oil_At_Flow_Meter IS NOT NULL
																				) > 0 THEN
			SET MfocAvail := TRUE;
            SET isMassNeeded := TRUE;
        END IF;
        
	ELSE
        SET MfocAvail := TRUE;
    END IF;
    
    /* Check if LCV is available */
    IF (SELECT COUNT(*) FROM `inservice`.tempRawISO WHERE Lower_Caloirifc_Value_Fuel_Oil IS NOT NULL) > 0 THEN
		SET LCVAvail := TRUE;
    END IF;
    
    /* Brake Power available when both are available */
	SET isAvailable = LCVAvail AND MfocAvail;
    
END;
