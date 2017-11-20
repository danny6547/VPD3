/* Process data for vessel performance analysis as described in ISO 19030-2 */

DROP PROCEDURE IF EXISTS cleanData;

delimiter //

CREATE PROCEDURE cleanData()
BEGIN
	
	/* Remove empty draft values */
    DELETE FROM tempRawISO WHERE Static_Draught_Fore IS NULL OR Static_Draught_Aft IS NULL;
END;