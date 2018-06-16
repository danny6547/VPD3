/* Sort data by time */




delimiter //

CREATE PROCEDURE sortOnDateTime()
BEGIN

	ALTER TABLE `inservice`.tempRawISO ORDER BY Timestamp ASC;
    
END