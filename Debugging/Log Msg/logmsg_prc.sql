/* Procedure for storing data in a "Log Table" for debugging. */
/* Place the below syntax into your code to store the state of variable VAR in table LOGT: 
CALL log_msg('VAR = ', VAR);
*/

delimiter //
DROP PROCEDURE IF EXISTS `log_msg`//
CREATE PROCEDURE `log_msg`(msg1 VARCHAR(255), msg2 VARCHAR(255))
BEGIN
    insert into logt select 0, msg1, msg2;
END