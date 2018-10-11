/* Create table for storing dates of vessel dry-dockings */



DROP PROCEDURE IF EXISTS createDryDock;

delimiter //

CREATE PROCEDURE createDryDock()

BEGIN

	CREATE TABLE `static`.DryDock (Dry_Dock_Id INTEGER AUTO_INCREMENT PRIMARY KEY,
								Vessel_Id INT(10) NOT NULL,
								Start_Date DATE NOT NULL,
								End_Date DATE NOT NULL,
								Bot_Top_Surface_Prep NVARCHAR(255),
								Bot_Top_Coating NVARCHAR(255),
								Vertical_Bottom_Surface_Prep NVARCHAR(255),
								Vertical_Bottom_Coating NVARCHAR(255),
								Flat_Bottom_Surface_Prep NVARCHAR(255),
								Flat_Bottom_Coating NVARCHAR(255),
								Average_Speed_Expected FLOAT(15, 3),
								Activity_Expected FLOAT(15, 3),
								Longest_Idle_Period_Expected FLOAT(15, 3),
								Deleted BOOL NOT NULL,
								constraint UniRows UNIQUE(Vessel_Id, Start_Date, End_Date)
								);

END
