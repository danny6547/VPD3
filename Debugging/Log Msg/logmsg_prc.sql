/* Procedure for storing debugging data */

delimiter //
DROP PROCEDURE IF EXISTS `log_msg`//
CREATE PROCEDURE `log_msg`(msg1 VARCHAR(255), msg2 VARCHAR(255))
BEGIN
    insert into logt select 0, msg1, msg2;
END