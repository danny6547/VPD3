/* Create filter for values below the lowest value of power in the appropriate speed-power curve */

DROP PROCEDURE IF EXISTS filterPowerBelowMinimum;

delimiter //

CREATE PROCEDURE filterPowerBelowMinimum(imo INT)

BEGIN
	
    /* Get nearest displacements and trim */
	UPDATE tempRawISO SET FilterSPBelow = FALSE;
	
END