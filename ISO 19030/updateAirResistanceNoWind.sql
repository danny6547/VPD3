/* Update Air Resistance in no-wind condition */

DROP PROCEDURE IF EXISTS updateAirResistanceNoWind;

delimiter //

CREATE PROCEDURE updateAirResistanceNoWind(imo INT)
BEGIN

	SET @currModel = (SELECT Wind_Model_ID FROM `static`.Vessels WHERE IMO_Vessel_Number = imo);

	UPDATE `inservice`.tempRawISO
	SET Air_Resistance_No_Wind = 
		0.5 * 
		Air_Density * 
		POWER(Speed_Over_Ground, 2) *
        Transverse_Projected_Area_Current * 
		( SELECT Coefficient FROM `static`.WindCoefficientDirection WHERE ModelID = @currModel AND Direction = 0 );

        
END;