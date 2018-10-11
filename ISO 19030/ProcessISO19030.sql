/* Process data according to the procedure described in ISO19030, and assign into the CalculatedData table */

DROP PROCEDURE IF EXISTS ProcessISO19030;

delimiter //

CREATE PROCEDURE ProcessISO19030(vcid INT)

BEGIN

	/* Get data for compliance table for this analysis */
	CALL ISO19030(vcid);
    CALL insertIntoCalculatedData();
END;