/* Create temp table for Chauvenet Filters, used in calculation of Chauvenet_Filter column by procedure updateChauvenetCriteria */

USE hull_performance;


DROP PROCEDURE IF EXISTS createTempChauvenetFilter;

delimiter //

CREATE PROCEDURE createTempChauvenetFilter()

	BEGIN

		DROP TABLE IF EXISTS ChauvenetTempFilter;

		CREATE TABLE ChauvenetTempFilter (id INT PRIMARY KEY AUTO_INCREMENT, 
										Speed_Through_Water BOOLEAN, 
										Delivered_Power BOOLEAN, 
										Shaft_Revolutions BOOLEAN, 
										Relative_Wind_Speed BOOLEAN, 
										Relative_Wind_Direction BOOLEAN, 
										Speed_Over_Ground BOOLEAN, 
										Ship_Heading BOOLEAN, 
										Rudder_Angle BOOLEAN, 
										Water_Depth BOOLEAN, 
										Seawater_Temperature BOOLEAN);
									
	END;