/* Create table for Performance Data, i.e. the "Performance Values" described in ISO19030-2 and any 
other time-dependet measures of hull and propellor performance. */

USE hull_performance;


CREATE TABLE PerformanceData (id INT PRIMARY KEY AUTO_INCREMENT,
						 DateTime_UTC DATETIME,
                         IMO_Vessel_Number INT(7),
						 Performance_Index DOUBLE(10, 7),
						 Speed_Index DOUBLE(10, 7),
                         CONSTRAINT UniqueDateIMO UNIQUE(DateTime_UTC, IMO_Vessel_Number)
                         );