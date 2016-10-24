delimiter //

CREATE PROCEDURE prc_test ()
BEGIN
    DECLARE var2 INT DEFAULT 1;
    SET var2 := var2 + 1;
    SET @var2 := @var2 + 1;
    SELECT var2, @var2;
END;
