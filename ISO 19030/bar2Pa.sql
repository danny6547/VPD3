
DROP FUNCTION IF EXISTS bar2Pa;

delimiter //

CREATE FUNCTION bar2Pa(press DOUBLE) RETURNS DOUBLE
	deterministic
BEGIN

	DECLARE press_Pa DOUBLE;
    
	SET press_Pa = press * 1e5;

	RETURN(press_Pa);
END