/* Sort data by time */

USE hull_performance;


delimiter //

CREATE PROCEDURE sortOnDateTime()
BEGIN

	ALTER TABLE tempRawISO ORDER BY DateTime_UTC ASC;
    
END