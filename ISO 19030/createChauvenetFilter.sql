/* Create temp table for Chauvenet Filters, used in calculation of Chauvenet_Filter column by procedure updateChauvenetCriteria */



DROP PROCEDURE IF EXISTS createTempChauvenetFilter;

delimiter //

CREATE PROCEDURE createTempChauvenetFilter()

	BEGIN

		DROP TABLE IF EXISTS ChauvenetTempFilter;

		CREATE TABLE ChauvenetTempFilter (id INT PRIMARY KEY AUTO_INCREMENT,
										
										Speed_Through_Water BOOLEAN, 
										Delivered_Power BOOLEAN, 
										Relative_Wind_Speed BOOLEAN, 
										Relative_Wind_Direction BOOLEAN, 
										Speed_Over_Ground BOOLEAN, 
										Ship_Heading BOOLEAN, 
										Shaft_Revolutions BOOLEAN, 
										Water_Depth BOOLEAN, 
										Rudder_Angle BOOLEAN, 
                                        Air_Temperature BOOLEAN,
                                        Static_Draught_Fore BOOLEAN,
                                        Static_Draught_Aft BOOLEAN,
										Seawater_Temperature BOOLEAN);
									
	END;