/* Create table for global constants */



DROP PROCEDURE IF EXISTS createglobalConstants;

delimiter //

CREATE PROCEDURE createglobalConstants()

	BEGIN

		DROP TABLE IF EXISTS `static`.globalConstants;
		CREATE TABLE `static`.globalConstants (id INT PRIMARY KEY AUTO_INCREMENT, Specific_Gas_Constant_Air DOUBLE(6, 3), g DOUBLE(10, 5));
		INSERT INTO `static`.globalConstants (Specific_Gas_Constant_Air, g) VALUES (287.058, 9.80665);

	END