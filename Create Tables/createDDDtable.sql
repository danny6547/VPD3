/* Create table for storing dates of vessel dry-dockings */
use test2;
CREATE TABLE DryDockDates (
id INTEGER AUTO_INCREMENT PRIMARY KEY,
IMO_Vessel_Number INTEGER,
StartDate DATE,
EndDate DATE)
