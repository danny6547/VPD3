
DROP FUNCTION IF EXISTS knots2mps;

delimiter //

CREATE FUNCTION knots2mps(speed DOUBLE) RETURNS DOUBLE
	deterministic
BEGIN

	DECLARE speed_mps DOUBLE;
    
	SET speed_mps = speed * 0.51444444444;

	RETURN(speed_mps);
END