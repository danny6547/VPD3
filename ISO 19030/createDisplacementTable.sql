/* Create displacement table for vessel */



DROP PROCEDURE IF EXISTS createDisplacement;

delimiter //

CREATE PROCEDURE createDisplacement()

	BEGIN
	
	CREATE TABLE Displacement (id INT PRIMARY KEY AUTO_INCREMENT,
								 IMO_Vessel_Number INT NOT NULL,
								 Draft_Aft DOUBLE(10, 5),
								 Draft_Fore DOUBLE(10, 5),
								 Trim DOUBLE(10, 5),
								 Displacement DOUBLE(10, 5));
								 
	END;