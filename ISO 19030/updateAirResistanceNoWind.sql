/* Update Air Resistance in no-wind condition */

USE test2;

DROP PROCEDURE IF EXISTS updateAirResistanceNoWind;

delimiter //

CREATE PROCEDURE updateAirResistanceNoWind(imo INT)
BEGIN

	SET @currModel = (SELECT WindModelID FROM Vessels WHERE IMO_Vessel_Number = imo);

	UPDATE tempRawISO
	SET Air_Resistance_No_Wind = 
		0.5 * 
		Air_Density * 
		POWER(Speed_Over_Ground, 2) *
        Transverse_Projected_Area_Current * 
		( SELECT Coefficient FROM WindCoefficientDirection WHERE ModelID = @currModel AND Direction = 0 );
        
END;