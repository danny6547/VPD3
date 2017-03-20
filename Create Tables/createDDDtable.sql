/* Create table for storing dates of vessel dry-dockings */

USE hull_performance;

/* use test2; */
CREATE TABLE DryDockDates (
id INTEGER AUTO_INCREMENT PRIMARY KEY,
IMO_Vessel_Number INTEGER,
StartDate DATE,
EndDate DATE,
constraint UniRows UNIQUE(IMO_Vessel_Number, StartDate, EndDate)
)
