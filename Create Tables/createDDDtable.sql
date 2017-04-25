/* Create table for storing dates of vessel dry-dockings */



DROP PROCEDURE IF EXISTS createDryDockDates;

delimiter //

CREATE PROCEDURE createDryDockDates()

BEGIN

	CREATE TABLE DryDockDates (id INTEGER AUTO_INCREMENT PRIMARY KEY,
								IMO_Vessel_Number INT(7) NOT NULL,
								StartDate DATE NOT NULL,
								EndDate DATE NOT NULL,
								constraint UniRows UNIQUE(IMO_Vessel_Number, StartDate, EndDate)
								);

END
