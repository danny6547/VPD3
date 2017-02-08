/* Create table for Performance Data calculated by DNVGL, sourced from EcoInsight */

USE hull_performance;


CREATE TABLE PerformanceDataDNVGL (id INT PRIMARY KEY AUTO_INCREMENT,
						 DateTime_UTC DATETIME,
                         IMO_Vessel_Number INT(7),
						 Performance_Index DOUBLE(10, 7),
						 Speed_Index DOUBLE(10, 7),
                         CONSTRAINT UniqueDateIMO UNIQUE(DateTime_UTC, IMO_Vessel_Number)
                         );