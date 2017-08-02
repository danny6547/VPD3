/* Create table for coefficients of fit of speed, power curves at given displacement and trim.
The coefficients are found by fitting the data to the formula: y = A . e ^ (x . B) where x is
the vessel speed through water and y is the delivered power. */



DROP PROCEDURE IF EXISTS createspeedPowerCoefficients;

delimiter //

CREATE PROCEDURE createspeedPowerCoefficients()

BEGIN

	CREATE TABLE speedPowerCoefficients (id INT PRIMARY KEY AUTO_INCREMENT,
											 ModelID INT NOT NULL UNIQUE,
											 Displacement DOUBLE(20, 3),
											 Trim DOUBLE(10, 8),
											 Coefficient_A DOUBLE(10, 5),
											 Coefficient_B DOUBLE(10, 5),
											 R_Squared DOUBLE(10, 9),
											 constraint UniqueSpeedPowerCurves UNIQUE(Displacement, Trim, Coefficient_A, Coefficient_B)
											 );
											 
END;