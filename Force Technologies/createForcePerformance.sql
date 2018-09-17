/* Create table for Performance Data, i.e. the "Performance Values" described in ISO19030-2 and any 
other time-dependet measures of hull and propellor performance. */



DROP PROCEDURE IF EXISTS createForcePerformanceData;

delimiter //

CREATE PROCEDURE createForcePerformanceData()

	BEGIN

	CREATE TABLE PerformanceData (id INT PRIMARY KEY AUTO_INCREMENT,
							 DateTime_UTC DATETIME NOT NULL,
							 IMO_Vessel_Number INT(7) NOT NULL,
							 Consumption_Index DOUBLE(10, 7),
							 Speed_Index DOUBLE(10, 7),
							 Consumption_Index_Propeller DOUBLE(10, 7),
							 Speed_Index_Propeller DOUBLE(10, 7),
							 CONSTRAINT UniqueDateIMO UNIQUE(DateTime_UTC, IMO_Vessel_Number)
							 );
	END;