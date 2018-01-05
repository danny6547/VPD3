/* Create table of vessel speed, power, draft, trim data */



DROP PROCEDURE IF EXISTS createSpeedPower;

delimiter //

CREATE PROCEDURE createSpeedPower()

BEGIN

	CREATE TABLE SpeedPower (id INT PRIMARY KEY AUTO_INCREMENT, 
								ModelID INT NOT NULL,
								Draft_Fore DOUBLE(10, 5),
								Draft_Aft DOUBLE(10, 5),
								Trim DOUBLE(10, 5),
								Displacement DOUBLE(10, 1),
								Propulsive_Efficiency DOUBLE(10, 5),
								Speed DOUBLE(10, 5), /* m/s */
								Power DOUBLE(12, 5), /* kW */
								CONSTRAINT UniqueDispTrimSpeed UNIQUE(ModelID, Displacement, Trim, Speed, Power));
END;