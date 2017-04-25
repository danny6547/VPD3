/* Create table for coatings applied to vessels during dry-docking */



DROP PROCEDURE IF EXISTS createvesselCoating;

delimiter //

CREATE PROCEDURE createvesselCoating()

BEGIN

	CREATE TABLE vesselCoating (id INT PRIMARY KEY AUTO_INCREMENT, 
									IMO_Vessel_Number INT(7) NOT NULL,
									 CoatingName VARCHAR(255) NOT NULL,
									 DryDockId INT NOT NULL, 
									 CONSTRAINT UniIMODDI UNIQUE(IMO_Vessel_Number, DryDockId));
								 
END;