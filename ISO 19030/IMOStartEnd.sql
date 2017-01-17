/* Return IMO Vessel Number, the start and end dates of the analysis */

DROP PROCEDURE IF EXISTS IMOStartEnd;

delimiter //

CREATE PROCEDURE IMOStartEnd(OUT imo INT(7), OUT startd DATETIME, OUT endd DATETIME)

BEGIN

SET imo := (SELECT DISTINCT(IMO_Vessel_Number) FROM tempRawISO);
SET startd := (SELECT MIN(DateTime_UTC) FROM tempRawISO);
SET endd := (SELECT MAX(DateTime_UTC) FROM tempRawISO);

END;