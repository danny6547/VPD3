/* Remove rows containing any invalid data */


DROP PROCEDURE IF EXISTS removeInvalidRecords;

delimiter //

CREATE PROCEDURE removeInvalidRecords()

BEGIN

	UPDATE tempRawISO SET Mass_Consumed_Fuel_Oil = NULL WHERE Mass_Consumed_Fuel_Oil <= 0;
    UPDATE tempRawISO SET Water_Depth = NULL WHERE Water_Depth > 1.2E4 OR Water_Depth <= 0;
    UPDATE tempRawISO SET Relative_Wind_Speed = NULL WHERE Relative_Wind_Speed > 1E3 OR Relative_Wind_Speed <= 0;
    
    
END;