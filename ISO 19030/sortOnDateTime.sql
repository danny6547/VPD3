/* Sort data by time */

DROP PROCEDURE IF EXISTS sortOnDateTime;

delimiter //

CREATE PROCEDURE sortOnDateTime()
BEGIN

	ALTER TABLE tempRawISO ORDER BY Timestamp ASC;
    
END