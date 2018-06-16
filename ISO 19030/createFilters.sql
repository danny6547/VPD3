/* Create table of filters indicating where data should be removed according to the standard.
 
*/

DROP PROCEDURE IF EXISTS createFilters;

delimiter //

CREATE PROCEDURE createFilters()

	BEGIN
	
	CREATE TABLE `static`.Filters (id INT PRIMARY KEY AUTO_INCREMENT,
                         IMO_Vessel_Number INT(7),
						 DateTime_UTC DATETIME,
						 Filter_SpeedPower_Below BOOLEAN,
						 Filter_SpeedPower_Above BOOLEAN,
						 Filter_SpeedPower_Trim BOOLEAN,
						 Filter_SpeedPower_Disp BOOLEAN,
						 Filter_Reference_Seawater_Temp BOOLEAN DEFAULT FALSE,
						 Filter_Reference_Wind_Speed BOOLEAN DEFAULT FALSE,
						 Filter_Reference_Water_Depth BOOLEAN DEFAULT FALSE,
						 Filter_Reference_Rudder_Angle BOOLEAN DEFAULT FALSE,
						 Filter_SFOC_Out_Range BOOLEAN DEFAULT FALSE
                                 );
	END;