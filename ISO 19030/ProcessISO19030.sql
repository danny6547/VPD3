




DROP PROCEDURE IF EXISTS ProcessISO19030;

delimiter //

CREATE PROCEDURE ProcessISO19030(imo INT(7), allFilt BOOLEAN, speedPowerFilt BOOLEAN, SFOCFilt BOOLEAN)

BEGIN

	/* Get data for compliance table for this analysis */
	CALL `inservice`.ISO19030(imo);
    
	CALL `inservice`.insertIntoPerformanceData(allFilt, speedPowerFilt, SFOCFilt);
END;