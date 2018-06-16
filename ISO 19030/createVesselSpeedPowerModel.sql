/* Create table to relate Vessel IMO Numbers with Speed, Power models */

DROP PROCEDURE IF EXISTS createVesselSpeedPowerModel;

delimiter //

CREATE PROCEDURE createVesselSpeedPowerModel()

BEGIN

	CREATE TABLE `static`.VesselSpeedPowerModel (id INT PRIMARY KEY AUTO_INCREMENT,
										IMO_Vessel_Number INT(7),
                                        Speed_Power_Model INT,
										CONSTRAINT UNIQUE `UniqueEverything` (`IMO_Vessel_Number`,`Speed_Power_Model`)
                                        );
END