DELETE PROCEDURE updateValidated

delimiter //

CREATE PROCEDURE updateValidated()

BEGIN

	SELECT DateTime_UTC FROM tempRawISO LIMIT 1;

END;