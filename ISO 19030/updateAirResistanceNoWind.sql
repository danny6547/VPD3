/* Update Air Resistance in no-wind condition */

DROP PROCEDURE IF EXISTS updateAirResistanceNoWind;

delimiter //

CREATE PROCEDURE updateAirResistanceNoWind(vcid INT)
BEGIN

	SET @currModel = (SELECT Wind_Coefficient_Model_Id FROM `static`.VesselConfiguration WHERE Vessel_Configuration_Id = vcid);

	UPDATE tempRawISO
	SET Air_Resistance_No_Wind = 
		0.5 * 
		Air_Density * 
		POWER(Speed_Over_Ground, 2) *
        Transverse_Projected_Area_Current * 
		( SELECT Coefficient FROM `static`.WindCoefficientModelValue WHERE Wind_Coefficient_Model_Id = @currModel AND Direction = 0 );
END;