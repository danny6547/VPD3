/* Create table for coefficients of fit of speed, power curves at given displacement and trim.
The coefficients are found by fitting the data to the formula: y = A . e ^ (x . B) where x is
the vessel speed through water and y is the delivered power. */



DROP PROCEDURE IF EXISTS createSpeedPowerCoefficientModelValue;

delimiter //

CREATE PROCEDURE createSpeedPowerCoefficientModelValue()

BEGIN

	CREATE TABLE `static`.speedPowerCoefficientModelValue (Speed_Power_Coefficient_Model_Value_Id INT PRIMARY KEY AUTO_INCREMENT,
											 Speed_Power_Coefficient_Model_Id INT(10) NOT NULL,
											 Displacement FLOAT(15, 3) NOT NULL,
											 Trim FLOAT(15, 8) NOT NULL,
											 Coefficient_A FLOAT(15, 10) NOT NULL,
											 Coefficient_B FLOAT(15, 10) NOT NULL,
											 Coefficient_Q FLOAT(15, 10),
											 R_Squared FLOAT(15, 14) NOT NULL,
											 Maximum_Power FLOAT(15, 3) NOT NULL,
											 Minimum_Power FLOAT(15, 3) NOT NULL
                                             /*UNIQUE UniqueCurvesProbably (Speed_Power_Coefficient_Model_Id, Displacement, Trim, Coefficient_A, Coefficient_B, Maximum_Power, Minimum_Power)*/
											 );
END;