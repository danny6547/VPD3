
DROP FUNCTION IF EXISTS rad2deg;

delimiter //

CREATE FUNCTION rad2deg(rad DOUBLE) RETURNS DOUBLE
	deterministic
BEGIN

	DECLARE angle_deg DOUBLE;
    DECLARE rad_conv DOUBLE;
    
    SET rad_conv = PI() / 180;

	SET angle_deg = rad * rad_conv;

	RETURN(angle_deg);
END