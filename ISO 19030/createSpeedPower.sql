/* Create table of vessel speed, power, draft, trim data */

USE hull_performance;


CREATE TABLE SpeedPower (id INT PRIMARY KEY AUTO_INCREMENT, 
							IMO_Vessel_Number INT,
                            Draft_Fore DOUBLE(10, 5),
                            Draft_Aft DOUBLE(10, 5),
                            Trim DOUBLE(10, 5),
                            Displacement DOUBLE(10, 1),
                            Propulsive_Efficiency DOUBLE(10, 5),
                            Speed DOUBLE(10, 5),
                            Power DOUBLE(10, 5),
                            CONSTRAINT UniqueDispTrimSpeed UNIQUE(IMO_Vessel_Number, Displacement, Trim, Speed));