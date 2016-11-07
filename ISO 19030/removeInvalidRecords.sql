/* Remove rows containing any invalid data */

delimiter //

CREATE PROCEDURE removeInvalidRecords()
BEGIN

	DELETE FROM tempRawISO WHERE Mass_Consumed_Fuel_Oil = 0;
    
END;