/* Create vessel table, containing all time-invariant vessel data relevant for vessel identification and processing of performance values. */



DROP PROCEDURE IF EXISTS createVesselInfo;

delimiter //

CREATE PROCEDURE createVesselInfo()

BEGIN

	CREATE TABLE VesselInfo (id INT PRIMARY KEY AUTO_INCREMENT,
							 Vessel_Id INT(10),
                             Valid_From DATETIME,
                             Vessel_Name TEXT,
                             Deleted BOOL
							 );
END;