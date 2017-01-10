DROP PROCEDURE IF EXISTS updateTrim;

delimiter //

CREATE PROCEDURE updateTrim()

BEGIN

	UPDATE tempRawISO SET Trim = Trim;

END;