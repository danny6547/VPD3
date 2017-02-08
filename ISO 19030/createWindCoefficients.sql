/* Create table for vessels' wind resistance coefficients, binned by start and end directions */
/* Start_Direction, End_Direction: These are the start and end directions of the range over 
which the corresponding coefficient is applied. The units are degrees, with 0 being the head-
wind direction and clockwise positive looking down on the vessel from above.*/

USE hull_performance;


CREATE TABLE WindCoefficientDirection (id INT PRIMARY KEY AUTO_INCREMENT,
										 IMO_Vessel_Number INT,
										 Start_Direction DOUBLE(10, 5),
										 End_Direction DOUBLE(10, 5),
										 Coefficient DOUBLE(10, 9));