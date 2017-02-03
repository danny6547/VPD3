/* Update trim based on fore and aft draft */

DROP PROCEDURE IF EXISTS updateTrim;

delimiter //

CREATE PROCEDURE updateTrim()

BEGIN

	UPDATE tempRawISO SET Trim = Static_Draught_Fore - Static_Draught_Aft;

END;