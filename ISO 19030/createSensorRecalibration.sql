/* Create table for sensor recalibration events */



DROP PROCEDURE IF EXISTS createsensorRecalibration;

delimiter //

CREATE PROCEDURE createsensorRecalibration()

BEGIN

	CREATE TABLE sensorRecalibration (id INT PRIMARY KEY AUTO_INCREMENT,
										IMO_Vessel_Number INT(7) NOT NULL,
										DateTime_UTC DATETIME NOT NULL,
										SensorName VARCHAR(255),
										RecalibrationDescription TEXT);

END;