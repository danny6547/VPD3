/* Create vessel table, containing all time-invariant vessel data relevant for vessel identification and processing of performance values. */

USE hull_performance;

CREATE TABLE Vessels (id INT PRIMARY KEY AUTO_INCREMENT,
						 IMO_Vessel_Number INT,
						 Name VARCHAR(100),
						 Owner VARCHAR(100),
						 Engine_Model VARCHAR(100),
						 Wind_Resist_Coeff_Head DOUBLE(10, 5),
						 Wind_Resist_Coeff_Dir DOUBLE(10, 5),
						 Transverse_Projected_Area_Design DOUBLE(10, 5),
						 Block_Coefficient DOUBLE(10, 5),
                         Breadth_Moulded DOUBLE(10, 5),
                         Length_Overall DOUBLE(10, 5),
                         Draft_Design DOUBLE(10, 5),
                         Speed_Power_Source TEXT,
						 LBP DOUBLE(10, 5),
                         CONSTRAINT UNIQUE(IMO_Vessel_Number)
                         );