/* Create table for Performance Data calculated by DNVGL, sourced from EcoInsight */



DROP PROCEDURE IF EXISTS createDNVGLPerformanceData;

delimiter //

CREATE PROCEDURE createDNVGLPerformanceData()

BEGIN

	CREATE TABLE DNVGLPerformanceData (id INT PRIMARY KEY AUTO_INCREMENT,
							 DateTime_UTC DATETIME NOT NULL,
							 IMO_Vessel_Number INT(7) NOT NULL,
							 Performance_Index DOUBLE(10, 7),
							 Speed_Index DOUBLE(10, 7),
							 CONSTRAINT UniqueDateIMO UNIQUE(DateTime_UTC, IMO_Vessel_Number)
							 );
							 
END;