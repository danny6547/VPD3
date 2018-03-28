/* Create vessel table, containing all time-invariant vessel data relevant for vessel identification and processing of performance values. */



DROP PROCEDURE IF EXISTS createVesselConfiguration;

delimiter //

CREATE PROCEDURE createVesselConfiguration()

BEGIN

	CREATE TABLE VesselConfiguration (Vessel_Configuration_Id INT PRIMARY KEY AUTO_INCREMENT,
							 Vessel_Id INT(10) UNIQUE NOT NULL,
							 Engine_Model_Id INT(10),
							 Valid_From DateTime,
							 Valid_To DateTime,
                             DefaultConfiguration BINARY,
							 Engine_Model_Id INT(10),
							 Transverse_Projected_Area_Design FLOAT(15, 5),
							 Block_Coefficient FLOAT(15, 5),
							 Breadth_Moulded FLOAT(15, 5),
							 Length_Overall FLOAT(15, 5),
							 Draft_Design FLOAT(15, 5),
							 Speed_Power_Source TEXT,
                             Wind_Reference_Height_Design FLOAT(15, 5),
                             Anemometer_Height FLOAT(15, 5),
							 Displacement_Model_ID INT(10),
							 Speed_Power_Coefficient_Model_ID INT(10),
							 Wind_Coefficient_Model_ID INT,
                             VesselConfigurationDescription TEXT,
							 LBP FLOAT(15, 5),
                             Deleted BINARY,
                             ApplyWindCalculations BINARY,
                             FuelType TEXT
							 );
						 
END;