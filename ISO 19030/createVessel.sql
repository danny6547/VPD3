/* Create vessel table, containing all time-invariant vessel data relevant for vessel identification and processing of performance values. */



DROP PROCEDURE IF EXISTS createVessel;

delimiter //

CREATE PROCEDURE createVessel()

BEGIN

	CREATE TABLE Vessel (Vessel_id INT PRIMARY KEY AUTO_INCREMENT,
							 IMO INT UNIQUE NOT NULL,
                             Deleted BINARY
							 );
END;