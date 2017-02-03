/* Sort data by time */

delimiter //

CREATE PROCEDURE sortOnDateTime()
BEGIN

	ALTER TABLE tempRawISO ORDER BY DateTime_UTC ASC;
    
END