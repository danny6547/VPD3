/* Create vessel table, containing all vessel data required */

CREATE TABLE WindCoefficientDirection (id INT PRIMARY KEY AUTO_INCREMENT,
										 IMO_Vessel_Number INT,
										 Start_Direction DOUBLE(10, 5),
										 End_Direction DOUBLE(10, 5),
										 Coefficient DOUBLE(10, 9));