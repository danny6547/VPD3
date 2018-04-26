/* Create table for coefficients of SFOC fitted curve */



DROP PROCEDURE IF EXISTS createEngineModel;

delimiter //

CREATE PROCEDURE createEngineModel()

BEGIN

	CREATE TABLE EngineModel (Engine_Model_Id INT PRIMARY KEY AUTO_INCREMENT, 
									Engine_Model NVARCHAR(100) UNIQUE, 
									X0 FLOAT(15) NOT NULL, 
									X1 FLOAT(15) NOT NULL,  
									X2 FLOAT(15) NOT NULL, 
									Minimum_FOC_ph FLOAT(15) NOT NULL, 
									Lowest_Given_Brake_Power FLOAT(15) NOT NULL,
									Highest_Given_Brake_Power FLOAT(15) NOT NULL, 
									Description TEXT,
									Fuel_Type NCHAR(10)
									);
									
END;