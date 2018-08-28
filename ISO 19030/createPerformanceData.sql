/* Create Bunker Delivery Note Table for Vessels */

DROP PROCEDURE IF EXISTS createPerformanceData;

delimiter //

CREATE PROCEDURE createPerformanceData()

BEGIN

CREATE TABLE PerformanceData (id INT PRIMARY KEY AUTO_INCREMENT,
								IMO_Vessel_Number INT(7),
								DateTime_UTC DATETIME,
								Performance_Index FLOAT(10, 8),
								Speed_Index FLOAT(10, 8),
                                CONSTRAINT UniVesselDate UNIQUE(IMO_Vessel_Number, DateTime_UTC)
                                );
END