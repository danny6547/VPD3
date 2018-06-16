/* Create vessel table, containing all time-invariant vessel data relevant for vessel identification and processing of performance values. */



DROP PROCEDURE IF EXISTS createVesselToVesselOwner;

delimiter //

CREATE PROCEDURE createVesselToVesselOwner()

BEGIN

	CREATE TABLE `static`.VesselToVesselOwner (Vessel_To_Vessel_Owner_Id INT PRIMARY KEY AUTO_INCREMENT,
							 Vessel_Owner_Id INT,
							 Vessel_Id INT,
							 Ownership_Start DATETIME,
							 Ownership_End DATETIME,
                             UNIQUE OneVesselAtATime (Vessel_Id, Ownership_Start, Ownership_End)
							 );
END;