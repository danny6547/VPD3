/* Create vessel table, containing all time-invariant vessel data relevant for vessel identification and processing of performance values. */



DROP PROCEDURE IF EXISTS createVesselToVesselOwner;

delimiter //

CREATE PROCEDURE createVesselToVesselOwner()

BEGIN

	CREATE TABLE VesselToVesselOwner (id INT PRIMARY KEY AUTO_INCREMENT,
							 Vessel_Owner_Name NVARCHAR(100),
							 Deleted BOOL NOT NULL
							 );
END;