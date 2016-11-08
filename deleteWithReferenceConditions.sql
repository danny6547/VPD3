/* Remove rows containing data which fails the reference conditions given in standard ISO 19030-2 */

delimiter //

CREATE PROCEDURE deleteWithReferenceConditions()

BEGIN
	
	DELETE FROM tempRawISO WHERE Seawater_Temperature <= 2;
    
END;