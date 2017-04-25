/* Remove rows containing any invalid data (don't worry, I'm gonna rewrite this later.) */




delimiter //

CREATE PROCEDURE removeInvalidRecords()
BEGIN

	DELETE FROM tempRawISO WHERE Mass_Consumed_Fuel_Oil <= 0;
    
    
END;