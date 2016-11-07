/* Remove rows containing any invalid data */

delimiter //

CREATE PROCEDURE removeInvalidRecords()
BEGIN

	SELECT * FROM tempRawISO;
    
END;