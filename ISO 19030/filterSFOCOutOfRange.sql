/* Create filter to remove data corresponding to brake power values below the minimum or above the maximum of the available engine test data */

DROP PROCEDURE IF EXISTS filterSFOCOutOfRange;

delimiter //

CREATE PROCEDURE filterSFOCOutOfRange()

BEGIN

	select * from temprawiso;

END;