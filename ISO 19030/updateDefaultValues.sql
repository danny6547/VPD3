/* Set default values for any missing data, as given in the standard */

DROP PROCEDURE IF EXISTS updateDefaultValues;

delimiter //

CREATE PROCEDURE updateDefaultValues()

BEGIN
	
    IF (SELECT COUNT(Air_Temperature) FROM tempRawISO) = 0 THEN
    
		UPDATE tempRawISO SET Air_Temperature = 15;
    END IF;
    
    IF (SELECT COUNT(Air_Pressure) FROM tempRawISO) = 0 THEN
    
		UPDATE tempRawISO SET Air_Pressure = 101.325;
    END IF;
    
END;