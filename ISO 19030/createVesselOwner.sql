/* Create vessel table, containing all time-invariant vessel data relevant for vessel identification and processing of performance values. */



DROP PROCEDURE IF EXISTS createVesselOwner;

delimiter //

CREATE PROCEDURE createVesselOwner()

BEGIN

	CREATE TABLE VesselOwner (Vessel_Owner_Id INT PRIMARY KEY AUTO_INCREMENT,
							 Vessel_Owner_Name TEXT,
							 Deleted BOOL
							 );
END;