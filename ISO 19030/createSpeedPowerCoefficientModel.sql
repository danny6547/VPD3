/* Create table for coefficients of fit of speed, power curves at given displacement and trim.
The coefficients are found by fitting the data to the formula: y = A . e ^ (x . B) where x is
the vessel speed through water and y is the delivered power. */



DROP PROCEDURE IF EXISTS createSpeedPowerCoefficientModel;

delimiter //

CREATE PROCEDURE createSpeedPowerCoefficientModel()

BEGIN

	CREATE TABLE speedPowerCoefficientModel (Speed_Power_Coefficient_Model_Id INT PRIMARY KEY AUTO_INCREMENT,
											 Name NVARCHAR(100),
											 Description TEXT,
                                             Deleted BOOL NOT NULL,
                                             Loading_Conditions FLOAT(15)
											 );
END;