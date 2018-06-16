/* Create table of vessel speed, power, draft, trim data */



DROP PROCEDURE IF EXISTS createSpeedPower;

delimiter //

CREATE PROCEDURE createSpeedPower()

BEGIN

	CREATE TABLE `static`.SpeedPower (id INT PRIMARY KEY AUTO_INCREMENT, 
								Speed_Power_Coefficient_Model_Value_Id INT NOT NULL,
								Draft_Fore DOUBLE(10, 5),
								Draft_Aft DOUBLE(10, 5),
								Propulsive_Efficiency DOUBLE(10, 5),
								Speed DOUBLE(10, 5), /* m/s */
								Power DOUBLE(12, 5) /* kW */
								/*CONSTRAINT UniqueDispTrimSpeed UNIQUE(Speed_Power_Coefficient_Model_Value_Id, Speed, Power)*/);
END;