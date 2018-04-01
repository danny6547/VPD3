/* Create vessel table, containing all time-invariant vessel data relevant for vessel identification and processing of performance values. */



DROP PROCEDURE IF EXISTS createVesselOwner;

delimiter //

CREATE PROCEDURE createVesselOwner()

BEGIN

	CREATE TABLE Vessel_Owner (id INT PRIMARY KEY AUTO_INCREMENT,
							 Vessel_Owner_Id INT(10),
							 Vessel_Id INT(10),
							 Ownership_Start DATETIME,
							 Ownership_End DATETIME
							 );
END;