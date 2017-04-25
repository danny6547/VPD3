/* Create vessel table, containing all time-invariant vessel data relevant for vessel identification and processing of performance values. */



DROP PROCEDURE IF EXISTS createVessels;

delimiter //

CREATE PROCEDURE createVessels()

BEGIN

	CREATE TABLE Vessels (id INT PRIMARY KEY AUTO_INCREMENT,
							 IMO_Vessel_Number INT NOT NULL,
							 Name VARCHAR(100),
							 Owner VARCHAR(100),
							 Engine_Model VARCHAR(100),
							 Transverse_Projected_Area_Design DOUBLE(10, 5),
							 Block_Coefficient DOUBLE(10, 5),
							 Breadth_Moulded DOUBLE(10, 5),
							 Length_Overall DOUBLE(10, 5),
							 Draft_Design DOUBLE(10, 5),
							 Speed_Power_Source TEXT,
							 LBP DOUBLE(10, 5),
							 Wind_Model_ID INT,
							 CONSTRAINT UNIQUE(IMO_Vessel_Number)
							 );
						 
END;