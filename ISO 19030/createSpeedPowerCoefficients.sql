/* Create table for coefficients of fit of speed power curve with formula y = A . e ^ (x . B) */

CREATE TABLE speedPowerCoefficients (id INT PRIMARY KEY AUTO_INCREMENT,
										 IMO_Vessel_Number INT,
										 Displacement DOUBLE(20, 3),
										 Exponent_A DOUBLE(10, 5),
										 Exponent_B DOUBLE(10, 5));