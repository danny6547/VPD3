/* Removes any rows containing NULL values for Date_UTC or Time_UTC from table tempraw. */




delimiter //

CREATE PROCEDURE removeNullRows()
BEGIN

	DELETE FROM tempraw WHERE Date_UTC IS NULL OR Time_UTC IS NULL;

END;