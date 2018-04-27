/* Create vessel table, containing all time-invariant vessel data relevant for vessel identification and processing of performance values. */



DROP PROCEDURE IF EXISTS createVesselInfo;

delimiter //

CREATE PROCEDURE createVesselInfo()

BEGIN

	CREATE TABLE VesselInfo (Vessel_Info_Id INT PRIMARY KEY AUTO_INCREMENT,
							 Vessel_Id INT(10),
                             Valid_From DATETIME,
                             Vessel_Name TEXT,
                             Deleted BOOL,
                             CONSTRAINT UniqueVesselName UNIQUE(Vessel_Id, Valid_From)
							 );
END;