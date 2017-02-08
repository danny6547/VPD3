/* Create displacement table for vessel */

USE hull_performance;


CREATE TABLE Displacement (id INT PRIMARY KEY AUTO_INCREMENT,
							 IMO_Vessel_Number INT,
							 Draft_Aft DOUBLE(10, 5),
							 Draft_Fore DOUBLE(10, 5),
							 Trim DOUBLE(10, 5),
							 Displacement DOUBLE(10, 5));