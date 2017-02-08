/* Create table for sensor recalibration events */

USE hull_performance;


CREATE TABLE sensorRecalibration (id INT PRIMARY KEY AUTO_INCREMENT, IMO_Vessel_Number INT(7), DateTime_UTC DATETIME, SensorName VARCHAR(255), RecalibrationDescription TEXT);