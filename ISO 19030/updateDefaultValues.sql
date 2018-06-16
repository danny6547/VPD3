/* Set default values for any missing data, as given in the standard */

DROP PROCEDURE IF EXISTS updateDefaultValues;

delimiter //

CREATE PROCEDURE updateDefaultValues()

BEGIN
	
    IF (SELECT COUNT(Air_Temperature) FROM `inservice`.tempRawISO) = 0 THEN
    
		UPDATE `inservice`.tempRawISO SET Air_Temperature = 15;
    END IF;
    
    IF (SELECT COUNT(Air_Pressure) FROM `inservice`.tempRawISO) = 0 THEN
    
		UPDATE `inservice`.tempRawISO SET Air_Pressure = 101325;
    END IF;
    
END;